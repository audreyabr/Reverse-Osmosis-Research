clear all 

a = arduino ('COM8', 'Mega2560', 'Libraries','Ultrasonic')

% Pinouts 
triggerPin= 'D8';
echoPin = 'D9';


ultrasonicObj = ultrasonic(a,triggerPin, echoPin, 'OutputFormat','double')

for loop = 1:500
    distance = 39.3701 * readDistance(ultrasonicObj) %inches
    
    pause(1)
end 