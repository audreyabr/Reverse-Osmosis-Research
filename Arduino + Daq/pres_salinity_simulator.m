function [tank_empty_vol,tank_full_vol,batch_vol,brine_vol,brine_concn,min_feed_pres,batch_conductivity,brine_conductivity,grams_CaCl_dihydrate,grams_Na2SO4,feed_vol_gallon,batch_number, tot_Na2SO4, tot_CaCl, ini_flowrate_ml_min] = pres_salinity_simulator(feed_concn,batch_time,RR,ini_flux,total_time)
% calculate batch volume(L), volume of full and empty(cm), minimal feed
% pressure(psi), brine conductvity(mS), Na2SO4 and CaCl2-H2O needed(g)
% based on intended feed concentration(mM), batch time(hour), average
% flux(L/m2.h) and recovery rate(%)

% constants
membrane_area = 0.0238; % m^2 (SW measurement feed side, 2019 module)
T = 25 + 273.15; % Kelvin, tempareture of water
flush_tube_volume = 0.50; % L, estimated with current tubing loop (remeasure!)
Kw = 2.6; %L/m2.h.bar, calculated with BW30-4040 membrane and adjusted based on test data

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
avg_flowrate = 0.75 * ini_flowrate; % L/h
batch_vol = batch_time * avg_flowrate; % L
brine_vol = batch_vol * (1 - RR); % L

% calculate tank full and empty volume
tank_empty_vol = 1000 * (brine_vol - flush_tube_volume); % ml (main run function takes volume in ml)
tank_full_vol = 1000 * batch_vol; % ml

% calculate Na2SO4 and CaCl2-H2O mass
[grams_CaCl_dihydrate,grams_Na2SO4]= CaSO4_mixing(feed_concn/1000, batch_vol);% inputs: concentration(mol/L)
                                                                              %         volume(L)
                                                                              % outputs: grams per batch
% calculate conductivities
brine_conductivity = condu_concen_converter(brine_concn/1000,"concentration"); % mS/cm, converter takes in concn in M
batch_conductivity = condu_concen_converter(feed_concn/1000,"concentration"); % mS/cm

% estimate total feed water volume base on initial conditions
batch_number = total_time / batch_time;
feed_vol = batch_number * batch_vol; % L
feed_vol_gallon = 0.2642 * feed_vol; % gallon
tot_CaCl = grams_CaCl_dihydrate * batch_number;
tot_Na2SO4 = grams_Na2SO4 * batch_number;

end

