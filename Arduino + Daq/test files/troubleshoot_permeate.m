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
%%
%Setup Scale
if ~isempty(instrfind)
  fclose(instrfind);
  delete(instrfind);
end


s = serial('COM6', "Baudrate", 9600) % scale
 set(s,'Parity', 'none');
 set(s,'DataBits', 8);
 set(s,'StopBit', 1);

% scaletest = fscanf(s)
% pause

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
scale_flowrate_list = [0];
permeate_volume_list = [0];
oldmass=0;
    perm_flowmeter_added_mass=0;



% main code 
run = 1;
t = tic();

close all
figure

    time_now = toc(t); 

while time_now < 60
    % REGULAR DATA COLLECTION
      % Read time
    time_now = toc(t); 
    time_list = time_readings(time_list, time_now);
    fopen(s);
    a = fscanf(s)% 
    b = strtrim(a);
    c = erase(b,"g");
    d = erase(c,"?");
    e = strtrim(d);
    newmass = str2double(e);
    fclose(s);
    mass_list=[mass_list;newmass];
    scale_flowrate_list=[scale_flowrate_list;(mass_list(end)-mass_list(end-1))./(time_list(end)-time_list(end-1))*60];
    oldmass=newmass;
    [permeate_flowrate_list, current_permeate_flowrate, flowrate_list, current_flowrate, conductivity_list, conductivity] = daq_reading(dq, permeate_flowrate_list, flowrate_list, conductivity_list);
    perm_flowmeter_added_mass=[perm_flowmeter_added_mass;perm_flowmeter_added_mass(end)+current_permeate_flowrate*(time_list(end)-time_list(end-1))/60];


if length(time_list)>=4
    plot(time_list(4:end),permeate_flowrate_list(4:end),time_list(4:end),scale_flowrate_list(4:end))
    xlabel('Time [s]')
    ylabel('Permeate flowrate [mL/min]')
    legend('Flowmeter','Scale')
end
drawnow
pause(3)    
end 

perm_FM_mass=mass_list(2)+perm_flowmeter_added_mass;
figure    
plot(time_list(2:end-3),perm_FM_mass(2:end-3),time_list(2:end),mass_list(2:end))
    xlabel('Time [s]')
    ylabel('Permeate mass [g]')
    legend('Flowmeter','Scale')