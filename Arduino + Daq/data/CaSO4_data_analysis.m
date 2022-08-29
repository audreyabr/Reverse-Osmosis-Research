D = [length(time_list),length(conductivity_list),length(distance_list),length(flowrate_list),length(permeate_flowrate_list),length(permeate_volume_list)];
data_length = min(D,[],"all");

% assigning variables
time = time_list(1:data_length);                                  % time, seconds
conductivity = conductivity_list(1:data_length);                  % conductivity, mS/cm
distance = distance_list(1:data_length);                          % distance, cm
batch_flow_rate = flowrate_list(1:data_length);                   % flow rate, mL/min
permeate_flow_rate = permeate_flowrate_list(1:data_length);       % flow rate, mL/min
mass = permeate_volume_list(1:data_length);                       % mass, g
tank_state = tank_state_list(1:data_length);                      % tank states, (0=empty,1=neither,2=full)

[r,c] = find(tank_state == 0);
empty_time = time(r);
        
%% calculates and plots salinity ,flux, and permeability
% parameters to enter each time
sal_mM_i = 4.6;       % mM, initial salinityfor salinity-based estimation of recovery
P_psi = 550;          % applied pressure in psi
permeate_cond = 100/1000;  % conductivity of permeate in mS/cm 

% preset parameters
t_min_av = 0.5;         % minutes to average over
condu_at_1mM = 0.35;   % mS/cm, conductivity of 1mM of CaSO4 and 2mM of NaCl
pi_at_1mM = 14.8729;    % kpa, osmotic pressure of 1mM of CaSO4 and 2mM of NaCl
t_interval = 1;         % NOTE: data time interval is approximate
A_m = 0.0238;           % m^2, membrane area(SW measurement feed side, 2019 module)

close all
sal_mM = conductivity / condu_at_1mM;  % mM, salinity calculated by linear relation to conductivity
n_av = t_min_av * 60/t_interval;        % number of points to make flux avg across

sal_mM_av = movmean(sal_mM, n_av);
flowrate_av = (mass(n_av+1:end) - mass(1:end-n_av)) ./ (time(n_av+1:end) - time(1:end-n_av));

flux_lmh = flowrate_av / 1000*3600 / A_m; % L/m2.h
RR_i_cond = 1 - sal_mM_i ./ sal_mM_av; % conductivity-based instantaneous RR assuming no salt permeation!
P_bar = P_psi * 0.0689;
pi_psi = pi_at_1mM * sal_mM_av; % est. osmotic pressure in psi
pi_bar = pi_psi * 0.01;    
perm_LMHB = flux_lmh ./ (P_bar-pi_bar(1:end-n_av)); %LMH/bar, permeability

%% Generate graphs
% plots conductivity over time
figure
hold on
plot(time/3600, conductivity)
xline(empty_time./3600)
title("Conductivity of Water Over Time")
xlabel("Time (h)")
ylabel("Conductivity (mS/cm)")
hold off

% plots distance over time
figure
hold on
plot(time/3600, distance)
xline(empty_time./3600)
title("Water Level Over Time")
xlabel("Time (h)")
ylabel("Distance (cm)")
ylim([0,30])
hold off

% plots flow rate over time
figure
hold on
plot(time/3600, batch_flow_rate)
xline(empty_time./3600)
title("Flow Rate of Batch Water Over Time")
xlabel("Time (h)")
ylabel("Flow Rate (mL/min)")
hold off

% plots flow rate over time
figure
hold on
plot(time/3600, permeate_flow_rate)
xline(empty_time./3600)
title("Flow Rate of Permeate Over Time")
xlabel("Time (h)")
ylabel("Flow Rate (mL/min)")
hold off

% plots mass over time
figure
hold on
plot(time/3600, mass)
xline(empty_time./3600)
title("Mass of Permeate Over Time")
xlabel("Time (h)")
ylabel("Mass (g)")
hold off

% plots flux
figure
plot(time(1:end-n_av)/3600, flux_lmh)
xline(empty_time./3600)
title("Flux Over Time")
xlabel('Time (h)')
ylabel('Flux (lmh)')
ylim([0,100])

% plots salinity
figure
plot(time/3600, sal_mM_av)
xline(empty_time./3600)
title("Salinity Over Time")
xlabel('Time (h)')
ylabel('Salinity (mM CaSO4)')

% plots recover rate
figure
plot(time/3600, RR_i_cond)
xline(empty_time./3600)
title("Recovery Rate")
xlabel('Time (h)')
ylabel('Instantaneous recovery (est.)')

% plots permeability
figure
plot(time(1:end-n_av)/3600,perm_LMHB)
xline(empty_time./3600)
title("Membrane Permeability Over Time")
xlabel('Time (h)')
ylabel('Permeability (LMH/bar)')
ylim([0,6])

% plots osmotic pressure
figure
plot(time/3600,pi_bar)
xline(empty_time./3600)
title("Osmotic Pressure Over Time")
xlabel('Time (h)')
ylabel('Osmotic pressure (bar)')

