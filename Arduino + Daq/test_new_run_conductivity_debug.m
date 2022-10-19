% Entire system code - to stop it, do Ctrl+c

% feed: 1-close, 0-open
% brine: 1-close, 0-open
% batch: 0-close, 1-open

clear
filename = '10-4-data.csv';

% setup pins 
trigger_pin= 'D8';
echo_pin = 'D9';
batch_valve_pin = 'D4';
brine_valve_pin = 'D3';
feed_valve_pin = 'D5';
perm_flowrate_pin = 'A2';

% set up Arduino and Ultrasonic sensor
a = arduino('COM16', 'Mega2560','Libraries', 'Ultrasonic');
ultrasonicObj = ultrasonic(a,trigger_pin, echo_pin, 'OutputFormat','double');

% set up DAQ
daqreset
d = daqlist;
% dq = daq("ni");
dq = daqvendorlist;
Daqtype = d.DeviceID;

ch00ai = addinput(dq,Daqtype,'ai0','Voltage');  % permeate flowrate in Channel AI0(+)
ch00ai.TerminalConfig = 'Differential';
ch01ai = addinput(dq,Daqtype,'ai1','Voltage');  % batch flowrate in Channel AI1(+)
ch01ai.TerminalConfig = 'Differential';
ch02ai = addinput(dq,Daqtype,'ai2','Voltage');  % conductivity in Channel AI2
ch02ai.TerminalConfig = 'Differential';


% constants
%initial_conductivity = input("initial conductivity(mS): ");
end_conductivity = input("batch end conductivity(mS): ");

empty_tank_dist = 24.05;  % cm, top of the tank to the top of the drainage square with some extra room
full_tank_dist = 19.55;  % cm  (CHANGE LATER?)
pause_time = 0.5; % seconds, waiting time between arduino operations
max_flush_distance = 26.5; % cm, ultrasonic sensor measurement of tank waterline that stops flushing


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
        

% data collections
[time_list, distance_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, tank_state] = main_data_collection(empty_tank_dist, full_tank_dist, time_list, a, ultrasonicObj, distance_list, trigger_pin, echo_pin, dq, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, filename,t);
    
% set initial conductivity to be the first value in the list
initial_conductivity = conductivity_list(end);
conductivity_buffer = 0.15 * initial_conductivity;

% set up debug file
debug_file = "debug.csv";
debug_headers = ["Time", "Batch no.", "Process", "Feed open", "Batch open", "Brine open", "Valves correct?"];
%writematrix(debug_headers, debug_file); % adds headers to csv

% define variables for debug file
process = "0";
feed_open = 0;
batch_open = 1;
brine_open = 0;
valves_correct = 0; % shows whether or not the valve states are correct for each process according to the code

expected_valve_states = [0, 0, 0]; % used to check against actual valve states to see if correct valves are open/closed
% create column matricies (probably not needed)
%time_debug_list = [0];
%batch_no_list = [0];
%process_list = [0];
%feed_open_list = [0];
%batch_open_list = [0];
%brine_open_list = [0];
%debug_data_matrix = [time_debug_list, batch_no_list, process_list, feed_open_list, batch_open_list, brine_open_list]

debug_matrix = debug_headers; %; debug_data_matrix]

% debug data collection (don't need this?)
%[time_debug_list, batch_open_list, process_list, feed_open_list, batch_no_list, brine_open_list] = debug_data_collection(debug_file);  

while run == 1
    i = 1;
    % i is used to indicate if the conductivity is low enough for the next
    % batch and if during the feed + flush state brine valve has been
    % closed or not
    
    disp("Batch Number: " + batch_number)
    
    % data collections
    [time_list, distance_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, tank_state] = main_data_collection(empty_tank_dist, full_tank_dist, time_list, a, ultrasonicObj, distance_list, trigger_pin, echo_pin, dq, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, filename,t);


    % tank not empty: maintain normal state
    if(conductivity_list(end) < end_conductivity)&&(tank_state ~= 0)
        writeDigitalPin(a,batch_valve_pin,1); % open batch valve
        batch_open = 1;
        add_debug_row;

        pause(pause_time) % valve delay time
        writeDigitalPin(a,feed_valve_pin,1);% close feed valve
        feed_open = 0;
        add_debug_row;
        
        pause(pause_time) % valve delay time
        writeDigitalPin(a,brine_valve_pin,1);% close brine valve
        brine_open = 0;
        add_debug_row;

        pause(pause_time) % valve delay time
    end
    
    % tank empty: flush -> feed + flush -> feed to full
    if(conductivity_list(end) >= end_conductivity)||tank_state == 0
        
        % flush brine to max low
        if distance_list(end) <= max_flush_distance % if tank level above min level
            % Drain tank water
            writeDigitalPin(a,brine_valve_pin,0);  % open brine valve
            brine_open = 1;
            add_debug_row;

            pause(pause_time) % valve delay time
            writeDigitalPin(a,batch_valve_pin,0); % close batch valve
            batch_open = 0;
            add_debug_row;

            pause(pause_time) % valve delay time
        
            while distance_list(end) <= max_flush_distance % while tank is above min level
                process = "1 - Flushing";
                disp(process)
                
                % data collections
                [time_list, distance_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list,tank_state] = main_data_collection(empty_tank_dist, full_tank_dist, time_list, a, ultrasonicObj, distance_list, trigger_pin, echo_pin, dq, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list,filename,t);
            end    
        end
        
        % Open feed valve, fill the tank to full distance while flushing
        writeDigitalPin(a,brine_valve_pin,0);  % open brine valve
        brine_open = 1;
        add_debug_row;

        pause(pause_time) % valve delay time
        writeDigitalPin(a,batch_valve_pin,0); % close batch valve
        batch_open = 0;
        add_debug_row;

        pause(pause_time) % valve delay time
        writeDigitalPin(a,feed_valve_pin,0); % open feed valve
        feed_open = 1;
        add_debug_row;

        pause(pause_time) % valve delay time
            
        while distance_list(end) > full_tank_dist % while the tank is not full
            if i == 1
                process = "2-Flushing + Feeding";
                disp(process)
            elseif i == 0
                process = "3.1-Finished flushing, still feeding";
                disp(process)
            end 
            % data collections
            [time_list, distance_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, tank_state] = main_data_collection(empty_tank_dist, full_tank_dist, time_list, a, ultrasonicObj, distance_list, trigger_pin, echo_pin, dq, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list,tank_state_list, filename, t);
            if (conductivity_list(end) <= initial_conductivity + conductivity_buffer) && (i == 1) % if conductivity is reset and 
                % Stop flushing when conductivity is reset
                writeDigitalPin(a,batch_valve_pin,1); % open batch valve
                batch_open = 1;
                add_debug_row;

                pause(pause_time) % valve delay time
                writeDigitalPin(a,brine_valve_pin,1);  % close brine valve
                brine_open = 0;
                add_debug_row;

                pause(pause_time) % valve delay time
                process = "3-Stop flushing.";
                disp(process + " Conductivity(mS): " + conductivity_list(end))
                i = 0;
            end  
        end
        
        % Close feed valve
        writeDigitalPin(a,feed_valve_pin,1);
        feed_open = 0;
        add_debug_row;
        pause(pause_time) % valve delay time 
        process = "4-Stop feeding-tank full";
        disp(process)

        % If flushing continues after feeding has finished
        if conductivity_list(end) > initial_conductivity + conductivity_buffer
            writeDigitalPin(a,brine_valve_pin,0);  % open brine valve
            brine_open = 1;
            add_debug_row;

            pause(pause_time) % valve delay time
            writeDigitalPin(a,batch_valve_pin,0); % close batch valve
            batch_open = 0;
            add_debug_row;

            pause(pause_time) % valve delay time
            while conductivity_list(end) > initial_conductivity + conductivity_buffer && distance_list(end) <= max_flush_distance
                process = "4.1-Flushing after tank full";
                disp(process)
                
                % data collections
                [time_list, distance_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list,tank_state] = main_data_collection(empty_tank_dist, full_tank_dist, time_list, a, ultrasonicObj, distance_list, trigger_pin, echo_pin, dq, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list,filename,t);
            end
            
            % stop flushing
            writeDigitalPin(a,batch_valve_pin,1); % open batch valve
            batch_open = 1;
            add_debug_row;
            batch_state = true;

            pause(pause_time) % valve delay time
            writeDigitalPin(a,brine_valve_pin,1);  % close brine valve
            brine_open = 0;
            add_debug_row;

            pause(pause_time) % valve delay time
            
            process = "4.2-Stop flushing after feeding.";
            disp(process + " Conductivity(mS): " + conductivity_list(end))
           
            % Refill the tank if water level is below full distance
            if distance_list(end) > full_tank_dist + 0.3
                % Open feed valve
                writeDigitalPin(a,feed_valve_pin,0);
                feed_open = 1;
                add_debug_row;

                pause(pause_time) % valve delay time
                
                % Check final distance
                while distance_list(end) > full_tank_dist + 0.3
                   process = "4.3-Refeeding";
                   disp(process)
                   [time_list, distance_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list,tank_state] = main_data_collection(empty_tank_dist, full_tank_dist, time_list, a, ultrasonicObj, distance_list, trigger_pin, echo_pin, dq, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list,filename,t);
                end
                % Close feed valve
                writeDigitalPin(a,feed_valve_pin,1);
                feed_open = 0;
                add_debug_row;

                pause(pause_time) % valve delay time
                process = "4.4-Stop feeding-tank full";
                disp(process)
            end
        end
        
        % Display current batch number
        batch_number = batch_number + 1;
        disp("Batch Number: " + batch_number)
    end 
end 

writematrix(debug_matrix, debug_file);

% append debug matrix
function debug_matrix = add_debug_row(debug_matrix)   
    valve_states = [feed_open, batch_open, brine_open];
    if isequal(valve_states, expected_valve_states) == true
        valves_correct = 1;
    else 
        valves_correct = 0;
    end
    debug_matrix = [debug_matrix; [t, batch_number, process, feed_open, batch_open, brine_open, valves_correct]];
end