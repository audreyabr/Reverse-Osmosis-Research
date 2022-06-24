% reading data
data = readtable('138_2022-02-21.csv'); % name of file being analyzed

% converting table to an array
A = table2array(data);

% assigning variables
time = A(:,1);         % time, seconds
conductivity = A(:,2); % conductivity, mS/cm
distance = A(:,3);     % distance, cm
flow_rate = A(:,4);    % flow rate, mL/min
mass = A(:,5);         % mass, g
stage = A(:,6);        % stage number


% calculates and plots salinity ,flux, and permeability
% parameters to enter each time
sal_pct_i = 0.03; % initial salinity (in %) for salinity-based estimation of recovery
P_psi = 350; % applied pressure in psi
permeate_cond = 0.188; % 

% % preset parameters
t_min_av = 0.5; % minutes to average over
cond_at_1pct = 17.6; % conductivity in mS/cm for 1% NaCl
pi_at_1pct = 7.9566; % osmotic pressure in bar for 1% NaCl
t_interval = 1; % s NOTE: data time interval is approximate

close all
sal_pct = conductivity / cond_at_1pct; % salinity in % by wt (where linear!)
n_av = t_min_av * 60/t_interval; % number of points to make flux avg across

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
plot(time, stage)
title("Conductivity of Water Over Time")
xlabel("Time, s")
ylabel("Conductivity, mS/cm")
hold off

% plots distance over time
figure
hold on
plot(time, distance)
plot(time, stage)
title("Water Level Over Time")
xlabel("Time, s")
ylabel("Distance, cm")
ylim([0,30])
hold off

% plots flow rate over time
figure
hold on
plot(time, flow_rate)
title("Flow Rate of Water Over Time")
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

%plots stage number over time
figure
hold on
plot(time, stage)
title("Stage Number Over Time")
xlabel("Time, s")
ylabel("Stage Number")
hold off


figure
plot(time(1:end-n_av), flux_lmh,'o')
xlabel('Time (s)')
ylabel('Flux (lmh)')
ylim([0,200])

figure
plot(time, sal_pct_av,'o')
xlabel('Time (s)')
ylabel('Salinity (% NaCl)')

figure
plot(time, RR_i_cond,'o')
xlabel('Time (s)')
ylabel('Instantaneous recovery (est.)')

figure
plot(time(1:end-n_av),perm_LMHB,'o')
xlabel('Time (s)')
ylabel('Permeability (LMH/bar)')
ylim([0,10])
