% Entire system code - to stop it, do Ctrl+c

% feed: 1-close, 0-open
% brine: 1-close, 0-open
% batch: 0-close, 1-open

clear
filename = '10-28-data0048.csv';

% setup pins 
trigger_pin= 'D8';
echo_pin = 'D9';
batch_valve_pin = 'D4';
brine_valve_pin = 'D3';
feed_valve_pin = 'D5';
perm_flowrate_pin = 'A2';

% set up Arduino and Ultrasonic sensor
a = arduino('COM6', 'Mega2560','Libraries', 'Ultrasonic');
ultrasonicObj = ultrasonic(a,trigger_pin, echo_pin, 'OutputFormat','double');

% set up DAQ
daqreset
d = daqlist;
dq = daq("ni");
%dq = daqvendorlist;
Daqtype = d.DeviceID;

ch00ai = addinput(dq,Daqtype,'ai0','Voltage');  % permeate flowrate in Channel AI0(+)
ch00ai.TerminalConfig = 'Differential';
ch01ai = addinput(dq,Daqtype,'ai1','Voltage');  % batch flowrate in Channel AI1(+)
ch01ai.TerminalConfig = 'Differential';
ch02ai = addinput(dq,Daqtype,'ai2','Voltage');  % conductivity in Channel AI2
ch02ai.TerminalConfig = 'Differential';

%%
%CONSTANTS
%initial_conductivity = input("initial conductivity(mS): ");
%end_conductivity = input("batch end conductivity(mS): ");
RR = input("Recovery Rate (decimal): ");

empty_tank_dist = 24.39;  % cm, top of the tank to the top of the drainage square with some extra room
full_tank_dist = 20;  % cm  (CHANGE LATER?)
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
    
% set initial and end conductivity
initial_conductivity = conductivity_list(end);% first conductivity reading
end_conductivity = initial_conductivity * (1/ (1 -RR)); % end conductivity calculated with init_condu and RR
conductivity_buffer = 0.15 * initial_conductivity; % 15% buffer rate for later batches' initial conductivity

%%
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
        pause(pause_time) % valve delay time
        writeDigitalPin(a,feed_valve_pin,1);% close feed valve
        pause(pause_time) % valve delay time
        writeDigitalPin(a,brine_valve_pin,1);% close brine valve
        pause(pause_time) % valve delay time
    end
    
    % tank empty: flush -> feed + flush -> feed to full
    if(conductivity_list(end) >= end_conductivity)||tank_state == 0
        
        % flush brine to max low
        if distance_list(end) <= max_flush_distance % if tank level above min level
            % Drain tank water
            writeDigitalPin(a,brine_valve_pin,0);  % open brine valve
            pause(pause_time) % valve delay time
            writeDigitalPin(a,batch_valve_pin,0); % close batch valve
            pause(pause_time) % valve delay time
        
            while distance_list(end) <= max_flush_distance % while tank is above min level
                disp("1-Flushing")
                
                % data collections
                [time_list, distance_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list,tank_state] = main_data_collection(empty_tank_dist, full_tank_dist, time_list, a, ultrasonicObj, distance_list, trigger_pin, echo_pin, dq, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list,filename,t);
            end    
        end
        
        % Open feed valve, fill the tank to full distance while flushing
        writeDigitalPin(a,brine_valve_pin,0);  % open brine valve
        pause(pause_time) % valve delay time
        writeDigitalPin(a,batch_valve_pin,0); % close batch valve
        pause(pause_time) % valve delay time
        writeDigitalPin(a,feed_valve_pin,0); % open feed valve
        pause(pause_time) % valve delay time
            
        while distance_list(end) > full_tank_dist % while the tank is not full
            if i == 1
                disp("2-Flushing + Feeding")
            elseif i == 0
                disp("3.1-Finished flushing, still feeding")
            
            end 
            % data collections
            [time_list, distance_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, tank_state] = main_data_collection(empty_tank_dist, full_tank_dist, time_list, a, ultrasonicObj, distance_list, trigger_pin, echo_pin, dq, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list,tank_state_list, filename, t);
            if (conductivity_list(end) <= initial_conductivity + conductivity_buffer) && (i == 1) % if conductivity is reset and 
                % Stop flushing when conductivity is reset
                writeDigitalPin(a,batch_valve_pin,1); % open batch valve
                pause(pause_time) % valve delay time
                writeDigitalPin(a,brine_valve_pin,1);  % close brine valve
                pause(pause_time) % valve delay time
                disp("3-Stop flushing. Conductivity(mS): " + conductivity_list(end))
                i = 0;
            end  
        end
        
        % Close feed valve
        writeDigitalPin(a,feed_valve_pin,1);
        pause(pause_time) % valve delay time 
        disp("4-Stop feeding-tank full")

        % If flushing continues after feeding has finished
        if conductivity_list(end) > initial_conductivity + conductivity_buffer
            writeDigitalPin(a,brine_valve_pin,0);  % open brine valve
            pause(pause_time) % valve delay time
            writeDigitalPin(a,batch_valve_pin,0); % close batch valve
            pause(pause_time) % valve delay time
            while conductivity_list(end) > initial_conductivity + conductivity_buffer && distance_list(end) <= max_flush_distance
                disp("4.1-Flushing after tank full")
                
                % data collections
                [time_list, distance_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list,tank_state] = main_data_collection(empty_tank_dist, full_tank_dist, time_list, a, ultrasonicObj, distance_list, trigger_pin, echo_pin, dq, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list,filename,t);
            end
            
            % stop flushing
            writeDigitalPin(a,batch_valve_pin,1); % open batch valve
            pause(pause_time) % valve delay time
            writeDigitalPin(a,brine_valve_pin,1);  % close brine valve
            pause(pause_time) % valve delay time
            
            disp("4.2-Stop flushing after feeding. Conductivity(mS): " + conductivity_list(end))
           
            
            % Refill the tank if water level is below full distance
            if distance_list(end) > full_tank_dist + 0.3
                % Open feed valve
                writeDigitalPin(a,feed_valve_pin,0);
                pause(pause_time) % valve delay time
                
                % Check final distance
                while distance_list(end) > full_tank_dist + 0.3
                   disp("4.3-Refeeding")
                   [time_list, distance_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list,tank_state] = main_data_collection(empty_tank_dist, full_tank_dist, time_list, a, ultrasonicObj, distance_list, trigger_pin, echo_pin, dq, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list,filename,t);
                end
                % Close feed valve
                writeDigitalPin(a,feed_valve_pin,1);
                pause(pause_time) % valve delay time
                disp("4.4-Stop feeding-tank full")
            end
        end
        
        % Display current batch number
        batch_number = batch_number + 1;
        disp("Batch Number: " + batch_number)
    end 
end 
