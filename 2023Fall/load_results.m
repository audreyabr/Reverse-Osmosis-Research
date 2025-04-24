function trial = load_results(trial)
results = readtable("C:/Users/tewald/Downloads/Results2025")

%%%Assign Conducitivy at Start to Trial Matrix
for i = 1:size(trial,2)
    if ismember(i, results.TrialNumber) %%%Check Trial is in Matrix
        trial(i).ConductivityStart = results.ConductivityStart(results.TrialNumber == i);
        trial(i).ConductivityEnd = results.ConductivityEnd(results.TrialNumber == i);
        trial(i).StartTime = results.StartTime(results.TrialNumber == i);
        trial(i).StartDate = results.StartDate(results.TrialNumber == i);
        trial(i).ScaleTime1 = results.ScaleTime1_min_(results.TrialNumber == i);
        trial(i).ScaleTime2 = results.ScaleTime2_min_(results.TrialNumber == i);
    else
        trial(i).ConductivityStart = NaN;
        trial(i).ConductivityEnd = NaN;
        trial(i).StartTime = '';
        trial(i).StartDate = '';
        trial(i).ScaleTime1 = NaN(1);
        trial(i).ScaleTime2 = NaN(1);

    end

end




end