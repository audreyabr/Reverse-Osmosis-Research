% Testing squishy_processing indealing by running a loop
% Simulates a squishy batch

% creating out lists to store data from loop
salt_rej_list = [];
mem_CaSO4_conc_list = [];
conc_polar_list = [];
SI_gypsum_list = [];
ind_time_list = [];
C_t_list = [];

for i = 1:time_list %only needs to run n-1 times to collect data through second n
    squishy_processing(initial_conductivity,flowrate_list,permeate_flowrate_list,conductivity_list,conductivity,time_list)
    salt_rej_list(end+1) = salt_rej;
    mem_CaSO4_conc_list(end+1) = mem_CaSO4_conc;
    conc_polar_list(end+1) = conc_polar;
    SI_gypsum_list(end+1) = SI_gypsum;
    ind_time_list(end+1) = ind_time;
    C_t_list(end+1) = C_t
end   

f = @(ind_time_list,C_t_list) 1./(ind_time_list.*C_t_list);
nucl_prob = integral2(f,0,500,0,500);