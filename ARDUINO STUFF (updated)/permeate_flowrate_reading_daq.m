function [perm_flowrate_list, perm_flowrate] = permeate_flowrate_reading_daq(daqName, perm_flowrate_list)

% Takes in the current flowrate list, takes the next
% flowrate reading and appends it onto the list

% Args: daqName = the specific daq we're using 
%       perm_flowrate_list = an array of permeate flowrate readings 

% Returns: perm_flowrate_list = the list of permeate flowrate readings 
%          perm_flowrate = the current permeate flowrate reading  

    perm_voltage = read(daqName, "OutputFormat", "Matrix");

    perm_flowrate = perm_voltage(1) * 20; % 20 calculated by max flow rate(100ml/min) / 5v 
    perm_flowrate_list(end+1, 1) = perm_flowrate;
end