function plotdata(time_list,permeate_flowrate_list)
%plot permeate flowrate 
sizeP = size(permeate_flowrate_list);
time_list_trim = time_list(1:sizeP(1));
plot(time_list_trim/60, permeate_flowrate_list)
xlabel("time(min)")
ylabel("permeate flowrate(ml/min)")

%ylim([0 25])
end

