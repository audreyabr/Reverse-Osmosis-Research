function [flowrate_list,flowrate] = flowrate_reading_daq(daqName, flowrate_list)

% Takes in the current flowrate list, takes the next
% flowrate reading and appends it onto the list

% Args: daqName = the specific daq we're using 
%       flowrate_list - an array of flowrate readings 

% Returns: flowrate_list - the list of flowrate readings 
%          flowrate - the current flowrate reading  
    
    voltage = read(daqName, "OutputFormat", "Matrix"); % can only read from 0 to 5V
    %voltage = (analogvalue * 5 / 1023);
    %voltage_out = (analogvalue*(3.3/1024)*5)*63  % voltage after going through voltmeter, read by arduino 
                                             % 63 is some multiplier to make it more correct
    %voltage_in = voltage_out * 1/(((3.3/1024)*5)*63)
    
    flowrate = voltage(2) * 200; % 200 calculated by max flow rate (1000ml/min) / 5v
    flowrate_list(end+1, 1) = flowrate;

end
