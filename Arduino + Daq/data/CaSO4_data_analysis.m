D = [length(time_list),length(conductivity_list),length(distance_list),length(flowrate_list),length(permeate_flowrate_list),length(permeate_volume_list)];
data_length = min(D,[],"all");

% assigning variables
time = time_list(1:data_length);                                  % time, seconds
conductivity = conductivity_list(1:data_length);                  % conductivity, mS/cm
distance = distance_list(1:data_length);                          % distance, cm
batch_flow_rate = flowrate_list(1:data_length);                   % flow rate, mL/min
permeate_flow_rate = permeate_flowrate_list(1:data_length);       % flow rate, mL/min
mass = permeate_volume_list(1:data_length);                       % mass, g

% calculates and plots salinity ,flux, and permeability
% parameters to enter each time
sal_mM_i = 4.5;       % mM, initial salinityfor salinity-based estimation of recovery
P_psi = 575;          % applied pressure in psi
permeate_cond = 0.107;  % conductivity of permeate in mS/cm 

% preset parameters
t_min_av = 0.5;         % minutes to average over
condu_at_1mM = 0.495;   % mS/cm, conductivity of 1mM of CaSO4 and 2mM of NaCl
pi_at_1mM = 14.8729;    % psi, osmotic pressure of 1mM of CaSO4 and 2mM of NaCl
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
pi_bar = pi_psi * 0.0689;
perm_LMHB = flux_lmh ./ (P_bar-pi_bar(1:end-n_av)); %LMH/bar, permeability


% plots conductivity over time
figure
hold on
plot(time, conductivity)
title("Conductivity of Water Over Time")
xlabel("Time, s")
ylabel("Conductivity, mS/cm")
hold off

% plots distance over time
figure
hold on
plot(time, distance)
title("Water Level Over Time")
xlabel("Time, s")
ylabel("Distance, cm")
ylim([0,30])
hold off

% plots flow rate over time
figure
hold on
plot(time, batch_flow_rate)
title("Flow Rate of Batch Water Over Time")
xlabel("Time, s")
ylabel("Flow Rate, mL/min")
hold off

% plots flow rate over time
figure
hold on
plot(time, permeate_flow_rate)
title("Flow Rate of Permeate Over Time")
xlabel("Time, s")
ylabel("Flow Rate, mL/min")
hold off

% plots mass over time
figure
hold on
plot(time, mass)
title("Mass of Permeate Over Time")
xlabel("Time, s")
ylabel("Mass, g")
hold off

% plots flux
figure
plot(time(1:end-n_av), flux_lmh,'o')
title("Flux Over Time")
xlabel('Time (s)')
ylabel('Flux (lmh)')
ylim([0,200])

% plots salinity
figure
plot(time, sal_mM_av,'o')
title("Salinity Over Time")
xlabel('Time (s)')
ylabel('Salinity (% NaCl)')

% plots recover rate
figure
plot(time, RR_i_cond,'o')
title("Recovery Rate")
xlabel('Time (s)')
ylabel('Instantaneous recovery (est.)')

% plots permeability
figure
plot(time(1:end-n_av),perm_LMHB,'o')
title("Membrane Permeability Over Time")
xlabel('Time (s)')
ylabel('Permeability (LMH/bar)')
ylim([0,10])

% plots osmotic pressure
figure
plot(time,pi_bar,'o')
title("Osmotic Pressure Over Time")
xlabel('Time (s)')
ylabel('Osmotic pressure (bar)')
