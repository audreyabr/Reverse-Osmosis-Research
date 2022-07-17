function [dist_full,dist_empty,batch_vol,brine_vol,min_feed_pres,batch_conductivity,brine_conductivity,grams_CaCl_dihydrate,grams_Na2SO4] = salinity_simulator(feed_concn,batch_time,RR)
% calculate batch volume(L), distance of full and empty(cm), minimal feed
% pressure(psi), brine conductvity(mS), Na2SO4 and CaCl2-H2O needed(g)
% based on intended feed concentration(mM), batch time(hour) and recovery rate(%)

% constants
membrane_area = 0.0238; % m^2 (SW measurement feed side, 2019 module)
T = 25 + 273.15; % Kelvin, tempareture of water
flush_tube_volume = 0.170; % L, estimated with current tubing loop
Kw= 3.39755; %L/m2.h.bar, calculated with BW30-4040 membrane
cond_at_01pct = 3.2;    % measured conductivity in mS/cm for 0.1% CaSO4
molar_mass_CaSO4 = 147.01; % g/mol

% calculate for minimal hydraulic pressure
brine_concn = feed_concn / (1 - RR);% mM,concentration of CaSO4 in brine
feed_osmotic = 8.314 * T * 6 * feed_concn / 1000;% kPa, feed osmotic pressure calculated by van't Hoff equation
feed_membrane_osmotic = 1.1 * feed_osmotic; % kPa, feed osmotic pressure at membrane
brine_osmotic =  8.314 * T * 6 * brine_concn / 1000;% kPa, brine osmotic pressure
brine_membrane_osmotic = 1.1 * brine_osmotic; % kPa, brine osmotic pressure at membrane
min_feed_pres = 0.1450 * (brine_membrane_osmotic + 100); % psi, minimal hydraulic pressure needed

% calculate for batch volume
avg_osmotic =(feed_membrane_osmotic + brine_membrane_osmotic) / 2; % kPa
avg_flux = (min_feed_pres * 0.06895 - avg_osmotic * 0.01) * Kw; % L/m2.h, converted pressure to bar
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
brine_salinity_pct = 100 * (((brine_concn / 1000) * molar_mass_CaSO4) / 1000); %in percent, salinity of CaSO4
brine_conductivity = brine_salinity_pct * cond_at_01pct * 10; % mS
batch_salinity_pct = 100 * (((feed_concn / 1000) * molar_mass_CaSO4) / 1000); %in percent, salinity of CaSO4
batch_conductivity = batch_salinity_pct * cond_at_01pct * 10; % mS

end

