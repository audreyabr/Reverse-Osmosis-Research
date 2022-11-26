function [time_list, permeate_flowrate_list, batch_flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, tank_volume_list] = main_data_collection(dq, time_list, tank_volume_list, permeate_flowrate_list, batch_flowrate_list, conductivity_list, permeate_volume_list, tank_state_list, filename,t, empty_tank_volume, full_tank_volume)
% main_data_measuring function combines four functions including
% daq_reading, time_readings, integrate_permeate_volume, check_tank_state.
% It reads data from DAQ, displays current permeate
% flowrate, calculates accumulative permeate volume, check tank state, and
% save all data lists in csv file.
%
% Inputs: 
%   empty_tank_volume, full_tank_volume: tank volume setting for every batch
%   time_list, dtank_volume_list, permeate_flowrate_list, batch_flowrate_list,
%   conductivity_list, permeate_volume_list,tank_state_list: 7 Data storing lists
%   dq: Daq setup name
%   filename: Data csv file name
%
% Outputs:
%   7 data lists saved in the csv file, including time_list, 
%   conductivity_list, tank_volume_list, permeate_flowrate_list, batch_flowrate_list, 
%   permeate_volume_list, tank_state_list

    % Read time
    time_now = toc(t); 
    time_list = time_readings(time_list, time_now);
    
    % Read daq data, append new data to lists
    [permeate_flowrate_list, permeate_flowrate, batch_flowrate_list, batch_flowrate, conductivity_list, conductivity, tank_volume_list] = daq_reading(dq, permeate_flowrate_list, batch_flowrate_list, conductivity_list,tank_volume_list);
    disp("permeate flowrate(mL/min): " + permeate_flowrate)
    
    % Calculate for permeate volume
    [permeate_volume_list, permeate_volume] = integrate_permeate_volume(time_list,permeate_flowrate_list, permeate_volume_list);
    
    % Check if tank volume full
    tank_state = pres_check_tank_state(empty_tank_volume, full_tank_volume,tank_volume_list);
    tank_state_list(end+1,1) = tank_state;
    
    % write data into csv file
    tobesaved = [time_list, conductivity_list, tank_volume_list, permeate_flowrate_list, batch_flowrate_list, permeate_volume_list, tank_state_list]; 
    csvwrite(filename, tobesaved);

end

