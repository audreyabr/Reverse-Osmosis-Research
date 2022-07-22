clear
clf

a = arduino ('COM5', 'Mega2560', 'Libraries','Ultrasonic');

% Pinouts 
triggerPin= 'D8';
echoPin = 'D9';
distance = [];


ultrasonicObj = ultrasonic(a,triggerPin, echoPin, 'OutputFormat','double');

for loop = 1:400
    distance(end+1) = 100 * readDistance(ultrasonicObj); %cm
    hold on
    scatter(loop,distance(end))
end 

avg_dist = mean(distance)
max_dist = max(distance)
min_dist = min(distance)


beep