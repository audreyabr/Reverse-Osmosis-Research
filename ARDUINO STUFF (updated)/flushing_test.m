% flushing test (to see why it explodes)
clear all 
run = 1 
batch_valve_pin = 'D4';
brine_valve_pin = 'D3';
feed_valve_pin = 'D5';

a = arduino() %('COM8', 'Uno')
 
    pause(3)
   
   %flush
writeDigitalPin(a,brine_valve_pin,0);% relay is ON, so brine valve is open
pause(0.2)
writeDigitalPin(a,feed_valve_pin,0);% relay is ON, so feed valve is open
writeDigitalPin(a,batch_valve_pin,0); % relay is ON, so batch valve is closed
  