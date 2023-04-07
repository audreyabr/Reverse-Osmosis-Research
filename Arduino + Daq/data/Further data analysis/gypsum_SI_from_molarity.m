function [saturation_index] = gypsum_SI_from_molarity(CaSO4_molarity)
%by Emily 6/28/22
%Calculates saturation index of gypsum (CaSO4-dihydrate) from molarity of
%CaSO4 in aqueous solution with twice the gypsum molarity of Na and Cl
%based on interpolation of PHREEQC output SI

%Inputs:
%CaSO4 molarity in mol/L

CaSO4_molality=CaSO4_molarity;%assuming low-salinity water with density approximately 1 kg/L
saturation_index = 0.527*log(CaSO4_molality*1000) - 1.5073;

%     if (saturation_index > 0.6) || (saturation_index < 0)%limits output to range of correlation
%         saturation_index = NaN;
%     end
end
