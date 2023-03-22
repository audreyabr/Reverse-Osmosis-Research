function[] = pres_CaSO4_analysis(time_list,conductivity_list,tank_volume_list,flowrate_list,permeate_flowrate_list,permeate_volume_list,tank_state_list,P_psi)
% This function takes in data lists and setting conditions of each test with
% NaCl and CaSO4. It generates graphs including flux over time, permeability
% over time, etc. 

% Inputs:
    % time(sec),conductivity(mS/cm), tank volume(mL), two flowrates(mL/min), permeate volume(mL), and tank
    % state lists
    % P_psi: applied pressure in psi
    % permeate_cond: conductivity of permeate in mS/cm 
% Output:
    % flux_lmh: L/m2.h, flux calculated with permeate flowrate
    % sal_mM_av: mM, salinity of CaSO4 (only) calculated with conductivity
    % RR_i_cond: instantaneous recovery rate calculated with conductivity
    % pi_bar: bar, osmotic pressure calculated with linear relation between
    %         osmotic pressure and concentration.
    % perm_LMHB: L/m2.h.bar, permeability calculated with flux and osmotic pressure 


% Input data
D = [length(time_list),length(conductivity_list),length(tank_volume_list),length(flowrate_list),length(permeate_flowrate_list),length(permeate_volume_list)];
data_length = (min(D,[],"all")-1);

% assigning variables
time = time_list(1:data_length);                                  % time, seconds
conductivity = conductivity_list(1:data_length);                  % conductivity, mS/cm
tank_volume = tank_volume_list(1:data_length);                          % distance, cm
batch_flow_rate = flowrate_list(1:data_length);                   % flow rate, mL/min
permeate_flow_rate = permeate_flowrate_list(1:data_length);       % flow rate, mL/min
mass = permeate_volume_list(1:data_length);                       % mass, g

tank_state = tank_state_list(1:data_length);                      % tank states, (0=empty,1=neither,2=full)
[r,c] = find(tank_state == 0);
empty_time = time(r);
        
%% calculates and plots salinity ,flux, and permeability

% preset parameters
t_min_av = 0.5;         % minutes to average over
pi_at_1mM = 14.8729;    % kpa, osmotic pressure of 1mM of CaSO4 and 2mM of NaCl
t_interval = 1;         % NOTE: data time interval is approximate
A_m = 0.0238;           % m^2, membrane area(SW measurement feed side, 2019 module)

condu_i = mean(mink(conductivity(2:10), 10));
sal_M_i = condu_concen_converter(condu_i,"conductivity");
sal_mM_i = sal_M_i * 1000;

close all
sal_M = condu_concen_converter(conductivity, "conductivity"); % conductivity data to concentration in M
sal_mM = sal_M * 1000; % convert to mM
n_av = t_min_av * 60/t_interval; % number of points to make flux avg across

sal_mM_av = movmean(sal_mM, n_av);


flowrate_av = (mass(n_av+1:end) - mass(1:end-n_av)) ./ (time(n_av+1:end) - time(1:end-n_av));
RR_i_cond = 1 - sal_mM_i ./ sal_mM_av; % conductivity-based instantaneous RR assuming no salt permeation!


flux_lmh = ((flowrate_av / 1000)*3600 )/ A_m; % L/m2.h
P_bar = P_psi * 0.0689;
pi_kpa = pi_at_1mM * sal_mM_av; % est. osmotic pressure in kpa
pi_bar = pi_kpa * 0.01;    
perm_LMHB = flux_lmh ./ (P_bar-pi_bar(1:end-n_av)); %LMH/bar, permeability

%% Generate graphs

% Vertical lines at moments that the tank turns empty

% plots conductivity over time
figure
hold on
plot(time/3600, conductivity)
%xline(empty_time./3600)
title("Conductivity of Water Over Time")
xlabel("Time (h)")
ylabel("Conductivity (mS/cm)")
ylim([0,25])
hold off

% plots tank volume over time
figure
hold on
plot(time/3600, tank_volume,"r*")
%xline(empty_time./3600)
title("Tank Volume Over Time")
xlabel("Time (h)")
ylabel("Volume (mL)")
ylim([0,10000])
hold off
% 
% plots flow rate over time
figure
hold on
plot(time/3600, batch_flow_rate)
%xline(empty_time./3600)
title("Flow Rate of Batch Water Over Time")
xlabel("Time (h)")
ylabel("Flow Rate (mL/min)")
ylim([0,700])
hold off

% plots permeate flow rate over time
figure
hold on
plot(time/3600, permeate_flow_rate)
%xline(empty_time./3600)
title("Flow Rate of Permeate Over Time")
xlabel("Time (h)")
ylabel("Flow Rate (mL/min)")
ylim([-1 15])
hold off

% plots mass over time
figure
hold on
plot(time/3600, mass)
%xline(empty_time./3600)
title("Mass of Permeate Over Time")
xlabel("Time (h)")
ylabel("Mass (g)")
hold off

% plots flux
figure
plot(time(1:end-n_av)/3600, flux_lmh)
%xline(empty_time./3600)
title("Flux Over Time")
xlabel('Time (h)')
ylabel('Flux (lmh)')
%ylim([0,3])

% plots salinity
figure
plot(time/3600, sal_mM_av)
%xline(empty_time./3600)
title("Salinity Over Time")
xlabel('Time (h)')
ylabel('Salinity (mM CaSO4)')
ylim([0,55])

% plots recover rate
figure
plot(time/3600, RR_i_cond)
%xline(empty_time./3600)
title("Recovery Rate")
xlabel('Time (h)')
ylabel('Instantaneous recovery (est.)')
ylim([0,1])

% plots permeability
figure
plot(time(1:end-n_av)/3600,perm_LMHB)
%xline(empty_time./3600)
title("Membrane Permeability Over Time")
xlabel('Time (h)')
ylabel('Permeability (LMH/bar)')
ylim([0,0.2])

% plots osmotic pressure
figure
plot(time/3600,pi_bar)
%xline(empty_time./3600)
title("Osmotic Pressure Over Time")
xlabel('Time (h)')
ylabel('Osmotic pressure (bar)')

end

