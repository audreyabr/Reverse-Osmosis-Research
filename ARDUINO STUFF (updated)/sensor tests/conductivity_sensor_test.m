 clear
%  a = arduino ('COM18', 'Mega2560');
 a = arduino('COM4', 'Mega2560','Libraries', 'Ultrasonic');

 cond_pin = 'A1';
 trigger_pin= 'D8';
 echo_pin = 'D9';
 conductivity_list = [];
 distance_list = [];

 ultrasonicObj = ultrasonic(a,trigger_pin, echo_pin, 'OutputFormat','double');


for loop = 1:600
    [distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin);   
    conductivity_list = conductivity_reading(a,conductivity_list,cond_pin);
	scatter(loop, conductivity_list(end,1))% live plotting
	hold on 
	pause(0.5)
end 

