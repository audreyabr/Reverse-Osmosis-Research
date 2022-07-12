daqreset
d = daqlist;
dq = daq('ni');
Daqtype = d.DeviceID;

ch00ai = addinput(dq,Daqtype,'ai0','Voltage');  % permeate flowrate in Channel AI0(+)
ch00ai.TerminalConfig = 'SingleEnded';

perm_flowrate_list = [];

for loop = 1:100
    matrixdata = read(dq, "OutputFormat", "Matrix");
    perm_flowrate_list = matrixdata(1)/5*100;  
	scatter(loop, perm_flowrate_list(end,1)) % live plotting
	hold on 
	pause(1)
end 
