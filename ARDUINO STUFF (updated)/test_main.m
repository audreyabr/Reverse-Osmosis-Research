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

empty_tank_dist = 14;  % cm, top of the tank to the top of the drainage square with some extra room
full_tank_dist = 10 ;  % cm  (CHANGE LATER?)
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
batch_tank_volume = Water_Tank_Calculations(29.845-distance);

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
  
end