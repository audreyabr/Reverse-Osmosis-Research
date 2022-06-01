function tank_state = check_tank_state(last_distance)
% Checks if the batch tank is empty(tank_state=0), full(tank_state=2), 
% or neither(tank_state=1)
%    
% Args:
%     last_distance: An integer representing the batch tank distance in cm
% Returns:
%     tank_state: 0 if the batch tank is empty, 2 if the batch is full,
%                 1 if it is neither. 


empty_tank_distance = 25.5;  % cm, top of the tank to the top of the 
                             %drainage square with some extra room
full_tank_distance = 23;  % cm  (CHANGE LATER?)

if last_distance >= empty_tank_distance
    tank_state = 0;
    disp("TANK IS EMPTY")
    
elseif last_distance <= full_tank_distance
    tank_state = 2;
    disp("TANK IS FULL")
    
else
    tank_state = 1;
    disp("TANK IS NEITHER FULL NOR EMPTY")
    
end