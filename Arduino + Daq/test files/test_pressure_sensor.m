clear
% set up Arduino and Ultrasonic sensor
trigger_pin= 'D8';
echo_pin = 'D9';

a = arduino('COM6', 'Mega2560','Libraries', 'Ultrasonic');
ultrasonicObj = ultrasonic(a,trigger_pin, echo_pin, 'OutputFormat','double');

distance_list = [];
[distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin);
tank_height = 29.87;
ultra_distance_from_bottom = tank_height - distance;
disp(ultra_distance_from_bottom)

% set up DAQ
daqreset
d = daqlist;
dq = daq("ni");
Daqtype = d.DeviceID;

ch00ai = addinput(dq,Daqtype,'ai0','Voltage');  % permeate flowrate in Channel AI0(+)
ch00ai.TerminalConfig = 'Differential';
ch01ai = addinput(dq,Daqtype,'ai1','Voltage');  % batch flowrate in Channel AI1(+)
ch01ai.TerminalConfig = 'Differential';
ch02ai = addinput(dq,Daqtype,'ai2','Voltage');  % conductivity in Channel AI2
ch02ai.TerminalConfig = 'Differential';
ch03ai = addinput(dq,Daqtype,'ai3','Voltage');  % pressure in Channel AI3
ch03ai.TerminalConfig = 'Differential';

% Initialize 
index = 25;
voltage_list = []; 

daqName = dq;
% taking multiple readings from each input pin
for i = 1:index
    daqName.Rate = 5000;
    voltage_list(i,1:4) = read(daqName, "OutputFormat", "Matrix");
end 
disp(voltage_list);
water_height = volt_to_height(mean(voltage_list(:,4)));
%disp(mean(voltage_list(:,4)));
%disp(water_height)