function [brine_salinity,brine_conductivity,batch_salinity,batch_conductivity] = salinity_simulator(salt_name)

% input theoratical batch distances, salinity, and brine volume
empty_dis = input("empty distance: "); % cm
full_dis = input("full distance: "); % cm
batch_salinity = input("Feed salinity(mM): ");
brine_vol = input("brine volume: "); % ml

% constants
tank_height = 29.845; % cm

if salt_name == "NaCl"||salt_name == "nacl"||salt_name == "sodium chloride"
    cond_at_1pct = 17.6;    % conductivity in mS/cm for 1% NaCl
    molar_mass = 58.44; % g/mol
end

if salt_name == "CaSO4"||salt_name == "caso4"||salt_name == "calcium sulfate"
    cond_at_1pct = 17.6;    % conductivity in mS/cm for 1% NaCl
    molar_mass = 136.14; % g/mol
end

% calculation
batch_vol = Water_Tank_Calculations(tank_height - full_dis) - Water_Tank_Calculations(tank_height - empty_dis); % ml
RR = (batch_vol - brine_vol) / batch_vol;

brine_salinity = batch_salinity/(1-RR); % milimolar - 1/1000mol/L (RR: recovery rate)
brine_salinity_pct = 100 * (((brine_salinity / 1000) * molar_mass) / 1000); % assume water density is 1000g/L
brine_conductivity = brine_salinity_pct * cond_at_1pct;

batch_salinity_pct = 100 * (((batch_salinity / 1000) * molar_mass) / 1000); % in percent
batch_conductivity = batch_salinity_pct * cond_at_1pct; % mS

% output brine salinity and conductivity range
disp("batch conductivity(mS): " + batch_conductivity)
disp("brine conductivity(mS): " + brine_conductivity)
disp("salinity range of this batch(mM): " + batch_salinity + " to " + brine_salinit)
end

