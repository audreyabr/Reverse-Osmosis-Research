function tank_state = pres_check_tank_state(empty_tank_volume,full_tank_volume,volume_list)
% Checks if the tank is empty(tank_state=0), full(tank_state=2), 
% or neither(tank_state=1)
%    
% Args:
%     volume(mL)
%
% Returns:
%     tank_state: 0 if the batch tank is empty, 2 if the batch is full,
%                 1 if neither. 

if volume_list(end) <= empty_tank_volume
    tank_state = 0;
    disp("TANK IS EMPTY...feed valve open")
    
elseif volume_list(end) >= full_tank_volume
    tank_state = 2;
    disp("TANK IS FULL...close feed valve ")
    
else
    tank_state = 1;
    disp("TANK IS NEITHER FULL NOR EMPTY")
    
end