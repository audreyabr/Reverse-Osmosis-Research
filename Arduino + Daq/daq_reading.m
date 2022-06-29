function [perm_flowrate_list, perm_flowrate, flowrate_list, flowrate, conductivity_list, conductivity] = daq_reading(daqName, perm_flowrate_list, flowrate_list, conductivity_list)

    voltage = read(daqName, "OutputFormat", "Matrix");
    
    %%
    % permeate flowrate
    perm_flowrate = voltage(1) * 20; % 20 calculated by max flow rate(100ml/min) / 5v 
   
    % this while loop checks for flowrate values and re-measures
    % in the case that the value is negative
    while perm_flowrate < 0
          voltage = read(daqName, "OutputFormat", "Matrix");
          perm_flowrate = voltage(1) * 20; % 20 calculated by max flow rate(100ml/min) / 5v 
    end

    perm_flowrate_list(end+1, 1) = perm_flowrate;
    %%

    % batch flowrate
    flowrate = voltage(2) * 200; % 200 calculated by max flow rate (1000ml/min) / 5v

    % this while loop checks for flowrate values and re-measures
    % in the case that the value is negative
    while flowrate < 0
          voltage = read(daqName, "OutputFormat", "Matrix");
          flowrate = voltage(2) * 200; % 20 calculated by max flow rate(100ml/min) / 5v 
    end

    flowrate_list(end+1, 1) = flowrate;
    %%

    % conductivity
    R = 200; % resistance in ohms - 
    % this value is chosen so that cond_pin_neg voltage is between 1V
    % and 4.2V
    
    I = voltage(3) / R; % I in A
    K = 100;
    conductivity = (2000* (I * 1000 - 4)) / (16 * K); % I in mA
    
    conductivity_list(end+1, 1:2) = [conductivity, voltage(3)];

end