function [tiGypsum] = indtimeGypsum(SI)
% returns the nucleation induction time of Gypsum in seconds given SI
%
% from:
% https://doi.org/10.1006/jcis.1994.1042  
% http://dx.doi.org/10.1016/j.watres.2018.01.060

for i=1:length(SI)

if SI(i) < 0 % avoid returning complex values
	tiGypsum(i) = 1e15;
elseif SI(i) <= 0.2015
	tiGypsum(i) = 55.5*SI(i)^(-4.701);
elseif SI(i) >= 0.657
	tiGypsum(i) = 47.4*SI(i)^(-4.858);
else
	indTimeHe = [265 402 500 590 752 985 1111 2052 4057 6402 14691 24000 110400];
	satStatesHe = [4.54 4.46 4.13 4.03 3.72 3.29 3.23 3.02 2.73 2.33 2.03 1.95 1.59]; % log(satStates) = SI;
	satIndicesHe = log10(satStatesHe);
	tiGypsum(i) = interp1(satIndicesHe,indTimeHe,SI(i));

% 	if isnan(tiGypsum(i))
% 		keyboard
% 	end
end



end

end

