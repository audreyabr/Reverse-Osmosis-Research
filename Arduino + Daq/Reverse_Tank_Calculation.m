function ultrasoni_distance = Reverse_Tank_Calculation(volume)
    % volume: batch volume (L)
    volume = volume * 1000; % convert to ml
    
    % Tank constant parameters
    % Captalized variables are constant dimension of the tank
    % Lowercase variables are specific height calculated based on volume
    TANK_HEIGHT = 29.87; % cm, total height of whole tank below sensor
    TUBE_AREA = 4.11; % cm2,tube caliber
    TUBE_HEIGHT = 2.286; % cm, tank bottom to tube top
    SQUARE_HEIGHT = 1.5875 + TUBE_HEIGHT; % cm, tank bottom to square top
    SQUARE_AREA = 4.953* 4.953; % cm2,cross-section area of bottom square
    TRI_HEIGHT = 11.7; % cm, tank bottom to triangular top
    REC_AREA = 29.845 * 17.145; % cm2
    TUBE_VOL = TUBE_AREA * TUBE_HEIGHT; % ml, only tube volume
    TRI_VOL = 1.4888e+03; % ml, only triangular volume
    SQUARE_VOL = 1.5875 * SQUARE_AREA;% ml, total square volume
    REC_VOL = 5.2799e+03; % cm3, max volume is approximately upto batch valve

    if volume <= TUBE_VOL && volume > 0 % tube
        height = volume / TUBE_SQUARE;
    elseif volume <= SQUARE_VOL + TUBE_VOL % tube and square
        sqr_vol = volume - TUBE_VOL;
        sqr_height = sqr_vol / SQUARE_AREA;
        height = sqr_height + TUBE_HEIGHT;
    elseif volume <= TRI_VOL + SQUARE_VOL + TUBE_VOL % tube,square and triangular
        tri_vol  = volume - SQUARE_VOL - TUBE_VOL;
        tri_height = Reverse_V_trian(tri_vol);
        height = tri_height + SQUARE_HEIGHT;
    elseif volume <= TRI_VOL + SQUARE_VOL + REC_VOL + TUBE_VOL % tube, square, triangular and rectangular
        rec_vol = volume - SQUARE_VOL - TRI_VOL - TUBE_VOL;
        rec_height = rec_vol / REC_AREA;
        height = TRI_HEIGHT + rec_height;
    else
        height = NaN;
    end
    
    if height <= TANK_HEIGHT & height > 0
        ultrasoni_distance = TANK_HEIGHT - height; %cm, convert height(from bottom
                                               %    to waterline) to
                                               %    distance measured by
                                               %    ultrasonic from the top
    else
        ultrasoni_distance = TANK_HEIGHT - height;
        disp("volume invalid")
    end
end 
%% calculation based on SolidWorks model 
% function h = Reverse_V_trian(volume)
%     syms h_trian
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
%     equ = V_1 + V_2 + V_3 == volume;
%     h = vpasolve(equ, h_trian,[-Inf Inf]);
% end
%% Calculation based on data and polynomial equation 
function h = Reverse_V_trian(volume)
    if volume <= 0
        h = 0;
    else % water level within triangular zone
        syms h_trian
        TANK_HEIGHT = 29.87;
        SQUARE_HEIGHT = 3.8735; % cm, tank bottom to square top
        TRI_HEIGHT = 11.7; % cm, tank bottom to triangular top
        UPTO_SQUARE_VOL = 48.3403; % cm3, volume up to the bottom of tri zone
        x = TANK_HEIGHT -(SQUARE_HEIGHT + h_trian); % cm,ultrasonic distance
        total_volume = 18412 - 1384 * x + 26.1 * x^2;
        tri_volume = total_volume - UPTO_SQUARE_VOL == volume;
        h = double(vpasolve(tri_volume, h_trian,[0 TRI_HEIGHT-SQUARE_HEIGHT]));
    end 
end


