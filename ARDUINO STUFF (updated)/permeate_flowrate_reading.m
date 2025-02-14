function [perm_flowrate_list, perm_flowrate] = permeate_flowrate_reading(arduino_object,perm_flowrate_list,perm_flowrate_pin)

% Takes in the current flowrate list, takes the next
% flowrate reading and appends it onto the list

% Args: arduino_object = the specific arduino we're using 
%       perm_flowrate_list = an array of permeate flowrate readings 

% Returns: perm_flowrate_list = the list of permeate flowrate readings 
%          perm_flowrate = the current permeate flowrate reading  

    perm_voltage = readVoltage(arduino_object,perm_flowrate_pin); % can only read from 0V to 5V

    perm_flowrate = perm_voltage * 20; % 20 calculated by max flow rate(100ml/min) / 5v 
    perm_flowrate_list(end+1, 1) = perm_flowrate;
end