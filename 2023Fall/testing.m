part1 = load('04-10-25-try36.mat');
part2 = load('04-10-25-try36_2.mat');
part3 = load('04-10-25-try36_3.mat');
part4 = load('04-10-25-try36_4.mat');

combine_flow = [part1.permeate_flowrate_list;part2.permeate_flowrate_list; part3.permeate_flowrate_list; part4.permeate_flowrate_list];

combine_time = part1.time_list;
combine_time = [combine_time; part2.time_list + combine_time(end)];
combine_time = [combine_time; part3.time_list + combine_time(end)];
combine_time = [combine_time; part4.time_list + combine_time(end)];


plot(combine_time/60, combine_flow)