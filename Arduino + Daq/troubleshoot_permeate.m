% troublueshooting permeate
clear

filename = 'live_data.txt';

% set up daq
daqreset
d = daqlist;
dq = daq('ni');
Daqtype = d.DeviceID;

ch00ai = addinput(dq,Daqtype,'ai0','Voltage');  % permeate flowrate in Channel AI0(+)
ch00ai.TerminalConfig = 'SingleEnded';
ch01ai = addinput(dq,Daqtype,'ai1','Voltage');  % batch flowrate in Channel AI1(+)
ch01ai.TerminalConfig = 'SingleEnded';
ch02ai = addinput(dq,Daqtype,'ai2','Voltage');  % conductivity in Channel AI2
ch02ai.TerminalConfig = 'Differential';

% Setup Scale
% if ~isempty(instrfind)
%   fclose(instrfind);
%   delete(instrfind);
% end
% 
s = serial('COM6 q', "Baudrate", 9600); % scale
 set(s,'Parity', 'none');
 set(s,'DataBits', 8);
 set(s,'StopBit', 1);

fopen(s)
%%
% constants
empty_tank_dist = 22.3;  % cm, top of the tank to the top of the drainage square with some extra room
full_tank_dist = 21.5;  % cm  (CHANGE LATER?)
pause_time = 0.5; % seconds, waiting time between arduino operations
flow_loop_volume = 120; % ml, the total amount of water in one batch
flush_tube_volume = 72; % ml, the amount water in the tubes

% empty lists 
time_list = [0];
mass_list = [0];
conductivity_list = [];
flowrate_list = [0];
permeate_flowrate_list = [0];
scale_flowrate_list = [0;0];

permeate_volume_list = [0];

% main code 
run = 1;
t = tic();

figure
%%
while run == 1
    % REGULAR DATA COLLECTION
      % Read time
    time_now = toc(t); 
    time_list = time_readings(time_list, time_now);  
    [mass_list, mass] = scale_reading(s, mass_list);
    scale_flowrate_list=(mass_list(:,1:end-1)-mass_list(:,2:end))/(time_list(:,1:end-1)-time_list(:,2:end))*60;
    [permeate_flowrate_list, current_permeate_flowrate, flowrate_list, current_flowrate, conductivity_list, conductivity] = daq_reading(dq, permeate_flowrate_list, flowrate_list, conductivity_list);
    
plot(time_list,permeate_flowrate_list,time_list,scale_flowrate_list)
xlabel('Time [s]')
ylabel('Permeate flowrate [mL/min]')
legend('Flowmeter','Scale')
drawnow
pause(0.1)
    
end 
