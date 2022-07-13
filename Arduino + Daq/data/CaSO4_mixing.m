function [grams_CaCl_dihydrate,grams_Na2SO4] = CaSO4_mixing(concentration,volume)
%CaSO4_to_indv_grams calcates the grams of CaCl-dihydrate and Na2SO4

%written by Diana 6/27/22
%Emily made 3 updates 6/28/22
    %Changed molar mass of calcium salt to 147.01 [g/mol] because we have calcium
        %chloride dihydrate, which has 2 water molecules per molecule of
        %salt, in lab (also changed name of output to refect that)
    %Stylistic:
        %Changed capitalization of CaSO4 (O is capital bc oxygen)
        %Changed mol to molarmass and moles because the same name ("mol") was 
            %being used for different things
    

%Units
%concentration units = mol/L
%volume = Liters(L)

% Parameters
molarmass_CaClDH = 147.01;      % molar mass of CaCl+2(H2O) (g/mol)
molarmass_Na2SO4 = 142.04;    % molar mass of Na2SO4 (g/mol)

%Equations
moles_CaSO4 = concentration * volume;       % finds the amount of moles of CaSO4
grams_Na2SO4 = moles_CaSO4 * molarmass_Na2SO4;   % finds the grams of Na2SO4
grams_CaCl_dihydrate = moles_CaSO4 * molarmass_CaClDH;       % find the grams of CaCl-dihydrate
end
