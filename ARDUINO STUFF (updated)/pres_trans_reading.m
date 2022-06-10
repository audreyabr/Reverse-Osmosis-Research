function [pres_trans_list, pres_trans_value] = pres_trans_reading(arduino_object, pres_trans_list, pressure_transducer_pin)

%Records the data coming in from the pressure transducer
%Args:
%    arduino_object = the specific arduino we are using
%    pres_trans = an array of pressure transducer reading

%Return:
%    pres_trans_list = the list of permeate tranducer readings
%    pres_trans_value = the current value of pressure transducer value

    pres_trans_volts = readVoltage(arduino_object, pressure_transducer_pin); % can only read from 0V to 5V
    
    pres_trans_value = 3 * pres_trans_volts;
    pres_trans_list(end+1,1 )= pres_trans_value;

end
