%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%           ROTHERMELS MODEL 1972                                         %      
%                                      Function to calculate RoS          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function calculates the Rate of Spread (m/s) according to Rothermel
% work published in 1972. 
% It also uses Albini 1976 experimental data. This set is used in FARSITE
% .* data also used by Scott and Burgan05
%
% --------Input Parametes------------------------------------------------
%
%   Mf    = Moisture content [%] 0-1 tant per 1! < 0.3!!! mirar FIT!!!
%   U     = Wind vector (over space??¿?) !! [m/s]-- CONVERTEIXO A DINS!!!
%   PhiS0 = Slope [rad]
%
%------ FUEL PARAMETERS-----------------------
%   D     = Fuel depth  [m]
%   SAV   = Surface-area-to-volum ratio As/V [1/m] limit according to paper Overholt FireTechnology lim 2800-10800 1/m
%   Wo    = 5;%!!!!     % [kg/m.^2]  Ovendry fuel loading
%   Mx    = Moisture content of extintion (doesn't burn) [%] 0-1
% ------------------------------------------------------------------------%
%
% ------ OUTPUTS----------------------------------------------------------
% RoS [m/S]
%TOT EN ENGLISH UNITS !!!!!!!!!!!!!!!

function[RoS]=rothermel_SI(U, PhiS0, D, SAV, Wo, Mf, Mx)

%------------ CONSTANT parameters----------------------------
rho_p=32;           %[lb/ft.^3]  Ovenrdy fuel density.* Confirmat
h= 8000;            %[btu/lb]   Fuel particle low heat content.*
St= 5.55/100;       % [%]       Fuel particle total mineral content.*
Se= 1/100;          % [%]       Fuel particle effective mineral content.*
%------------------------------------------------------------

%Variables unit change
%PhiS0 = PhiS0.*pi()/180;     % deg to rad
Ue = 196.85.*U;              % [m/s]    -> [feet/min] as rothermels need Uenglish
%rho_p=0.062428.*rho_p;       % [kg/m.^3] -> [lb/ft.^3]
D=3.28084.*D;                % [m]      -> [feet]
SAV=1/3.28084.*SAV;          % [1/m]    -> [1/feet]
Wo= 0.20482.*Wo;             % [kg/m.^2] -> [lb/ft.^2]
%---------------------------------------------------------------
% Let's start with the intermediate calculus

rho_b=Wo./D;                                 % Ovendry bulk density
beta=rho_b./rho_p;                           % Packing ratio
Qig=250+1.116.*Mf;                           % Heat of preignition
epsilon = exp(-138./SAV);                    % Effective heating number
phi_s=5.275.*beta.^(-0.3).*(tan(PhiS0)).^2;     % Slope factor
Wn= Wo./(1+St);                              % Net fuel loading !!!!!!!!!!! FALTAAA

% all this for the wind...!! (interaction with canopy)
    E=0.715.*exp(-3.59.*1E-4.*SAV);                % !! Analitzar aquest terme!!!!!!!!!!!!!
    B=0.02526.*SAV.^(0.54);                       % !! Analitzar aquest terme!!!!!!!!!!!!!
    C=7.47.*exp(-0.133.*SAV.^0.55);                % !! Analitzar aquest terme!!!!!!!!!!!!!
    beta_op= 3.348.*SAV.^-0.8189;                 % Optimum packing ratio
    phi_w=C.*(Ue).^B.*(beta./beta_op).^(-E);      % WIND FACTOR in feet./min.. ok!
% wind's over

xi= 1./(192+0.2595.*SAV).*exp((0.792+0.681.*sqrt(SAV)).*(beta+0.1)); %propagating flux ratio
n_s= 0.174.*Se.^(-0.19);                                % mineral damping coefficient
n_M=1-2.59.*(Mf./Mx)+5.11.*(Mf./Mx).^2-3.52.*(Mf./Mx).^3;   % MOISURE DAMPING!!! MIRAR!!!! That's experimental for Ponderosa Pine Needle beds Rothermels pg 12. 

% velocity
A=1./(4.774.*SAV.^0.1-7.27);
RV_max=SAV.^1.5./(495+0.0594.*SAV.^1.5);              % MAX Reaction Velocity
RV= RV_max.*(beta./beta_op).^A.*exp(A.*1-(beta./beta_op));  % Optimum Reaction Velocity
IR=RV.*Wn.*h.*n_M.*n_s;                                   % Reaction Intensity min-1

%at the end of the day...
RoS= (IR.*xi.*(1+phi_w+phi_s))./(rho_b.*epsilon.*Qig);      %Rate of spread [ft./min]
RoS= 1./3.28084.*RoS/60; %[ft./min]->[m/s]
if any(RoS<0)
        disp(RoS)
        error('myApp:argChk','RoS < 0. ERROR!!! You might want to check your inputs!!')        
end

end
