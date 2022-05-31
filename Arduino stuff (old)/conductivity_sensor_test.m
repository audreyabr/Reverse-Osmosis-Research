 clear all 
 a = arduino ('COM8', 'Mega2560')
 conductivity_list = []

for loop = 1:500
    cond_pin = 'A1'[distance_list, distance] = distance_reading(a, ultrasonicObj, distance_list, trigger_pin, echo_pin)    

    conductivity_list = conductivity_reading(a,conductivity_list,cond_pin);
	scatter(loop, conductivity_list(end,1))% live plotting
	hold on 
	pause(0.5)
        
end 

