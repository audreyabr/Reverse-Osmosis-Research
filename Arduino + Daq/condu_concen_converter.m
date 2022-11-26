function converted_value = condu_concen_converter(value,type)
% Base on concentration(M) vs. conductivity(mS/cm) best-fit curve, 
% translate one variable to the other
% Inputs
% value: concentration (M) or conductivity (mS/cm)
% type: (string)"concentration" or "conductivity", the type of input value


if type == "concentration"
    % convert concentration to conductivity
    conductivity  = 323.55 * value + 0.656;
    if conductivity < 0 
        conductivity = 0;
    end 
    converted_value = conductivity;

elseif type == "conductivity"
    % convert conductivity to concentration
    concentration = (value - 0.656) / 323.55;
    if concentration < 0 
        concentration = 0;
    end 
    converted_value = concentration;
else 
    disp("enter: value,type")
end  
end

