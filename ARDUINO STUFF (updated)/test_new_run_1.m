% Entire system code - to stop it, do Ctrl+c
clear

% setup pins 
trigger_pin= 'D8';
echo_pin = 'D9';
batch_valve_pin = 'D4';
brine_valve_pin = 'D3';
feed_valve_pin = 'D5';
flowrate_pin = 'A0';
conductivity_pin = 'A1';

% Setup Arduino and Ultrasonic sensor
a = arduino('COM5', 'Mega2560','Libraries', 'Ultrasonic');
ultrasonicObj = ultrasonic(a,trigger_pin, echo_pin, 'OutputFormat','double');

% Setup Scale
if ~isempty(instrfind)
  fclose(instrfind);
  delete(instrfind);
end

s = serial('COM13', 'baudrate', 9600); % scale
 set(s,'Parity', 'none');
 set(s,'DataBits', 8);
 set(s,'StopBit', 1);

fopen(s)

% constants

% distance constants are passed into check state functions, change the
% values here instead of in the function

empty_tank_dist = 25.5;  % cm, top of the tank to the top of the drainage square with some extra room
full_tank_dist = 19;  % cm  (CHANGE LATER?)
time_step = 0.50; % seconds (this is not actually the real time step between data points)
flow_loop_volume = 150; % ml, the total amount of water in one batch
flush_tube_volume = 72; % ml, the amount water in the tubes

% empty lists 
time_list = [];
mass_list = [];
distance_list = [];
conductivity_list = [];
flowrate_list = [];

% main code 
run = 1;
t = tic();

while run == 1
    % REGULAR DATA COLLECTION
    conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin);
    [distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin); 
    [flowrate_list, flowrate] = flowrate_reading(a, flowrate_list, flowrate_pin);
    [mass_list, mass] = scale_reading(s, mass_list);

    % Read time
    time_now = toc(t); 
    time_list = time_readings(time_list, time_now);
    
    % Check if full
    tank_state = check_tank_state(empty_tank_dist, full_tank_dist, distance);
    disp("REGULAR OPERATION... DRAINING BATCH TANK") 
    pause(time_step)
    
    if tank_state >= 2 % batch is full
        disp('TANK IS FULL')
        writeDigitalPin(a,brine_valve_pin,1) % close brine valve
        writeDigitalPin(a,feed_valve_pin,1) % close feed valve
        writeDigitalPin(a,batch_valve_pin,1) % open batch valve
        break
    end 
    
    if tank_state == 1 % tank is neither empty nor full, keep recycling
        disp("TANK IS RECYCLING BATCH")
        
        % valves operation
        writeDigitalPin(a,batch_valve_pin,1); % open batch valve
        pause(0.2) % valve delay time
        writeDigitalPin(a,brine_valve_pin,1);% close brine valve
        writeDigitalPin(a,feed_valve_pin,1);% close feed valve
        
        % REGULAR DATA COLLECTION
        conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin);
        [distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin); 
        [flowrate_list, flowrate] = flowrate_reading(a, flowrate_list, flowrate_pin);
        [mass_list, mass] = scale_reading(s, mass_list);

        % Read time
        time_now = toc(t); 
        time_list = time_readings(time_list, time_now);

        % Check if full
        tank_state = check_tank_state(empty_tank_dist, full_tank_dist, distance);
    end    
    
    if tank_state == 0 % tank is empty
        disp("TANK IS EMPTY")
        
        % valves operation
        writeDigitalPin(a,brine_valve_pin,0);% open brine valve
        pause(0.2) % valve delay time
        writeDigitalPin(a,feed_valve_pin,0);% open feed valve
        writeDigitalPin(a,batch_valve_pin,0); % close batch valve
        
        % initialize
        last_flowrate = 0; % ml/min
        time_step_flushing = 0; % sec
        
        while tank_state ~= 2 % during the time that tank is not full
            

            while volume_flushed < flush_tube_volume
                
                writeDigitalPin(a,brine_valve_pin,0);% open brine valve
                pause(0.2)
                writeDigitalPin(a,feed_valve_pin,0);% open feed valve
                writeDigitalPin(a,batch_valve_pin,0); % close batch valve
                
                % start flushing timer
                start_flushing = tic();
                
                % REGULAR DATA COLLECTION
                conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin);
                [distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin); 
                [flowrate_list, current_flowrate] = flowrate_reading(a, flowrate_list, flowrate_pin);
                [mass_list, mass] = scale_reading(s, mass_list);

                % Append time (from first start run) to data list
                time_now =  toc(t);
                time_list = time_readings(time_list, time_now);

                % Calculate for volume flushed in 
                added_volume = volume_step_approx(time_step_flushing, last_flowrate, current_flowrate);
                volume_flushed = volume_flushed + added_volume;
                disp("Volume flushed: " + volume_flushed + "ml")
                last_flowrate = current_flowrate;

                % record flushing time step in one loop
                time_step_flushing = toc(start_flushing);
            end

        
            while volume_flushed >= flush_tube_volume && volume_flushed < flow_loop_volume
                % valves operation
                writeDigitalPin(a,brine_valve_pin,1) % close brine valve
                writeDigitalPin(a,feed_valve_pin, 0) % open feed valve
                writeDigitalPin(a,batch_valve_pin,1) % open batch valve
                
                pause(time_step)
                pause(3)
                disp("FILLING BATCH TANK")
                
                % REGULAR DATA COLLECTION
                conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin);
                [distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin);    
                [flowrate_list, current_flowrate] = flowrate_reading(a, flowrate_list, flowrate_pin);
                [mass_list,mass] = scale_reading(s, mass_list);
                disp("Measured Distance = " + distance + "cm")
                
                % Append time (from first start run) to data list
                time_now = toc(t); 
                time_list = time_readings(time_list, time_now);
                
                % check tank state
                tank_state = check_tank_state(empty_tank_dist, full_tank_dist, distance);
            end
        end
    end
end