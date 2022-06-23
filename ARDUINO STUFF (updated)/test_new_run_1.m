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
perm_flowrate_pin = 'A2';
pressure_transducer_pin = 'A3';


% Setup Arduino and Ultrasonic sensor
a = arduino('COM4', 'Mega2560','Libraries', 'Ultrasonic');
ultrasonicObj = ultrasonic(a,trigger_pin, echo_pin, 'OutputFormat','double');

% Setup Scale (optional since now permeate flowmeter is working!)
if ~isempty(instrfind)
  fclose(instrfind);
  delete(instrfind);
end

s = serial('COM6', 'baudrate', 9600); % scale
 set(s,'Parity', 'none');
 set(s,'DataBits', 8);
 set(s,'StopBit', 1);

fopen(s)

% constants

empty_tank_dist = 25;  % cm, top of the tank to the top of the drainage square with some extra room
full_tank_dist = 22.5 ;  % cm  (CHANGE LATER?)
pause_time = 2; % seconds, waiting time between arduino operations
%flow_loop_volume = 120; % ml, the total amount of water in one batch
flush_tube_volume = 72; % ml, the amount water in the tubes

% empty lists 
time_list = [0];
mass_list = [0];
distance_list = [];
conductivity_list = [];
flowrate_list = [0];
permeate_flowrate_list = [0];
permeate_volume_list = [0];
pres_trans_list = [];
flushed_volume_list = [];

% main code 
times_feed = 0;
run = 1;
t = tic();

% Calculating starting volume
[distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin); 


while run == 1
    
    % REGULAR DATA COLLECTION
    conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin);
    [distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin); 
    [flowrate_list, current_flowrate] = flowrate_reading(a, flowrate_list, flowrate_pin);
    [permeate_flowrate_list, current_permeate_flowrate] = permeate_flowrate_reading(a, permeate_flowrate_list, perm_flowrate_pin);
    [pres_trans_list, pres_trans_value] = pres_trans_reading(a,pres_trans_list,pressure_transducer_pin);
    [mass_list, mass] = scale_reading(s, mass_list);
    
    % Read time
    time_now = toc(t); 
    time_list = time_readings(time_list, time_now);
    
    % Calculate for permeate volume
    [permeate_volume_list, permeate_volume] = integrate_permeate_volume(time_list,permeate_flowrate_list, permeate_volume_list);
    
    % Check if full
    tank_state = check_tank_state(empty_tank_dist, full_tank_dist, distance);
    
    % if tank is full
    if tank_state == 2 
        
        % reset the time that empty state is achieved
        times_feed = 0;
        
        writeDigitalPin(a,feed_valve_pin,1);% close feed valve
        pause(pause_time) % valve delay time
    end
    
    % if tank is neither empty nor full: keep valves at default
    if tank_state == 1
        
        % reset the time that empty state is achieved
        times_feed = 0;
        
        % valves operation
        writeDigitalPin(a,batch_valve_pin,1); % open batch valve
        pause(pause_time) % valve delay time
        writeDigitalPin(a,brine_valve_pin,1);% close brine valve
        pause(pause_time) % valve delay time
        writeDigitalPin(a,feed_valve_pin,1);% close feed valve
        pause(pause_time) % valve delay time
    end
    
    % if tank is empty: open feed valve
    if tank_state == 0
        
         % record times entering this "empty if loop" continuously
        times_feed = times_feed + 1;
        if times_feed > 10 % used to be 1
            run = 0;
        end 
        % tank is empty again, bucket out of water, break the whole loop
        if run == 0
            break
        end
        
        % open feed valve
        writeDigitalPin(a,feed_valve_pin,0);
        pause(pause_time) % valve delay time
        
        % initialize
        last_flowrate = 0; % ml/min
        time_step_flushing = 0; % sec
        volume_flushed = 0; % ml
            
            % tube concentrate is not fully flushed: brine valve open
            if volume_flushed < flush_tube_volume 
            
                % valves operation
                writeDigitalPin(a,brine_valve_pin,0);  % open brine valve
                pause(pause_time) % valve delay time
                writeDigitalPin(a,batch_valve_pin,0); % close batch valve
                pause(pause_time) % valve delay time
                disp("start flushing..OPENED BRINE, CLOSED BATCH")
                
                while volume_flushed < flush_tube_volume && tank_state ~= 2
                    % start flushing timer
                    start_flushing = tic();

                    % REGULAR DATA COLLECTION
                    conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin);
                    [distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin); 
                    [flowrate_list, current_flowrate] = flowrate_reading(a, flowrate_list, flowrate_pin);
                    [permeate_flowrate_list, current_permeate_flowrate] = permeate_flowrate_reading(a, permeate_flowrate_list, perm_flowrate_pin);
                    [pres_trans_list, pres_trans_value] = pres_trans_reading(a,pres_trans_list,pressure_transducer_pin);
                    [mass_list, mass] = scale_reading(s, mass_list);
                
                    % Append time (from first start run) to data list
                    time_now =  toc(t);
                    time_list = time_readings(time_list, time_now);
                        
                    % Calculate for permeate volume
                    [permeate_volume_list, permeate_volume] = integrate_permeate_volume(time_list,permeate_flowrate_list, permeate_volume_list);
                     
                    % Calculate for volume flushed
                    added_volume = volume_step_approx(time_step_flushing, last_flowrate, current_flowrate);
                    volume_flushed = volume_flushed + added_volume;
                    disp("Volume flushed: " + volume_flushed + "ml")
                    last_flowrate = current_flowrate;

                    % record flushing time step in one loop
                    time_step_flushing = toc(start_flushing);

                    % update tank state and stop feed if full
                    tank_state = check_tank_state(empty_tank_dist, full_tank_dist, distance);
                    pause(pause_time)
                    if tank_state == 2
                        writeDigitalPin(a,feed_valve_pin,1);% close feed valve
                        pause(pause_time) % valve delay time
                        break
                    end
                    if volume_flushed >= flush_tube_volume
                        % valves operation
                        writeDigitalPin(a,batch_valve_pin,1) % open batch valve
                        pause(pause_time) % valve delay time
                        writeDigitalPin(a,brine_valve_pin,1) % close brine valve
                        pause(pause_time) % valve delay time
                    end
                 end 
            end
            
            % tube concentrate fully flushed: brine valve closed
            if volume_flushed >= flush_tube_volume
                % valves operation
                writeDigitalPin(a,batch_valve_pin,1) % open batch valve
                pause(pause_time) % valve delay time
                writeDigitalPin(a,brine_valve_pin,1) % close brine valve
                pause(pause_time) % valve delay time
                
                % append flushed volume to a list
                flushed_volume_list(end+1,1) = volume_flushed; 
                
                disp("Flush volume achieved " + flush_tube_volume + "..CLOSED BRINE, OPENED BATCH")
        
                while volume_flushed < flow_loop_volume

                    % REGULAR DATA COLLECTION
                    conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin);
                    [distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin); 
                    [flowrate_list, current_flowrate] = flowrate_reading(a, flowrate_list, flowrate_pin);
                    [permeate_flowrate_list, current_permeate_flowrate] = permeate_flowrate_reading(a, permeate_flowrate_list, perm_flowrate_pin);
                    [pres_trans_list, pres_trans_value] = pres_trans_reading(a,pres_trans_list,pressure_transducer_pin);
                    [mass_list, mass] = scale_reading(s, mass_list);
                    
                    % Append time (from first start run) to data list
                    time_now = toc(t); 
                    time_list = time_readings(time_list, time_now);
                    
                    % Calculate for permeate volume
                    [permeate_volume_list, permeate_volume] = integrate_permeate_volume(time_list,permeate_flowrate_list, permeate_volume_list);
                    
                    % update tank state and stop feed if full
                    tank_state = check_tank_state(empty_tank_dist, full_tank_dist, distance);
                    pause(pause_time)
                    if tank_state == 2
                        disp("TANK FULL")
                        writeDigitalPin(a,feed_valve_pin,1);% close feed valve
                        pause(pause_time) % valve delay time
                        break
                    end
                end    
            end 
    end
end
