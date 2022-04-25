% entire system code
clear all
% setup pins 
trigger_pin= 'D1';
echo_pin = 'D2';
batch_valve_pin = 'D3';
brine_valve_pin = 'D4';
feed_valve_pin = 'D5';
flowrate_pin = 'A0';
conductivity_pin = 'A1';

% Setup Arduino and Ultrasonic sensor

a = arduino('COM8', 'Mega2560')
ultrasonicObj = ultrasonic(a,triggerPin, echoPin, 'OutputFormat','double')

% Setup Scale
if ~isempty(instrfind)
  fclose(instrfind);
  delete(instrfind);
end
s = serial('COM7', 'baudrate', 9600) % scale
 set(s,'Parity', 'none');
 set(s,'DataBits', 8);
 set(s,'StopBit', 1);

 fopen(s)

% constants

empty_tank_dist = 21  % cm, top of the tank to the top of the drainage square with some extra room 
full_tank_dist = 18  % cm  (CHANGE LATER?)
time_step = 0.50 % seconds (this is not actually the real time step between data points)
took_scale_data = 0 % this helps with the scale data collecting
flow_loop_volume = 150 % ml

% empty lists 

rows = []
time_list = []
mass_list = []
distance_list = []
current_distance_list = []
conductivity_list = []
flowrate_list = []

% main code 

run = 1;
t = tic();  

while run == 1

% REGULAR DATA COLLECTION:
conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin)
[distance_list, distance] = distance_reading(arduino_object, distance_list, trigger_pin, echo_pin)    
[flowrate_list, flowrate] = flowrate_reading(arduino_object, flowrate_list, flowrate_pin)  
[mass_list,mass] = scale_reading(s, mass_list)

time_now = toc(t); 
time_list = time_readings(time_list, time_now)

tank_is_empty = check_tank_empty(empty_tank_distance, distance)
tank_is_full = check_tank_full(full_tank_distance, distance)
disp("REGULAR OPERATION... DRAINING BATCH TANK") 
pause(time_step)

elapsed_time = 0
brine_valve_open = 0 

if tank_is_empty == 1
    
    volume_flushed = 0 
    last_flowrate = 0 
    time_step_flushing = 1
    print("TANK IS EMPTY")
    
    while volume_flushed < flow_loop_volume && tank_is_full == 0
        time_then = tic()
        
        % DATA COLLECTION
        conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin)
        [distance_list, distance] = distance_reading(a, distance_list, trigger_pin, echo_pin)    
        [flowrate_list, current_flowrate] = flowrate_reading(a, flowrate_list, flowrate_pin)  
        [mass_list,mass] = scale_reading(s, mass_list)
        time_now = toc(t); 
        time_list = time_readings(time_list, time_now)
           
        added_volume = volume_step_approx(time_step_flushing, last_flowrate, current_flowrate)
        volume_flushed = volume_flushed + added volume;
        disp("Volume flushed: " + volume_flushed + "ml")
        last_flowrate == current flowrate;
        
        delay(time_step)
        
        print("FLUSHING... WAITING TO FLUSH 150 ml FROM FLOW LOOP")
        
        writeDigitalPin(a,batch_valve_pin,0); % batch valve is open
        Brine_valve_open = 1
        writeDigitalPin(a,brine_valve_pin,0);% brine valve is open
        writeDigitalPin(a,feed_valve_pin,0);% feed valve is open
        
        time_now = toc(time_then); 
        time_step_flushing == time_now - time_then; 
        
        else 
            while volume_flushed >= 72
                delay(time_step)
                disp("FILLING BATCH TANK")
                 conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin)
                [distance_list, distance] = distance_reading(a, distance_list, trigger_pin, echo_pin)    
                [flowrate_list, current_flowrate] = flowrate_reading(a, flowrate_list, flowrate_pin)  
                [mass_list,mass] = scale_reading(s, mass_list)
                time_now = toc(t); 
                time_list = time_readings(time_list, time_now)
                
                tank_is_full = check_tank_full(full_tank_distance, distance)
                
                disp("Measured Distance = " + distance)
                
                writeDigitalPin(a,brine_valve_pin,1) % Brine valve is closed 
                Brine_valve_open = 0 
                writeDigitalPin(a,batch_valve_pin,1) % Batch valve is open 
                
                if tank_is_full == 1
                    break 
                end 
                
            end
    end
end

% if tank_is_full == 1
%     writeDigitalPin(a,feed_valve_pin,1) % feed valve is closed 
%     print("TANK IS FULL")
%     conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin)
%     [distance_list, distance] = distance_reading(a, distance_list, trigger_pin, echo_pin)    
%     [flowrate_list, current_flowrate] = flowrate_reading(a, flowrate_list, flowrate_pin)  
%     % (insert scale reading)
%     time_now = toc(t); 
%     time_list = time_readings(time_list, time_now)
% 
%     if Brine_valve_open ==1
%         disp("FLUSHING....WAITING 9 SECOND")
%         delay(9)
%         conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin)
%         [distance_list, distance] = distance_reading(a, distance_list, trigger_pin, echo_pin)    
%         [flowrate_list, current_flowrate] = flowrate_reading(a, flowrate_list, flowrate_pin)  
%         % (insert scale reading)
%         time_now = toc(t); 
%         time_list = time_readings(time_list, time_now)
%         
%         writeDigitalPin(a,brine_valve_pin,1) % brine valve is closed 
%         Brine_valve_open = 0 
%         
%         writeDigitalPin(a,batch_valve_pin,1) % batch valve is open 
%         Batch_valve_open = 1
%         
%     end 

end            
        




