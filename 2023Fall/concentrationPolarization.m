function [cm_avg_list,Gz_m, Sh_avg,kf_avg] = concentrationPolarization(batch_flow, permeate_flow, bulk_concentration)
length = 0.24352;%m  length of channel
thickness = 0.001; %m    thickness of channel
width = 0.09112; %m   width of channel
crossSection = thickness*width; %m^2 horizontal cross section area of channel
membrane_Area = length*width; %m^2  area of membrane
perm_flux = permeate_flow/1e6/60/membrane_Area; %m/s flux rate through membrane
D_s = 7.98e-10; %m^2/s   diffusion coefficent of caso4 at 20C
visc = 1.0035e-6; % m^2/s KINEMATIC viscosity of water at 20C
D_h = 2*thickness; %m   hydraulic diameter of channel

vel = batch_flow/1e6/60/crossSection; %m/s  velocity of water through channel
Sc = visc/D_s;  %Schmidt number of solution
Re_Dh = vel*D_h/visc; %Reynolds number of channel flow
Gz_m = D_h/length*Re_Dh*Sc; 
Sh_avg = NaN;
for i = 1:size(Gz_m)
if Gz_m(i) <= 100
    Sh_avg(i) = 8.235 + 0.0364*Gz_m(i);
elseif Gz_m(i) <= 1000
    Sh_avg(i) = 2.236*(Gz_m(i).^(1/3))+0.9;
else
    Sh_avg(i) = 2.236*(Gz_m(i).^(1/3));
end
end

kf_avg = Sh_avg.*D_s./D_h;  %average mass diffusion coefficent 

cm_avg_list = NaN;
for i = 1:size(perm_flux)
cm_avg_list(i) = bulk_concentration*exp(perm_flux(i)/kf_avg(i)); %avgerage concentration at membrane
end

end