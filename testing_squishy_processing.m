% Testing squishy_processing indealing by running a loop
% Simulates a squishy batch

timestep = 30;         %total number of seconds to simulate


for i = 1:(timestep-1) %only needs to run n-1 times to collect data through second n
    init_conc = 150;
    feed_flow = 200;
    perm_flow = 10;
    feed_cond = 50;
    perm_cond = 7;
    squishy_processing(init_conc, feed_flow, perm_flow, feed_flow, perm_cond,timestep)
end    