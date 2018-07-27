function [Phi_w]=Calc_Phi_w(U_flame05,rho_p,SAV,I_Wo,fuel_depth_i)
%
% UNITS
% I_Wo
% fuel_depth_i
% rho_p            in IS UNITS (ja queden dimensionless després);
%
% Uses the wind at mid flame! (need to reduce) 
% After Rothermel 72
% %------------ CONSTANT parameters----------------------------
% rho_p=32;                 %[lb/ft^3]  Ovenrdy fuel density*
% rho_p=512.59*rho_p;       %[lb/ft^3] -> [kg/m^3]
% %------------ CONSTANT parameters----------------------------
%U_flame05=U_flame05*196.85;              % m/s->ft/min  FARSITE CORRECTED

rho_b=I_Wo./fuel_depth_i;                    % Ovendry bulk density
beta=rho_b/rho_p;                           % Packing ratio
%
SAV=0.3048.*SAV;                             % 1/m->1/ft
E=0.715*exp(-3.59*1E-4*SAV);                 % !! Analitzar aquest terme!!!!!!!!!!!!!
B=0.02526*SAV.^(0.54);                       % !! Analitzar aquest terme!!!!!!!!!!!!!
C=7.47*exp(-0.133*SAV.^0.55);                % !! Analitzar aquest terme!!!!!!!!!!!!!
beta_op= 3.348*SAV.^-0.8189;                 % Optimum packing ratio
Phi_w=C.*(3.281.*U_flame05).^B.*(beta./beta_op).^(-E);      % WIND FACTOR DIMENSIONLESS
end 