function [permeate_volume_list, permeate_volume] = integrate_permeate_volume(time_list,permeate_flowrate_list, permeate_volume_list)
% This function displays the total volume of permeate(ml) by integrating 
% the permeate volume in each time interval up to a given time

time_interval = time_list(end)-time_list(end-1); % in s
average_flowrate = (permeate_flowrate_list(end) + permeate_flowrate_list(end-1))/ 2; % in mL/min
add_permeate = time_interval/60 * average_flowrate; % divide by 60 to put time_interval into minute
permeate_volume = permeate_volume_list(end) + add_permeate;
permeate_volume_list(end+1, 1) = permeate_volume;
disp("Current permeate volume = " + permeate_volume + "ml")
end

