function ultrasoni_distance = Reverse_Tank_Calculation(volume)
    % volume: batch volume (L)
    volume = volume * 1000; % convert to ml
    
    % Tank constant parameters
    % Captalized variables are constant dimension of the tank
    % Lowercase variables are specific height calculated based on volume
    TANK_HEIGHT = 29.845; % cm, total height of whole tank
    SQUARE_HEIGHT = 1.64846; % cm, tank bottom to square top
    SQUARE_AREA = 5.08 * 5.08; % cm2,cross-section area of bottom square
    SQUARE_VOL = SQUARE_HEIGHT * SQUARE_AREA;% ml, total square volume
    TRI_HEIGHT = 11.52652; % cm, tank bottom to triangular top
    TRI_VOL = 1.3872e+03; % ml, total triangular volume
    REC_AREA = 29.845 * 17.145; % cm2
    REC_VOL = 5.2799e+03; % cm3, max volume is approximately upto batch valve

    if volume <= SQUARE_VOL && volume > 0 % only square
        height = volume / SQUARE_AREA;
    elseif volume <= TRI_VOL + SQUARE_VOL % square and triangular
        tri_vol  = volume - SQUARE_VOL;
        tri_height = Reverse_V_trian(tri_vol);
        height = tri_height + SQUARE_HEIGHT;
    elseif volume <= TRI_VOL + SQUARE_VOL + REC_VOL % square, triangular and rectangular
        rec_vol = volume - SQUARE_VOL - TRI_VOL;
        rec_height = rec_vol / REC_AREA;
        height = TRI_HEIGHT + SQUARE_HEIGHT + rec_height;
    else
        height = NaN;
    end
    
    if height <= TANK_HEIGHT && height > 0
        ultrasoni_distance = TANK_HEIGHT - height; %cm, convert height(from bottom
                                               %    to waterline) to
                                               %    distance measured by
                                               %    ultrasonic from the top
    else
        ultrasoni_distance = TANK_HEIGHT - height;
        disp("volume invalid")
    end
end 
      
function h = Reverse_V_trian(volume)
    syms h_trian
    w_1 = 5.08; % cm
    w_2 = 5.08 + 1.2214 * h_trian;
    w_3 = 0.6107 * h_trian;
    L_1 = 5.08; % cm
    L_2 = 2.5071 * h_trian;

    V_1 = h_trian * 0.5 * (w_1 + w_2) * L_1;  % volume of trapezoidal prism
    V_2 = h_trian * (2/3) * L_2 * w_3;    % volume of the 2 pyramids combined
    V_3 = h_trian * 0.5 * L_2 * w_1;      % volume of triangular prism

    equ =  V_1 + V_2 + V_3 == volume;
    h = vpasolve(equ, h_trian,[-Inf Inf]);
end