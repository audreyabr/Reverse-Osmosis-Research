function [d, dq, Daqtype] = initalizeDaq()

daqreset
d = daqlist;
dq = daq("ni");
Daqtype = d.DeviceID;

ch00ai = addinput(dq,Daqtype,'ai0','Voltage');  % permeate flowrate in Channel AI0(+)
ch00ai.TerminalConfig = 'Differential';
ch01ai = addinput(dq,Daqtype,'ai1','Voltage');  % batch flowrate in Channel AI1(+)
ch01ai.TerminalConfig = 'Differential';

end