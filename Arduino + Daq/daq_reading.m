function [permeate_flowrate_list, permeate_flowrate, batch_flowrate_list, batch_flowrate, conductivity_list, conductivity] = daq_reading(daqName, permeate_flowrate_list, batch_flowrate_list, conductivity_list)
%it read this before: function [voltage_list, permeate_flowrate_list, permeate_flowrate, batch_flowrate_list, batch_flowrate, conductivity_list, conductivity] = daq_reading(daqName, permeate_flowrate_list, batch_flowrate_list, conductivity_list)

    % Initialize 
    index = 25;
    voltage_list = [];
    conductivity_voltage_list_rmo = [];

    % taking multiple readings from each input pin
    for i = 1:index
        daqName.Rate = 5000;
        voltage_list(i,1:3) = read(daqName, "OutputFormat", "Matrix");

    end 

    % calculate average for flowrates voltages
    mean_voltage_list = mean(voltage_list(:,1:2));
    permeate_voltage = mean_voltage_list(1);
    batch_voltage = mean_voltage_list(2);

    % remove outliers and calculate average for conductivity voltages
    conductivity_voltage_list_rmo = rmoutliers(voltage_list(:,3));
    conductivity_voltage = mean(conductivity_voltage_list_rmo);

    % convert voltage values into flowrates
    permeate_flowrate = permeate_voltage *20;
    batch_flowrate = batch_voltage *200;

    % append to flowrate lists
    permeate_flowrate_list(end+1,1) = permeate_flowrate;
    batch_flowrate_list(end+1,1) = batch_flowrate;
    
    % convert voltage values into conductivity
    R = 200; % resistance in ohms - 
    % this value is chosen so that cond_pin_neg voltage is between 1V
    % and 4.2V
    I = conductivity_voltage / R; % I in A
    K = 100;
    conductivity = (2000* (I * 1000 - 4)) / (16 * K); % I in mA

    % append to conductivity list
    conductivity_list(end+1,1) = conductivity;
end