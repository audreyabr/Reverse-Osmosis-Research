function water_height = volt_to_height(voltage_output)
% This function takes in voltage difference across a resistor 
% in the 4-20mA loop with WIKA pressure transmitter and convert it to 
% the height of tank water level.

% voltage: V
% current: mA
% water level: cm

% current and measured pressure ranges
min_current = 4; % mA
max_current  = 20; % mA
min_height = 0; % cm
max_height = 70.309; % cm

resistance = 251; % ohm

% calcutate current through resistor
current_output = (voltage_output / resistance) * 1000; % mA

% convert current signal to height of tank water level
water_height = (current_output - min_current) *((max_height - min_height)/ (max_current - min_current))+ min_height; % cm

% rectify negative height
if water_height < 0
    water_height = 0;
end 

end

