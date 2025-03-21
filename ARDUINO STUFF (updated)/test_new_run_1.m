% Entire system code - to stop it, do Ctrl+c
clear

%filename = 'live_data.txt';

% setup pins 
trigger_pin= 'D8';
echo_pin = 'D9';
batch_valve_pin = 'D4';
brine_valve_pin = 'D3';
feed_valve_pin = 'D5';
flowrate_pin = 'A0';
perm_flowrate_pin = 'A2';
conductivity_pin_pos = 'A3';
conductivity_pin_neg = 'A4';

% Setup Arduino and Ultrasonic sensor
a = arduino('COM5', 'Mega2560','Libraries', 'Ultrasonic');
ultrasonicObj = ultrasonic(a,trigger_pin, echo_pin, 'OutputFormat','double');

% declare pin mode

% Setup Scale (optional since now permeate flowmeter is working!)
if ~isempty(instrfind)
  fclose(instrfind);
  delete(instrfind);
end

s = serial('COM13', 'baudrate', 9600); % scale
 set(s,'Parity', 'none');
 set(s,'DataBits', 8);
 set(s,'StopBit', 1);

fopen(s)
%% 
% constants
empty_tank_dist = 25;  % cm, top of the tank to the top of the drainage square with some extra room
full_tank_dist = 22.5 ;  % cm  (CHANGE LATER?)
pause_time = 2; % seconds, waiting time between arduino operations
flow_loop_volume = 120; % ml, the total amount of water in one batch
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
run = 1;
t = tic();

% Calculating starting volume
[distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin); 
%%
while run == 1
    %tobesaved = [distance_list,conductivity_list,permeate_flowrate_list,flowrate_list]; 
    %save(filename,"tobesaved",'-ascii','-tabs');

    % REGULAR DATA COLLECTION
    conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin_pos, conductivity_pin_neg);
    [distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin); 
    [flowrate_list, current_flowrate] = flowrate_reading(a, flowrate_list, flowrate_pin);
    [permeate_flowrate_list, current_permeate_flowrate] = permeate_flowrate_reading(a, permeate_flowrate_list, perm_flowrate_pin);
    [mass_list, mass] = scale_reading(s, mass_list);
    
    % Read time
    time_now = toc(t); 
    time_list = time_readings(time_list, time_now);
    
    % Calculate for permeate volume
    [permeate_volume_list, permeate_volume] = integrate_permeate_volume(time_list,permeate_flowrate_list, permeate_volume_list);
    
    % Check if full
    tank_state = check_tank_state(empty_tank_dist, full_tank_dist, distance);
    
    % if tank is not empty: maintain normal state
    if tank_state ~= 0
        writeDigitalPin(a,feed_valve_pin,1);% close feed valve
        pause(pause_time) % valve delay time
        writeDigitalPin(a,batch_valve_pin,1); % open batch valve
        pause(pause_time) % valve delay time
        writeDigitalPin(a,brine_valve_pin,1);% close brine valve
        pause(pause_time) % valve delay time
    end
    
    % if tank is empty: open feed valve
    if tank_state == 0
        
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
                
                % flushing loop
                while volume_flushed < flush_tube_volume
                    % start flushing timer
                    start_flushing = tic();

                    % REGULAR DATA COLLECTION
                    conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin_pos, conductivity_pin_neg);
                    [distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin); 
                    [flowrate_list, current_flowrate] = flowrate_reading(a, flowrate_list, flowrate_pin);
                    [permeate_flowrate_list, current_permeate_flowrate] = permeate_flowrate_reading(a, permeate_flowrate_list, perm_flowrate_pin);
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
                    end
                end
            end 
                    
            % stop flushing
            if volume_flushed >= flush_tube_volume
                % valves operation
                writeDigitalPin(a,batch_valve_pin,1) % open batch valve
                pause(pause_time) % valve delay time
                writeDigitalPin(a,brine_valve_pin,1) % close brine valve
                pause() % valve delay time

                disp("Flush volume achieved " + flush_tube_volume + "..CLOSED BRINE, OPENED BATCH")
            end
    end 
end 
