clear
% set up DAQ
daqreset
d = daqlist;
dq = daq("ni");
Daqtype = d.DeviceID;

ch00ai = addinput(dq,Daqtype,'ai0','Voltage');  % permeate flowrate in Channel AI0(+)
ch00ai.TerminalConfig = 'Differential';
ch01ai = addinput(dq,Daqtype,'ai1','Voltage');  % batch flowrate in Channel AI1(+)
ch01ai.TerminalConfig = 'Differential';

% initialize
time_list = [0];
batch_flowrate_list = [0];
permeate_flowrate_list= [0];
permeate_volume_list = [0];

t = tic();
run = 1;

while run == 1
    time_now = toc(t); 
    time_list = time_readings(time_list, time_now);
    [permeate_flowrate_list, permeate_flowrate, batch_flowrate_list, batch_flowrate] = daq_reading(dq, permeate_flowrate_list, batch_flowrate_list);
 
end 