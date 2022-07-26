function vol = Water_Tank_Calculations_3(ultra_dist)
    %dimension constants of the tank
    %Lowercase variables are specific height calculated based on volume
    TANK_HEIGHT = 29.87; % cm, total height of whole tank below sensor
    TUBE_AREA = 4.11; % cm2,tube caliber
    TUBE_HEIGHT = 2.286; % cm, tank bottom to tube top
    SQUARE_HEIGHT = 1.5875 + TUBE_HEIGHT; % cm, tank bottom to square top
    SQUARE_AREA = 4.953* 4.953; % cm2,cross-section area of bottom square
    TRI_HEIGHT = 11.7; % cm, tank bottom to triangular top
    REC_AREA = 29.845 * 17.145; % cm2
    
    
    h_overall = TANK_HEIGHT - ultra_dist;
    
    %find volume of rectangle portion at the top
    if h_overall > TRI_HEIGHT  % max heights of square + triangle in cm
        h_rectangle = h_overall - TRI_HEIGHT;
    else
        h_rectangle = 0;
    end

    %find volume of triangular volume
    if h_overall > TRI_HEIGHT
        h_triangle = TRI_HEIGHT - SQUARE_HEIGHT; % full relative tri height
    elseif h_overall <= TRI_HEIGHT && h_overall > SQUARE_HEIGHT
        h_triangle = h_overall - SQUARE_HEIGHT;
    else
        h_triangle = 0;
    end
    
    %find volume of square portion at the bottom
    if h_overall > SQUARE_HEIGHT
        h_square = SQUARE_HEIGHT - TUBE_HEIGHT;
    elseif h_overall <= SQUARE_HEIGHT && h_overall > TUBE_HEIGHT
        h_square = h_overall - TUBE_HEIGHT;
    else
        h_square = 0;
    end

    %find volume of tube portion at the bottom
    if h_overall > TUBE_HEIGHT 
        h_tube = TUBE_HEIGHT;
    elseif h_overall <= TUBE_HEIGHT
        h_tube = h_overall;
    end
    
    triangle_vol = V_trian(h_triangle);
    vol = h_tube * TUBE_AREA + h_square * SQUARE_AREA + triangle_vol + h_rectangle * REC_AREA;
end

%% calculation based on SolidWorks model
% error: around 200ml
% function res = V_trian(h_trian)
%     w_1 = 4.953; % cm
%     w_2 = 4.953 + 1.283 * h_trian;
%     w_3 = 0.628 * h_trian;
%     L_1 = 4.953; % cm
%     L_2 = 3.05 * h_trian;
% 
%     V_1 = h_trian * 0.5 * (w_1 + w_2) * L_1;  % volume of trapezoidal prism
%     V_2 = h_trian * (2/3) * L_2 * w_3;    % volume of the 2 pyramids combined
%     V_3 = h_trian * 0.5 * L_2 * w_1;      % volume of triangular prism
% 
%     res = V_1 + V_2 + V_3;
% end
%% Water tests for above:
% Input volume: 200 mL 
% Measured height: 23.96
% Calculated height: 23.464
% 
% Input volume: 600 mL 
% Measured height: 21.02
% Calculated height: 20.99
% 
% Input volume: 1000 mL 
% Measured height: 19.82
% Calculated height: 19.53
% 
% Input volume: 1600 mL 
% Measured height: 18.679
% Calculated height: 18.0472
% 
% Input volume: 2400 mL 
% Measured height: 17.2345
% Calculated height: 16.4837
% 
% Input volume: 3200 mL 
% Measured height: 15.49
% Calculated height: 14.9203
%% Calculation based on data and polynomial equation
% error: within 100mL
function tri_volume = V_trian(h_trian)
    %See google sheet 'experimental curve for volume to distance
    %calculations' for calculation details.

    %h_trian: relative water distance(cm) only in the triangular volume area
    %total_volume: total volume in all shapes(ml) subtracted by volumes in
    %shapes other than triangle.
    
    % No water in triangular zone
    if h_trian <= 0
        tri_volume = 0;
    else % water level within triangular zone
        TANK_HEIGHT = 29.87;
        SQUARE_HEIGHT = 3.8735; % cm, tank bottom to square top
        UPTO_SQUARE_VOL = 48.3403; % cm3, volume up to the bottom of tri zone
        x = TANK_HEIGHT -(SQUARE_HEIGHT + h_trian); % cm,ultrasonic distance
        total_volume = 19391 - 1498 * x + 29 * x^2;
        tri_volume = total_volume - UPTO_SQUARE_VOL;
    end
    
end


