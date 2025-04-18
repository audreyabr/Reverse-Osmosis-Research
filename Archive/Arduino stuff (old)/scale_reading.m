function [mass_list,mass] = scale_reading(serial_object, mass_list)

% Takes in the current mass list, takes the next
% mass reading and appends it onto the list

% Args: mass_list - an array of mass readings (g)
%       serial_object = the scale we're using 

% Returns: mass_list - the list of mass readings (g)
    
    a = fscanf(serial_object);% 
    b = strtrim(a);
    c = erase(b,"g");
    d = erase(c,"?");
    e = strtrim(d);
    mass = str2double(e);  
    mass_list(end+1, 1) = mass
    
end
