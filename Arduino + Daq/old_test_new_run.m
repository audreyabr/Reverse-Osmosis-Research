% Entire system code - to stop it, do Ctrl+c
clear

filename = 'live_data_8-3.csv';

% setup pins 
trigger_pin= 'D8';
echo_pin = 'D9';
batch_valve_pin = 'D4';
brine_valve_pin = 'D3';
feed_valve_pin = 'D5';
perm_flowrate_pin = 'A2';

% set up Arduino and Ultrasonic sensor
a = arduino('COM5', 'Mega2560','Libraries', 'Ultrasonic');
ultrasonicObj = ultrasonic(a,trigger_pin, echo_pin, 'OutputFormat','double');

% set up DAQ
daqreset
d = daqlist;
dq = daq('ni');
Daqtype = d.DeviceID;

ch00ai = addinput(dq,Daqtype,'ai0','Voltage');  % permeate flowrate in Channel AI0(+)
ch00ai.TerminalConfig = 'Differential';
ch01ai = addinput(dq,Daqtype,'ai1','Voltage');  % batch flowrate in Channel AI1(+)
ch01ai.TerminalConfig = 'Differential';
ch02ai = addinput(dq,Daqtype,'ai2','Voltage');  % conductivity in Channel AI2
ch02ai.TerminalConfig = 'Differential';

%%
% constants
initial_conductivity = input("initial conductivity(mS): ");
conductivity_buffer = 0.1 * initial_conductivity;
empty_tank_dist = 25.1703;  % cm, top of the tank to the top of the drainage square with some extra room
full_tank_dist = 20.7516;  % cm  (CHANGE LATER?)
pause_time = 0.5; % seconds, waiting time between arduino operations
max_flush_volume = 100; % ml, max amount to be flushed if conductivity does not reset

% initialize
time_list = [0];
distance_list = [0];
conductivity_list = [0];
flowrate_list = [0];
permeate_flowrate_list= [0];
permeate_volume_list = [0];
flushed_volume_list = [0];
batch_number = 1;
tank_state_list = [0];


% main code 
run = 1;
t = tic();
disp("Batch Number: " + batch_number)
        
 
%%
while run == 1
    disp("Batch Number: " + batch_number)
    
    % REGULAR DATA COLLECTION
    [distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin);
    [permeate_flowrate_list, current_permeate_flowrate, flowrate_list, current_flowrate, conductivity_list, conductivity] = daq_reading(dq, permeate_flowrate_list, flowrate_list, conductivity_list);
    disp("permeate flowrate(mL/min): " + current_permeate_flowrate)
    
    % Read time
    time_now = toc(t); 
    time_list = time_readings(time_list, time_now);
    
    % Calculate for permeate volume
    [permeate_volume_list, permeate_volume] = integrate_permeate_volume(time_list,permeate_flowrate_list, permeate_volume_list);
    
    % Check if full
    tank_state = check_tank_state(empty_tank_dist, full_tank_dist, distance);
    tank_state_list(end+1,1) = tank_state;
    
    % Save live data
    tobesaved = [time_list, conductivity_list, distance_list, permeate_flowrate_list, flowrate_list, permeate_volume_list, tank_state_list]; 
    csvwrite(filename, tobesaved);

    %if tank is not empty: maintain normal state
    if tank_state ~= 0
        writeDigitalPin(a,batch_valve_pin,1); % open batch valve
        pause(pause_time) % valve delay time
        writeDigitalPin(a,feed_valve_pin,1);% close feed valve
        pause(pause_time) % valve delay time
        writeDigitalPin(a,brine_valve_pin,1);% close brine valve
        pause(pause_time) % valve delay time
    end
    
    % if tank is empty: open feed valve
    if tank_state == 0
        
        % open feed valve
        writeDigitalPin(a,feed_valve_pin,0);
        pause(pause_time) % valve delay time
        
        % Display current batch number
        batch_number = batch_number + 1;
        disp("Batch Number: " + batch_number)
        
        % open feed valve
        writeDigitalPin(a,feed_valve_pin,0);
        pause(pause_time) % valve delay time
        
        % initialize
        last_flowrate = 0; % ml/min
        time_step_flushing = 0; % sec
        volume_flushed = 0; % ml
            
        % tube concentrate is not fully flushed: brine valve open
        if volume_flushed < max_flush_volume
            
            % valves operation
            writeDigitalPin(a,brine_valve_pin,0);  % open brine valve
            pause(pause_time) % valve delay time
            writeDigitalPin(a,batch_valve_pin,0); % close batch valve
            pause(pause_time) % valve delay time
            disp("start flushing..OPENED BRINE, CLOSED BATCH")

            % flushing loop: stop when conductivity is smaller or equal to initial
            % max flush = max_flush_volume
            while volume_flushed <= max_flush_volume
                disp("Batch Number: " + batch_number)
                
                % start flushing timer
                start_flushing = tic();

                % REGULAR DATA COLLECTION
                [distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin);
                [permeate_flowrate_list, current_permeate_flowrate, flowrate_list, current_flowrate, conductivity_list, conductivity] = daq_reading(dq, permeate_flowrate_list, flowrate_list, conductivity_list);
                disp("permeate flowrate(ml/min): " + current_permeate_flowrate)
                
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
                tank_state_list(end+1,1) = tank_state;

                % Save live data
                tobesaved = [time_list, conductivity_list, distance_list, permeate_flowrate_list, flowrate_list, permeate_volume_list, tank_state_list]; 
                csvwrite(filename, tobesaved);
                    
                % ready to stop flush when average of 10 latest conductivity values
                % prove to be reset to initial
                if conductivity <= initial_conductivity + conductivity_buffer
                    break
                end
            end
                    
            % stop flushing
            writeDigitalPin(a,batch_valve_pin,1) % open batch valve
            pause(1) % valve delay time
            writeDigitalPin(a,brine_valve_pin,1) % close brine valve
            pause(pause_time) % valve delay time

            disp("Flush volume achieved " + max_flush_volume + "..CLOSED BRINE, OPENED BATCH")
        end 
    end 
end 