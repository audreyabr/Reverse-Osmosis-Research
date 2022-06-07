clear
% flushing test (to see why it explodes)

batch_valve_pin = 'D4';
brine_valve_pin = 'D3';
feed_valve_pin = 'D5';

a = arduino('COM5', 'Mega2560'); %('COM8', 'Uno')
 
pause(5)

%for i = 1:5
%flush
writeDigitalPin(a,brine_valve_pin,0);% relay is ON, so brine valve is open
pause(5)
writeDigitalPin(a,feed_valve_pin,0);% relay is ON, so feed valve is open
pause(5)
writeDigitalPin(a,batch_valve_pin,0); % relay is ON, so batch valve is closed
pause(5)

pause(5)

% configurePin(a,'D3',"pullup")
% b = readDigitalPin(a,brine_valve_pin);

writeDigitalPin(a,feed_valve_pin,1);% relay is closed, so feed valve is close
pause(5)

writeDigitalPin(a,brine_valve_pin,1);% relay is closed, so brine valve is close
pause(5)

writeDigitalPin(a,batch_valve_pin,1); % relay is closed so batch valve is open
pause(5)
