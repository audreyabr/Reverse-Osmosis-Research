for i = 1:0.2:28
   vol = Water_Tank_Calculations_3(i);
   scatter(i,vol,".")
   hold on
end