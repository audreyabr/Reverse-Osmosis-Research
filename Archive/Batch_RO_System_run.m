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
%took_scale_data = 0; % this helps with the scale data collecting
flow_loop_volume = 150; % ml, the total amount of water in one batch

% empty lists 
rows = [];
time_list = [];
mass_list = [];
distance_list = [];
current_distance_list = [];
conductivity_list = [];
flowrate_list = [];
perm_flowrate_list = [];
pres_trans_list = [];

% main code 
run = 1;
t = tic();  

while run == 1

% REGULAR DATA COLLECTION:
conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin);
[distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin); 
[flowrate_list, current_flowrate] = flowrate_reading(a, flowrate_list, flowrate_pin);
[perm_flowrate_list, perm_flowrate] = permeate_flowrate_reading(a, perm_flowrate_list, perm_flowrate_pin);
[pres_trans_list, pres_trans_value] = pres_trans_reading(a,pres_trans_list,pressure_transducer_pin);
[mass_list, mass] = scale_reading(s, mass_list);

% Read time
time_now = toc(t); 
time_list = time_readings(time_list, time_now);

% Check if full
tank_state = check_tank_state(empty_tank_dist,full_tank_dist,distance);
disp("REGULAR OPERATION... DRAINING BATCH TANK") 
pause(time_step)

elapsed_time = 0;
brine_valve_open = 0; 


    if tank_state == 0 % if batch tank is "empty"

        volume_flushed = 0; 
        last_flowrate = 0; 
        time_step_flushing = 1;
            
        disp("New time is starting soon!")
        
        while volume_flushed < flow_loop_volume && tank_state ~= 2
            % Fill the tank and drain the brine until 72 ml has been flushed or the tank is "full" 
            
            % start new timer
            time_then = tic();

            % DATA COLLECTION
            conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin);
            [distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin); 
            [flowrate_list, current_flowrate] = flowrate_reading(a, flowrate_list, flowrate_pin);
            [perm_flowrate_list, perm_flowrate] = permeate_flowrate_reading(a, perm_flowrate_list, perm_flowrate_pin);
            [pres_trans_list, pres_trans_value] = pres_trans_reading(a,pres_trans_list,pressure_transducer_pin);
            [mass_list, mass] = scale_reading(s, mass_list);

            
            time_now = toc(t); 
            time_list = time_readings(time_list, time_now);

            % Calculate for volume flushed in 
            added_volume = volume_step_approx(time_step_flushing, last_flowrate, current_flowrate);
            volume_flushed = volume_flushed + added_volume;
            disp("Volume flushed: " + volume_flushed + "ml")
            last_flowrate = current_flowrate;

            pause(time_step)

            disp("FLUSHING... WAITING TO FLUSH 150 ml FROM FLOW LOOP")

            Brine_valve_open = 1;
            writeDigitalPin(a,brine_valve_pin,0);% relay is ON, so brine valve is open
            pause(0.2)
            writeDigitalPin(a,feed_valve_pin,0);% relay is ON, so feed valve is open
            writeDigitalPin(a,batch_valve_pin,0); % relay is ON, so batch valve is closed

            time_now = toc(time_then); 
            time_step_flushing = time_now; 

            if  volume_flushed >= 72&&tank_state ~= 2
                while tank_state ~= 2
                % After 9 seconds of draining, close Brine valve,
                % open Batch valve and resume regular filling until tank is
                % full

                    pause(time_step)
                    pause(3)
                    disp("FILLING BATCH TANK")
                    
                    conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin);
                    [distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin); 
                    [flowrate_list, current_flowrate] = flowrate_reading(a, flowrate_list, flowrate_pin);
                    [perm_flowrate_list, perm_flowrate] = permeate_flowrate_reading(a, perm_flowrate_list, perm_flowrate_pin);
                    [pres_trans_list, pres_trans_value] = pres_trans_reading(a,pres_trans_list,pressure_transducer_pin);
                    [mass_list, mass] = scale_reading(s, mass_list);


                    tank_state = check_tank_state(empty_tank_dist, full_tank_dist, distance);

                    disp("Measured Distance = " + distance)
                    writeDigitalPin(a,batch_valve_pin,1) % batch valve is open 
                    % batch valve 0 is close and 1 is open
                    writeDigitalPin(a,brine_valve_pin,1) % brine valve is closed
                    % brine valve 0 is open 1 is close
                    % feed valve 0 is open 1 is close
                    Brine_valve_open = 0;
                    disp('THIS IS THE SPOT WHERE IT CRASHES')
                    

                    if tank_state == 2
                        disp('BREAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAK')
                        break 
                    end
                end
            end
        end
    end   
end