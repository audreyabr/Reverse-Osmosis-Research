function [conductivity_list,conductivity] = conductivity_reading_daq(daqName, conductivity_list)

% Takes in the current conductivity list, takes the next
% conductivity reading and appends it onto the list


% Args: 
%       conductivity_list: an array of conductivity readings (mS)
%       arduino_object: the specific arduino we're using 
%       cond_pin_pos: Pin number of the input voltage (around 5V) of the 
%                     resistor being used to measure conductivity
%       cond_pin_neg: Pin number of the output voltage of the resistor 
%                     being used to measure conductivity

% Returns: 
%       conductivity_list: the list of conductivity readings over time

    R = 200; % resistance in ohms - 
    % this value is chosen so that cond_pin_neg voltage is between 1V
    % and 4.2V
    
    voltage = read(daqName, "OutputFormat", "Matrix");
    I = voltage(3) / R; % I in A
    K = 100;
    conductivity = (2000* (I * 1000 - 4)) / (16 * K); % I in mA

    % note that the code below has been modified to remove outliers from
    % the data using the matlab function remoutliers

    % multiple data points are taken, outliers removed, then the remaining
    % points are averaged

    % however, the voltage reading is simply the average of all of the 
    % voltages taken, including those attached to outliers


%     index = 5;
%     for i = 1:index
%         voltage_list(i,1) = readVoltage(arduino_object,cond_pin); % voltage read from voltmeter
%     end
%         
%     vIN = voltage_list / (R2/(R1+R2)); % actual voltage read over Resistor R from conductivity sensor
%     conductivity_list = ((2000 * vIN)/(16*0.001*R*K)) - ((4*2000)/(K*16)); % display conductivity
%     no_outliers = rmoutliers(conductivity_list);
%     conductivity = sum(no_outliers)/length(no_outliers)
% 
%     voltage = mean(voltage_list);
    
    % error = (1.2188 * conductivity) + 5;
    % actual_conductivity = conductivity - error
    
    
    conductivity_list(end+1, 1:2) = [conductivity, voltage(3)];
    
end
