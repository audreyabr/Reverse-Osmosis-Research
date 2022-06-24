function conductivity_list = conductivity_reading(arduino_object, conductivity_list, cond_pin)

% Takes in the current conductivity list, takes the next
% conductivity reading and appends it onto the list

% Make sure that the Vcc voltmeter wire is plugged into the right pin on the
% Arduino and the Gnd wire plugging into Gnd on the Arduino.

% Args: 
%       conductivity_list: an array of conductivity readings (mS)
%       arduino_object: the specific arduino we're using 

% Returns: 
%       conductivity_list: the list of conductivity readings over time

    R = 1000; % resistance in ohms - I chose this because the voltage out 
    %          would be between 0 and 25 volts and can be measured by the
    %          arduino directly: 0.02 A (max A) * 1000 ohms  = 20 V
    K = 100; % K value specified by manufacturer
    R1 = 30000; % voltmeter resistor 1 
    R2 = 7500; % voltmeter resistor 2
    



    % note that the code below has been modified to remove outliers from
    % the data using the matlab function remoutliers

    % multiple data points are taken, outliers removed, then the remaining
    % points are averaged

    % however, the voltage reading is simply the average of all of the 
    % voltages taken, including those attached to outliers


    index = 5;
    for i = 1:index
        voltage_list(i,1) = readVoltage(arduino_object,cond_pin); % voltage read from voltmeter
    end
        
    vIN = voltage_list / (R2/(R1+R2)); % actual voltage read over Resistor R from conductivity sensor
    conductivity_list = ((2000 * vIN)/(16*0.001*R*K)) - ((4*2000)/(K*16)); % display conductivity
    no_outliers = rmoutliers(conductivity_list);
    conductivity = sum(no_outliers)/length(no_outliers)

    voltage = mean(voltage_list);
    
    % error = (1.2188 * conductivity) + 5;
    % actual_conductivity = conductivity - error
    
    conductivity_list(end+1, 1:2) = [conductivity, voltage];
    
end
