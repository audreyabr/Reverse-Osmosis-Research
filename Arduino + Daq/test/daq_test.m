daqreset
d = daqlist;
dq = daq('ni');
Daqtype = d.DeviceID

ch00ai = addinput(dq,Daqtype,'ai0','Voltage');  %permeate flowrate in Channel AI0(+)
ch00ai.TerminalConfig = 'SingleEnded';
disp('DAQ ready to go!')

readDaqOnce(dq) % start with just one output to test

function[qPerm] = readDaqOnce(daqName)
    matrixdata = read(daqName, "OutputFormat", "Matrix");
    qPerm = matrixdata(1)/5*100;  
end