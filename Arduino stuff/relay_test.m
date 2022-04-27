[distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin)    
% Turn valves on and off one at the time with pins D5, D6, D7 connected 
clear all

a = arduino() %('COM8', 'Uno')

disp('starting')

pause(1)
writeDigitalPin(a,'D3',0);
pause(1)
writeDigitalPin(a,'D4',0);
pause(1)
writeDigitalPin(a,'D5',0);
pause(1)
disp('all on')
writeDigitalPin(a,'D3',1);
pause(1)
writeDigitalPin(a,'D4',1);
pause(1)
writeDigitalPin(a,'D5',1);
pause(1)
disp('all off')
