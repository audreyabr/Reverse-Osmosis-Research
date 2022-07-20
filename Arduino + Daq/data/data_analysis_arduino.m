
% assigning variables
time = time_list;                              % time, seconds
conductivity = conductivity_list;                  % conductivity, mS/cm
distance = distance_list;                      % distance, cm
batch_flow_rate = flowrate_list;               % flow rate, mL/min
permeate_flow_rate = permeate_flowrate_list;   % flow rate, mL/min
mass = permeate_volume_list;                              % mass, g


molar_mass_CaSO4 = 136.14; % g/mol

% calculates and plots salinity ,flux, and permeability
% parameters to enter each time
milli_mols_initial = 4.5; %mM
sal_pct_i = (1/1000*molar_mass_CaSO4*milli_mols_initial)/1000*100; % initial salinity (in %) for salinity-based estimation of recovery
P_psi = 375;            % applied pressure in psi
permeate_cond = 160/1000;  % conductivity of permeate in mS/cm 

% preset parameters
t_min_av = 0.5;         % minutes to average over
cond_at_1pct = 17.6;    % conductivity in mS/cm for 1% NaCl
pi_at_1pct = 7.9566;    % osmotic pressure in bar for 1% NaCl
t_interval = 1;         % s NOTE: data time interval is approximate

close all
sal_pct = conductivity / cond_at_1pct;  % salinity in % by wt (where linear!)
n_av = t_min_av * 60/t_interval;        % number of points to make flux avg across

sal_pct_av = movmean(sal_pct, n_av);
flowrate_av = (mass(n_av+1:end) - mass(1:end-n_av)) ./ (time(n_av+1:end) - time(1:end-n_av));
A_m = 0.0238; % m^2 (SW measurement feed side, 2019 module)
flux_lmh = flowrate_av / 1000*3600 / A_m;
RR_i_cond = 1 - sal_pct_i ./ sal_pct_av; % conductivity-based instantaneous RR assuming no salt permeation!
P_bar = P_psi * 0.0689;
pi_bar = pi_at_1pct * sal_pct_av; % est. osmotic pressure in bar
perm_LMHB = flux_lmh ./ (P_bar-pi_bar(1:end-n_av)); % permeability


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
plot(time, sal_pct_av,'o')
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

