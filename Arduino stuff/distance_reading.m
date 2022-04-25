function [distance_list, distance]  = distance_reading(arduino_object, distance_list, triggerPin, echoPin)

% Takes in the current distance list, takes the next
% distance reading and appends it onto the list

% Args: arduino_object = the specific arduino we're using 
%       distance_list - an array of distance readings (cm)

% Returns: distance_list - the list of distance readings (cm)

    ultrasonicObj = ultrasonic(arduino_object, triggerPin, echoPin, 'OutputFormat','double')
    distance = readDistance(ultrasonicObj)
    distance_list(end+1, 1) = distance
    
end
