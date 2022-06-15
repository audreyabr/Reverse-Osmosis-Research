 clear
 a = arduino('COM4', 'Mega2560');
 perm_flowrate_list = [];

for loop = 1:100
    perm_flowrate_pin = 'A2';
    perm_flowrate_list = permeate_flowrate_reading(a,perm_flowrate_list,perm_flowrate_pin);
	scatter(loop, perm_flowrate_list(end,1))% live plotting
	hold on 
	pause(1)
        
end 
