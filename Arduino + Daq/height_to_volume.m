function volume = height_to_volume(height)
% This function takes in height of water level calculated based on the
% pressure transmitter readings and tank dimensions. It returns the tank water volume 
% (not including water volume in the loop)

% convert height measured by pressure sensor to tank water height
BOTTOM_TO_SENSOR = 5.5  ; %cm, distance between sensor and tank bottom
tank_height = height - BOTTOM_TO_SENSOR; %cm, water height IN the tank

% constants (from tank CAD datasheet)
TUBE_HEIGHT = 2.286; % cm, tank bottom to tube top
SQUARE_HEIGHT = 3.8735; % cm, tank bottom to square top
TRI_HEIGHT = 11.7; % cm, tank bottom to triangular top
TUBE_AREA = 4.11; % cm2,tube caliber
SQUARE_AREA = 4.953* 4.953; % cm2,cross-section area of bottom square

if tank_height < 0
    % no water in tank
    volume = 0;
    
elseif tank_height > 0 && tank_height <= TUBE_HEIGHT
    % below tube top
    volume = tank_height * TUBE_AREA;
     
elseif tank_height > TUBE_HEIGHT && tank_height <= SQUARE_HEIGHT
    % below square top
    % volume upto square top: 35.5ml
    volume = SQUARE_AREA * TUBE_HEIGHT + (tank_height - TUBE_HEIGHT) * SQUARE_AREA;

elseif tank_height > SQUARE_HEIGHT && tank_height <= TRI_HEIGHT
    % below triangular top
    % this function is best-fit curve found in
    % volume_vs_height_data_plot.mlx
    vol_in_tri = 0.7 * height^3 + 6.8 * height^2 - 385.9 * height + 2605.9;
    volume = vol_in_tri; 
    
elseif tank_height > TRI_HEIGHT
    % enters rectangular part
    % this function is best-fit curve found in
    % volume_vs_height_data_plot.mlx
    vol_in_rec = 501 * height - 7116;
    volume = vol_in_rec;
end 
    
end

