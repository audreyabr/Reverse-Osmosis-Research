 clear all 
 a = arduino('COM8', 'Mega2560')
 flowrate_list = []

for loop = 1:100
    flowrate_list = flowrate_reading(a,flowrate_list);
	scatter(loop, flowrate_list(end,1))% live plotting
	hold on 
	pause(1)
        
end 
