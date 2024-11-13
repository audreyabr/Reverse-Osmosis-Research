function [permeate_flowrate, batch_flowrate] = dataCollection(daqName)  

 % Initialize 
    index = 25;
    voltage_list = [];

    % taking multiple readings from each input pin
    for i = 1:index
        daqName.Rate = 5000;
        display(read(daqName, "OutputFormat", "Matrix"))
        voltage_list(i,1:2) = read(daqName, "OutputFormat", "Matrix");

    end 
    % calculate average for flowrates voltages
    mean_voltage_list = mean(voltage_list(:,1:2));
    permeate_voltage = mean_voltage_list(1);
    batch_voltage = mean_voltage_list(2);

    % convert voltage values into flowrates
    permeate_flowrate = permeate_voltage *20;
    batch_flowrate = batch_voltage *200;

end