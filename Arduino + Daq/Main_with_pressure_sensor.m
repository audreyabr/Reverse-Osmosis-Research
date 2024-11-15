% Entire system code - to stop it, do Ctrl+c

% feed: 1-close, 0-open
% brine: 1-close, 0-open
% batch: 0-close, 1-open

clear
filename = '3-30-test.csv';

% setup pins 
trigger_pin= 'D8';
echo_pin = 'D9';
batch_valve_pin = 'D4';
brine_valve_pin = 'D3';
feed_valve_pin = 'D5';
perm_flowrate_pin = 'A2';

% set up Arduino
a = arduino('COM6', 'Mega2560'); % COM6 for lab laptop

% set up DAQ
daqreset
d = daqlist;
dq = daq("ni");
Daqtype = d.DeviceID;

ch00ai = addinput(dq,Daqtype,'ai0','Voltage');  % permeate flowrate in Channel AI0(+)
ch00ai.TerminalConfig = 'Differential';
ch01ai = addinput(dq,Daqtype,'ai1','Voltage');  % batch flowrate in Channel AI1(+)
ch01ai.TerminalConfig = 'Differential';
ch02ai = addinput(dq,Daqtype,'ai2','Voltage');  % conductivity in Channel AI2
ch02ai.TerminalConfig = 'Differential';
ch03ai = addinput(dq,Daqtype,'ai3','Voltage');  % pressure in Channel AI3
ch03ai.TerminalConfig = 'Differential';

%%
%CONSTANTS
RR = 0.8;
empty_tank_volume = 2.03; % mL
full_tank_volume = 1115.5;  % mL
pause_time = 0.5; % seconds, waiting time between arduino operations
max_flush_volume = 2; % mL,pressure sensor measurement of tank volume that stops flushing
end_concentration = 0.024; % M (molar!)


% initialize
time_list = [0];
tank_volume_list = [0];
conductivity_list = [0];
flowrate_list = [0];
permeate_flowrate_list= [0];
permeate_volume_list = [0];
flushed_volume_list = [0];
tank_state_list = [0];
batch_number = 1;
email = 0;

% main code 
run = 1;
t = tic();
disp("Batch Number: " + batch_number)
        

% data collections
[time_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, tank_volume_list] = main_data_collection(dq, time_list, tank_volume_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, filename,t, empty_tank_volume, full_tank_volume);

% email if something breaks
[email] = send_email(flowrate_list, email);

% set initial and end conductivity
initial_conductivity = conductivity_list(end);% first conductivity reading
initial_concentration = condu_concen_converter(initial_conductivity,"conductivity"); % M (molar)
% end_concentration = initial_concentration * (1/ (1 -RR)); % end concentration calculated with init_condu and RR
end_conductivity = condu_concen_converter(end_concentration,"concentration"); % mS/cm
conductivity_buffer = 0.1 * initial_conductivity; % 10% buffer rate for later batches' initial conductivity

%%
while run == 1
    i = 1;
    % i is used to indicate if the conductivity is low enough for the next
    % batch and if during the feed + flush state brine valve has been
    % closed or not
    
    disp("Batch Number: " + batch_number)
    disp("tank vol = " + tank_volume_list(end))
    disp("condu = " + conductivity_list(end))
    
    % data collections
    [time_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, tank_volume_list] = main_data_collection(dq, time_list, tank_volume_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, filename,t, empty_tank_volume, full_tank_volume);

    % email if something breaks
    [email] = send_email(flowrate_list, email);
    
    disp(conductivity_list(end))
    % tank not empty: maintain normal state
    if(conductivity_list(end) < end_conductivity)&&(tank_state_list(end) ~= 0)
        writeDigitalPin(a,batch_valve_pin,1); % open batch valve
        pause(pause_time) % valve delay time
        writeDigitalPin(a,feed_valve_pin,1);% close feed valve
        pause(pause_time) % valve delay time
        writeDigitalPin(a,brine_valve_pin,1);% close brine valve
        pause(pause_time) % valve delay time
    end
    
    % tank empty: flush -> feed + flush -> feed to full
    if(conductivity_list(end) >= end_conductivity)||tank_state_list(end) == 0
        disp(conductivity_list(end))
         
        % flush brine to max low
        if tank_volume_list(end) >= max_flush_volume % if tank level above min level
            % Drain tank water
            writeDigitalPin(a,brine_valve_pin,0);  % open brine valve
            pause(pause_time) % valve delay time
            writeDigitalPin(a,batch_valve_pin,0); % close batch valve
            pause(pause_time) % valve delay time
        
            while tank_volume_list(end) >= max_flush_volume % while tank is above min level
                disp("1-Flushing")
                disp(conductivity_list(end))
                % data collections
                [time_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, tank_volume_list] = main_data_collection(dq, time_list, tank_volume_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, filename,t, empty_tank_volume, full_tank_volume);

                % email if something breaks
                [email] = send_email(flowrate_list, email);
            end    
        end
        
        % Open feed valve, fill the tank to full volume while flushing
        writeDigitalPin(a,brine_valve_pin,0);  % open brine valve
        pause(pause_time) % valve delay time
        writeDigitalPin(a,batch_valve_pin,0); % close batch valve
        pause(pause_time) % valve delay time
        writeDigitalPin(a,feed_valve_pin,0); % open feed valve
        pause(pause_time) % valve delay time
            
        while tank_volume_list(end) < full_tank_volume % while the tank is not full
            if i == 1
                disp("2-Flushing + Feeding")
                disp(conductivity_list(end))
            elseif i == 0
                disp("3.1-Finished flushing, still feeding")
                disp(conductivity_list(end))
            end 
            % data collections
            [time_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, tank_volume_list] = main_data_collection(dq, time_list, tank_volume_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, filename,t, empty_tank_volume, full_tank_volume);

            % email if something breaks
            [email] = send_email(flowrate_list, email);
            
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
            while conductivity_list(end) > initial_conductivity + conductivity_buffer && tank_volume_list(end) >= max_flush_volume
                disp("4.1-Flushing after tank full")
                disp(conductivity_list(end))
                % data collections
                [time_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, tank_volume_list] = main_data_collection(dq, time_list, tank_volume_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, filename,t, empty_tank_volume, full_tank_volume);

                % email if something breaks
                [email] = send_email(flowrate_list, email);
            end
            
            % stop flushing
            writeDigitalPin(a,batch_valve_pin,1); % open batch valve
            pause(pause_time) % valve delay time
            writeDigitalPin(a,brine_valve_pin,1);  % close brine valve
            pause(pause_time) % valve delay time
            
            disp("4.2-Stop flushing after feeding. Conductivity(mS): " + conductivity_list(end))
            disp(conductivity_list(end))
            
            % Refill the tank if water level is below full volume
            if tank_volume_list(end) < full_tank_volume
                % Open feed valve
                writeDigitalPin(a,feed_valve_pin,0);
                pause(pause_time) % valve delay time
                
                % Check final volume
                while tank_volume_list(end) < full_tank_volume
                    disp("4.3-Refeeding")
                    disp(conductivity_list(end))
                    % data collections
                    [time_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, tank_volume_list] = main_data_collection(dq, time_list, tank_volume_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, filename,t, empty_tank_volume, full_tank_volume);

                    % email if something breaks
                    [email] = send_email(flowrate_list, email);     
                end
                % Close feed valve
                writeDigitalPin(a,feed_valve_pin,1);
                pause(pause_time) % valve delay time
                disp("4.4-Stop feeding-tank full")
                disp(conductivity_list(end))
            end
        end
        
        % Display current batch number
        batch_number = batch_number + 1;
        disp("Batch Number: " + batch_number)
    end 

end 
