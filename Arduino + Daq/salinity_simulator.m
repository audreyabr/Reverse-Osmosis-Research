function [dist_full,dist_empty,batch_vol,brine_vol,brine_concn,min_feed_pres,batch_conductivity,brine_conductivity,grams_CaCl_dihydrate,grams_Na2SO4] = salinity_simulator(feed_concn,batch_time,RR,avg_flux)
% calculate batch volume(L), distance of full and empty(cm), minimal feed
% pressure(psi), brine conductvity(mS), Na2SO4 and CaCl2-H2O needed(g)
% based on intended feed concentration(mM), batch time(hour), avrage flux 
% and recovery rate(%)

% constants
membrane_area = 0.0238; % m^2 (SW measurement feed side, 2019 module)
T = 25 + 273.15; % Kelvin, tempareture of water
flush_tube_volume = 0.10; % L, estimated with current tubing loop (remeasure!)
Kw= 3.39755; %L/m2.h.bar, calculated with BW30-4040 membrane
unit_condu = 0.495;    % mS/cm, conductivity of 1mM of CaSO4 and 2mM of NaCl

% calculate for minimal hydraulic pressure
brine_concn = feed_concn / (1 - RR);% mM,concentration of CaSO4 in brine
feed_osmotic = 8.314 * T * 6 * feed_concn / 1000;% kPa, feed osmotic pressure calculated by van't Hoff equation
feed_membrane_osmotic = 0.1450 * 1.1 * feed_osmotic; % psi, feed osmotic pressure at membrane converted to psi
brine_osmotic =  8.314 * T * 6 * brine_concn / 1000;% kPa, brine osmotic pressure
brine_membrane_osmotic = 0.1450 * 1.1 * brine_osmotic; % psi, brine osmotic pressure at membrane converted to psi

% calculate for batch volume
avg_osmotic =(feed_membrane_osmotic + brine_membrane_osmotic) / 2; % psi
min_feed_pres = avg_flux / Kw / 0.06895 + avg_osmotic  ; %psi, minimal hydraulic pressure needed
avg_flowrate = avg_flux * membrane_area; % L/h
batch_vol = batch_time * avg_flowrate; % L
brine_vol = batch_vol * (1 - RR); % L

% calculate tank distances of full and empty
dist_empty = Reverse_Tank_Calculation(max(0,brine_vol - flush_tube_volume));
dist_full = Reverse_Tank_Calculation(batch_vol);

% calculate Na2SO4 and CaCl2-H2O mass
[grams_CaCl_dihydrate,grams_Na2SO4]= CaSO4_mixing(feed_concn/1000, batch_vol);% inputs: concentration(mol/L)
                                                                              %         volume(L)
% calculate conductivities
brine_conductivity = brine_concn * unit_condu; % mS
batch_conductivity = feed_concn * unit_condu; % mS
end

