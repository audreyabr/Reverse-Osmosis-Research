function [perm_flowrate_list, permeate_flowrate] = permeate_flowrate_reading_daq(daqName, perm_flowrate_list)

% Takes in the current flowrate list, takes the next
% flowrate reading and appends it onto the list

% Args: daqName = the specific daq we're using 
%       perm_flowrate_list = an array of permeate flowrate readings 

% Returns: perm_flowrate_list = the list of permeate flowrate readings 
%          perm_flowrate = the current permeate flowrate reading  

    index = 25;
    permeate_voltage_list = [];
    for i = 1:index
        voltage = read(daqName, "OutputFormat", "Matrix");
        permeate_voltage_list(i,1) = voltage(1);
    end 

    no_outliers = rmoutliers(permeate_voltage_list);
    avg_permeate = mean(no_outliers);
    permeate_flowrate = avg_permeate * (100 / 5); 
