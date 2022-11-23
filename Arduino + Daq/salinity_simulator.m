function [dist_full,dist_empty,batch_vol,brine_vol,brine_concn,min_feed_pres,batch_conductivity,brine_conductivity,grams_CaCl_dihydrate,grams_Na2SO4,feed_vol_gallon,batch_number, tot_Na2SO4, tot_CaCl, ini_flowrate_ml_min] = salinity_simulator(feed_concn,batch_time,RR,ini_flux,total_time)
% calculate batch volume(L), distance of full and empty(cm), minimal feed
% pressure(psi), brine conductvity(mS), Na2SO4 and CaCl2-H2O needed(g)
% based on intended feed concentration(mM), batch time(hour), average flux
% (L/m2.h) and recovery rate(%)
% 

% constants
membrane_area = 0.0238; % m^2 (SW measurement feed side, 2019 module)
T = 25 + 273.15; % Kelvin, tempareture of water
flush_tube_volume = 0.30; % L, estimated with current tubing loop (remeasure!)
Kw= 2.6; %L/m2.h.bar, calculated with BW30-4040 membrane and adjusted based on test data
%unit_condu = 0.9796;    % mS/cm, conductivity of 1mM of CaSO4 and 2mM of NaCl

% calculate for minimal hydraulic pressure
brine_concn = feed_concn / (1 - RR);% mM,concentration of CaSO4 in brine
feed_osmotic = 8.314 * T * 6 * feed_concn / 1000;% kPa, feed osmotic pressure calculated by van't Hoff equation
feed_membrane_osmotic = 0.1450 * 1.1 * feed_osmotic; % psi, feed osmotic pressure at membrane converted to psi
brine_osmotic =  8.314 * T * 6 * brine_concn / 1000;% kPa, brine osmotic pressure
brine_membrane_osmotic = 0.1450 * 1.1 * brine_osmotic; % psi, brine osmotic pressure at membrane converted to psi

% calculate for batch volume
avg_osmotic =(feed_membrane_osmotic + brine_membrane_osmotic) / 2; % psi
min_feed_pres = ini_flux / Kw / 0.06895 + avg_osmotic; %psi, minimal hydraulic pressure needed
ini_flowrate = ini_flux * membrane_area; % L/h
ini_flowrate_ml_min = ini_flowrate * 1000 / 60; % convert to ml/min
batch_vol = batch_time * ini_flowrate; % L
brine_vol = batch_vol * (1 - RR); % L

% calculate tank distances of full and empty
dist_empty = Reverse_Tank_Calculation(max(0,brine_vol - flush_tube_volume));
dist_full = Reverse_Tank_Calculation(batch_vol);

% calculate Na2SO4 and CaCl2-H2O mass
[grams_CaCl_dihydrate,grams_Na2SO4]= CaSO4_mixing(feed_concn/1000, batch_vol);% inputs: concentration(mol/L)
                                                                              %         volume(L)
                                                                              % outputs: grams per batch
% calculate conductivities
brine_conductivity = condu_concen_converter(brine_concn,"concentration"); % mS/cm
batch_conductivity = condu_concen_converter(feed_concn,"concentration"); % mS/cm

% estimate total feed water volume base on initial conditions
batch_number = total_time / batch_time;
feed_vol = batch_number * batch_vol; % L
feed_vol_gallon = 0.2642 * feed_vol; % gallon
tot_CaCl = grams_CaCl_dihydrate * batch_number;
tot_Na2SO4 = grams_Na2SO4 * batch_number;

end

