function add_water_vol = ethanol_mixing(ethanol_vol, ethanol_concn)
%This function calculates how much water and ethanol of a given
%concentration should be mixed together to produce 50% ethanol solution for
%soaking new membrane.
%ethanol_concn: Concentration(%) of ethanol.
%ethanol_vol: volume(mL)of the given concentration ethanol in use.
pure_ethanol = ethanol_vol * ethanol_concn;%pure ethanol(mL)in initial solution
tot_water_vol = pure_ethanol;% total water vol(ml) of pure ethanol made into 50%
add_water_vol = tot_water_vol - (ethanol_vol - pure_ethanol);% add water volume(mL)
end

