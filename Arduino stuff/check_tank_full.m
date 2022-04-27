function tank_is_full = check_tank_full(full_tank_distance, last_distance)
 
% Checks if the batch tank is full. 
%    
% Args:
%     last_distance: An integer representing the batch tank distance                             
% Returns:
%     tank_is_full: 0 if the batch tank is not full or 1 if the batch tank is full 
 
tank_is_full = 0  
if last_distance <= full_tank_distance
    tank_is_full = 1 
("TANK IS FULL")
    
end
