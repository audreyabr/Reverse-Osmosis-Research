% Entire system code - to stop it, do Ctrl+c
clear

filename = 'live_data.txt';

% setup pins 
trigger_pin= 'D8';
echo_pin = 'D9';
batch_valve_pin = 'D4';
brine_valve_pin = 'D3';
feed_valve_pin = 'D5';
% flowrate_pin = 'A0';
% conductivity_pin = 'A1';
% perm_flowrate_pin = 'A2';
pressure_transducer_pin = 'A3';


% Setup Arduino and Ultrasonic sensor
a = arduino('COM4', 'Mega2560','Libraries', 'Ultrasonic');
ultrasonicObj = ultrasonic(a,trigger_pin, echo_pin, 'OutputFormat','double');

% set up daq
daqreset
d = daqlist;
dq = daq('ni');
Daqtype = d.DeviceID;

ch00ai = addinput(dq,Daqtype,'ai0','Voltage');  % permeate flowrate in Channel AI0(+)
ch00ai.TerminalConfig = 'SingleEnded';
ch01ai = addinput(dq,Daqtype,'ai1','Voltage');  % batch flowrate in Channel AI1(+)
ch01ai.TerminalConfig = 'SingleEnded';
ch02ai = addinput(dq,Daqtype,'ai2','Voltage');  % conductivity in Channel AI2
ch02ai.TerminalConfig = 'Differential';

% Setup Scale (optional since now permeate flowmeter is working!)
if ~isempty(instrfind)
  fclose(instrfind);
  delete(instrfind);
end

s = serialport('COM6', 9600); % scale
 set(s,'Parity', 'none');
 set(s,'DataBits', 8);
 set(s,'StopBit', 1);

fopen(s)
%% 
% constants
empty_tank_dist = 22.3;  % cm, top of the tank to the top of the drainage square with some extra room
full_tank_dist = 21.5;  % cm  (CHANGE LATER?)
pause_time = 0.5; % seconds, waiting time between arduino operations
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

% main code 
run = 1;
t = tic();

% Calculating starting volume
[distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin); 
%%
while run == 1
    % REGULAR DATA COLLECTION
    [conductivity_list,conductivity] = conductivity_reading_daq(dq,conductivity_list);
    [distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin);
    [permeate_flowrate_list, current_permeate_flowrate] = permeate_flowrate_reading_daq(dq, permeate_flowrate_list);
    [flowrate_list, current_flowrate] = flowrate_reading_daq(dq, flowrate_list);
    [pres_trans_list, pres_trans_value] = pres_trans_reading(a,pres_trans_list,pressure_transducer_pin);
    [mass_list, mass] = scale_reading(s, mass_list);
    
    % Read time
    time_now = toc(t); 
    time_list = time_readings(time_list, time_now);
    
    % Save live data
    tobesaved = [time_now, conductivity(1), distance, current_permeate_flowrate, current_flowrate, pres_trans_value, mass]; 
    save(filename,"tobesaved",'-append', '-ascii', '-tabs');
    
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
                    conductivity_list = conductivity_reading_daq(dq,conductivity_list);
                    [distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin); 
                    [permeate_flowrate_list, current_permeate_flowrate] = permeate_flowrate_reading_daq(dq, permeate_flowrate_list);
                    [flowrate_list, current_flowrate] = flowrate_reading_daq(dq, flowrate_list);
                    [pres_trans_list, pres_trans_value] = pres_trans_reading(a,pres_trans_list,pressure_transducer_pin);
                    [mass_list, mass] = scale_reading(s, mass_list);
                
                    % Append time (from first start run) to data list
                    time_now =  toc(t);
                    time_list = time_readings(time_list, time_now);
                    
                    % Save live data
                    tobesaved = [time_now, distance,current_permeate_flowrate,current_flowrate,pres_trans_value,mass]; 
                    save(filename,"tobesaved",'-append', '-ascii', '-tabs');
                        
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
                pause(pause_time) % valve delay time

                disp("Flush volume achieved " + flush_tube_volume + "..CLOSED BRINE, OPENED BATCH")
            end
    end 
end 