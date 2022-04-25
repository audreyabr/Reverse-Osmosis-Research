 clear all 
 a = arduino ('COM8', 'Mega2560')
 conductivity_list = []

for loop = 1:500
    conductivity_list = conductivity_reading(a,conductivity_list);
	scatter(loop, conductivity_list(end,1))% live plotting
	hold on 
	pause(0.5)
        
end 

