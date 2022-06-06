function [flowrate_list,flowrate] = flowrate_reading(arduino_object, flowrate_list, flowrate_pin)

% Takes in the current flowrate list, takes the next
% flowrate reading and appends it onto the list

% Args: arduino_object = the specific arduino we're using 
%       flowrate_list - an array of flowrate readings 

% Returns: flowrate_list - the list of flowrate readings 
%          flowrate - the current flowrate reading  
    
    voltage = readVoltage(arduino_object,flowrate_pin); % can only read from 0 to 5V
    %voltage = (analogvalue * 5 / 1023);
    %voltage_out = (analogvalue*(3.3/1024)*5)*63  % voltage after going through voltmeter, read by arduino 
                                             % 63 is some multiplier to make it more correct
    %voltage_in = voltage_out * 1/(((3.3/1024)*5)*63)
    
    flowrate = voltage * 20;
    flowrate_list(end+1, 1) = flowrate;

end
