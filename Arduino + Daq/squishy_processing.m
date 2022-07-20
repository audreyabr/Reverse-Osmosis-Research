function [salt_rej, mem_CaSO4_conc, conc_polar,SI_gypsum, ind_time, nucl_prob]...
    = squishy_processing(init_conc,feed_flow,perm_flow,feed_cond,perm_cond,timestep)
%by Diana last upload to google drive 7/20/22 around 4:30pm pacific
% next things to do
% - find a way to integrate the time step
%   > I would if that would be in this function or in an outer file that
%       would run the loop

% Inputs
% init_conc - intial concentration in mol/L
% feed_flow - feed flowrate in mL/m
% perm_flow - permeate flowrate in mL/m
% feed_cond - feed conductivity
% perm_cond - permeate conductivity

% initializing the time step - I feel like this might have to happen outside
% the function hmmm
%timestep = linspace(0,100,10) % need to figure how to keep time/ need to make for loop
% time = time_list(1:end-1,:);  this came from data_analysis_arduino file
% what does it mean?

% initializing variables
mem_const = 0.99 % membrane constant (K)

% Calculating Salt Rejection
salt_rej = [1-(perm_cond)/mean(feed_cond)] % salt rejection

% Calculating CaSO4 Concentration at the membrane
recovery = (perm_flow/feed_flow)*100  % expressed in terms of percentage
mem_CaSO4_conc = (1/(1-recovery)) * init_conc % membrane CaSO4 concentration
conc_polar = mem_const * exp(perm_flow/mean(feed_flow)) % concentration polarization

% Calculating Saturation Index of Gypsum
SI_gypsum = 0.527 * log(init_conc) - 1.5073 

% Calculating the nucleation induction time of Gypsum
ind_time = 1.66*(10^6)*(exp(-0.174*init_conc)) % Induction Time in seconds (s)

% Integrating the Induction Rate over all timepsteps
C_t = mem_CaSO4_conc/timestep    % concentration as a funciton of time
% need the figure this out better, might not be it
nucl_prob = int(1/(ind_time*C_t),0,timestep)  % nucleation probability
% need to figure out the integrating over the timesteps
% and how to use the int for integration function in matlab
end
