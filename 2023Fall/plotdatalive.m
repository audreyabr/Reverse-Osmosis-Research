function plotdatalive(filename)
%plot permeate flowrate 
while(true)
load(filename);
sizeP = size(permeate_flowrate_list,1);
time_list_trim = time_list(1:sizeP);
plot(time_list_trim/60, permeate_flowrate_list)
xlabel("time(min)")
ylabel("permeate flowrate(ml/min)")

%xlim([0 100])
pause(10)
end
end

