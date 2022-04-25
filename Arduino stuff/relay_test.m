% Turn valves on and off one at the time with pins D5, D6, D7 connected 
clear all

a = arduino ('COM8', 'Mega2560')

disp('starting')

pause(1)
writeDigitalPin(a,'D5',0);
pause(1)
writeDigitalPin(a,'D6',0);
pause(1)
writeDigitalPin(a,'D7',0);
pause(1)
disp('all on')
writeDigitalPin(a,'D5',1);
pause(1)
writeDigitalPin(a,'D6',1);
pause(1)
writeDigitalPin(a,'D7',1);
pause(1)
disp('all off')
