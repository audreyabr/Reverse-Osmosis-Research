function tank_is_empty = check_tank_empty(empty_tank_distance, last_distance)

% Checks if the batch tank is empty. 
%    
% Args:
%     last_distance: An integer representing the batch tank distance                             
% Returns:
%     tank_is_empty: 0 if the batch tank is not empty or 1 if the batch
%     tank is empty

if last_distance >= empty_tank_distance
    tank_is_empty = 1;
    disp("TANK IS EMPTY")
    
end
