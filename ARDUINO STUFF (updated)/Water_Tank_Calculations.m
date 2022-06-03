%% Assumptions
% I am assuming a wall thickness of 1/8, or 0.125 inch, according to the
% McMaster website specifications. In the McMaster Solidworks file, the
% thickness is about 0.18 so I'm not sure how accurate these calculations
% are.

% Also, my calculations here return a volume slightly less than what my
% Solidworks Mass Properties says. Perhaps we can pretend this accounts for
% the fillets inside the box :)

%% Find volumes of all other sections of the tank, with respect to overall height

function res = Water_Tank_Calculations(overall_height)
    % CHANGE THIS, h max is 11.75 inches
    h_overall = overall_height; %11.75 - 6.5  % the overall height from the very bottom of the container, inches

    % find volume of rectangle portion at the top.
    if h_overall <= 4.5380  % this is the max heights of square + triangle
        h_rectangle = 0;
    else
        h_rectangle = h_overall - 4.5380;
    end


    % find volume of square portion at the bottom. h_square found with the
    % inside corner length in the Solidworks.
    if h_overall <= 0.6490
        h_square = h_overall;
    else
        h_square = 0.6490;
    end


    % find volume of triangle portion at the bottom.
    if h_overall <= 0.6490
        h_triangle = 0;
    elseif h_overall <= 4.5380
        h_triangle = h_overall - 0.6490;
    else
        h_triangle = 3.889;
    end

    V_triangle = V_trian(h_triangle);

    res = h_square*2*2 + V_triangle + h_rectangle*11.75*6.75;% + 7*overall_height;
end

%% change this to find Volume of the triangular portion, based on height
% height in inches, measured from the top of the square portion
% (or the bottom of the triangle portion)

% uncomment and change this height to whatever you want between 0 and 3.899
% to find just the triangle volume
%h_triangle = 3.889;

%% Set equations and solve for trianglular volume
% this is the recalculated formula, directly calculating the volume and not
% using negative space. It also accounts for the thickness of the walls.

function res = V_trian(h_trian)
    w_1 = 2;
    w_2 = 2 + 1.2214 * h_trian;
    w_3 = 0.6107 * h_trian;
    L_1 = 2;
    L_2 = 2.5071 * h_trian;

    V_1 = h_trian * 0.5 * (w_1 + w_2) * L_1;  % volume of trapezoidal prism
    V_2 = h_trian * (2/3) * L_2 * w_3;    % volume of the 2 pyramids combined
    V_3 = h_trian * 0.5 * L_2 * w_1;      % volume of triangular prism

    res = V_1 + V_2 + V_3;
end

%% This is my tests of MatLab vs Solidworks for the triangular portion:
% heights = [3, 2, 1, 3.889];     % inches
% SW_Vol  = [73.43, 31.31, 8.88, 132.32];     % in^3
% ML_Vol  = [73.1160, 31.0798, 8.7492, 131.9845];  % my calculated volumes

%% Water tests:
% 
% Input volume: 200 mL = 12.2047488 in^3
% Measured height: 9.8 in. from the top ()
% Calculated volume: 8.7168 in^3
% 
% Input Volume: 400 mL = 24.4094976 in^3
% Measured height: 9.12 in. from the top
% Calculated volume: 20.0136 in^3
% 
% Input Volume: 600 mL
% Measured height: 8.95 in. from the top
% Calculated volume: 23.9567 in^3
% 
% Input Volume: 800 mL
% Measured height: 8.6 in. from the top
% Calculated volume: 33.7070 in^3
% 
% Input Volume: 1000 mL
% Measured height: 8.37 in. from the top
% Calculated volume: 41.4127 in^3
% 
% Input Volume: 1200 mL
% Measured height: 8.15 in. from the top
% Calculated volume: 49.8279 in^3
% 
% Input Volume: 1600 mL
% Measured height: 7.78 in. from the top
% Calculated volume: 66.4664 in^3
% 
% Input Volume: 2000 mL
% Measured height: 7.45 in. from the top
% Calculated volume: 84.1535 in^3
% 
% Input Volume: 2400 mL
% Measured height: 7.23 in. from the top
% Calculated volume: 97.5500 in^3
% 
% Input Volume: 2800 mL
% Measured height: 6.82 in. from the top
% Calculated volume: 126.1957 in^3
% 
% Input Volume: 3200 mL
% Measured height: 6.5 in. from the top
% Calculated volume: 151.3947 in^3