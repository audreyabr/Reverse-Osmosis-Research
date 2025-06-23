function trial = filter_and_process(trial)
%%Calculate new variable for experiment
    for i = 1:size(trial,2)
        
        trial(i).batchFlowMean = mean(trial(i).batch_flowrate_list);
        trial(i).permeateFlux = trial(i).permeate_flowrate_list * .06 / 21982.45e-6;
        trial(i).concentration = (trial(i).ConductivityStart - 0.656)/323.55;
        trial(i).membraneConcentration = concentrationPolarization(trial(i).batch_flowrate_list, trial(i).permeate_flowrate_list, trial(i).concentration);
        trial(i).membraneConcentrationMean = mean(trial(i).membraneConcentration);
        if(isnan(trial(i).ScaleTime1))
            trial(i).batchFlowPrescaleMean = NaN;
            trial(i).membraneConcentrationPrescaleMean = NaN;
        elseif(isempty(trial(i).time_list) || trial(i).ScaleTime1 > (trial(i).time_list(end))/60)
            trial(i).batchFlowPrescaleMean = trial(i).batchFlowMean;
            trial(i).membraneConcentrationPrescaleMean = trial(i).membraneConcentrationMean;
        else
            trial(i).batchFlowPrescaleMean = mean(trial(i).batch_flowrate_list(trial(i).time_list < trial(i).ScaleTime1*60));
            trial(i).membraneConcentrationPrescaleMean = mean(trial(i).membraneConcentration(trial(i).time_list < trial(i).ScaleTime1*60));
        end
    end
%%Filter Data
    for i = 1:size(trial,2)
        disp("Trial #" + i)
        if(~isempty(trial(i).time_list) && ~isnan(trial(i).concentration))
        trial(i).batchFlowrateFiltered = lowpass(trial(i).batch_flowrate_list, .1);
        trial(i).permeateFlowrateFiltered = lowpass(trial(i).permeate_flowrate_list, .1);
        trial(i).membraneConcentrationFiltered = lowpass(trial(i).membraneConcentration, .1);
        trial(i).permeateFluxFiltered = lowpass(trial(i).permeateFlux, .1);
        end
    end
end