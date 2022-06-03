function tank_state = check_tank_state(empty_tank_distance,full_tank_distance,last_distance)
% Checks if the batch tank is empty(tank_state=0), full(tank_state=2), 
% or neither(tank_state=1)
%    
% Args:
%     empty_tank_distance: A float number representing the threshold
%                           distance(cm) of an empty tank.
%     full_tank_distance: A float number representing the threshold
%                           distance(cm) of a full tank.
%     last_distance: An integer representing the batch tank distance(cm)
%
% Returns:
%     tank_state: 0 if the batch tank is empty, 2 if the batch is full,
%                 1 if it is neither. 

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