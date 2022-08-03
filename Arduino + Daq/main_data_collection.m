function [time_list, distance_list, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list,tank_state] = main_data_collection(empty_tank_dist, full_tank_dist, time_list, a, ultrasonicObj, distance_list, trigger_pin, echo_pin, dq, permeate_flowrate_list, flowrate_list, conductivity_list, permeate_volume_list, tank_state_list,filename,t)
% main_data_measuring function combines functions including distance_reading,
% daq_reading, time_readings, integrate_permeate_volume, check_tank_state.
% It reads data from both Arduino and DAQ, displays current permeate
% flowrate, calculates accumulative permeate volume, check tank state, and
% save all data lists in csv file.
%
% Inputs: 
%   empty_tank_dist, full_tank_dist: Ultrasonic measurements of tank distance setting for every batch
%   time_list, distance_list, permeate_flowrate_list, flowrate_list,
%   conductivity_list, permeate_volume_list: Data storing lists
%   a, ultrasonicObj, trigger_pin, echo_pin: Arduino and ultrasonic setups
%   dq: Daq setup
%   filename: Data csv file name
%
% Outputs:
%   Every data list saved in the csv file, tank state

    [distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin);
    [permeate_flowrate_list, permeate_flowrate, flowrate_list, flowrate, conductivity_list, conductivity] = daq_reading(dq, permeate_flowrate_list, flowrate_list, conductivity_list);
    disp("permeate flowrate(mL/min): " + permeate_flowrate)
    
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

end

