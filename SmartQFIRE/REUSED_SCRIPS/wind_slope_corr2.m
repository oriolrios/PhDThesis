function [RoS_i,theta_w_s]=wind_slope_corr2(x,y,RoS0_i,U,wind_dir_i,I_Wo,slope_i,aspect_i,fuel_depth_i)
%% Corrects RoS as Lautenburger proposes:
% V_s=V_(s0)*max(1,[1+PHI_s*cos(teta_a-pi-teta)+PHI_w*cos(teta_w-pi-teta)] 
% PHI_s i PHI_w són els coeficients adimensionals de ROTHERMEL
% AND calculates the wind-slope propagation vector! 
% U should be mid-flame wind
% Needs to calculate rothermel wind and slope factors
%------------ CONSTANT parameters----------------------------
rho_p=32;                 %[lb/ft^3]  Ovenrdy fuel density*
rho_p=512.59*rho_p;       %[lb/ft^3] -> [kg/m^3]
SAV=6500;                 %[1/m] JUST FOR CHECK
% *(after Scott & Burgen)
%------------------------------------------------------------

%ADIMAT!
%[fuel_depth_i,wind_dir_i,slope_i,aspect_i]=GetGRDValueIfNeeded;

[theta_front]=front_normal_angle(x,y); % alpha_i in FARSITE

%% Phi_w. FROM FARSITE
[Phi_w_i]=Calc_Phi_w(U,rho_p,SAV,I_Wo,fuel_depth_i); % U should be wind at mid flame!


%% Phi_s. FROM FARSITE
rho_b=I_Wo./fuel_depth_i;                    % Ovendry bulk density
beta=rho_b/rho_p;                            % Packing ratio
Phi_s_i=5.275*beta.^(-0.3).*tan(slope_i).^2; %Slope Factor after Rothermel72

% % %% INCORRECTE
% % % Correccions com LAUTENBERGEN
% % % Get max(1,Phi_w_i,Phi_s_i) for each front point -INCORRECTE. AIXÔ ÉS
% % % QUUAN NO HI HA HUYGENS!!!
% % base_value=ones(size(Phi_w_i));
% % slope_factor= Phi_s_i.*(1+cos(aspect_i-pi-theta_front));
% % wind_factor= Phi_w_i.*(1+cos(wind_dir_i-theta_front));
% % 
% % %corr_i=max([base_value slope_factor wind_factor],[],2); 
% % %changed due to ADIMAT
% %     %aux1=[base_value slope_factor wind_factor]'; INCORRECTE
% %     aux1=[base_value 1+slope_factor+wind_factor]';
% %     corr_i=max(aux1);
% %     RoS_i=corr_i'.*RoS0_i;
% % 
% % % Calc of theta (vectorial sum of I_theta I_w)
%NO TEMIM EN COMPTE TRANSFORMACIÖ DE PLANS! (veure FARSITE pag 6)
theta_w_s_x=Phi_s_i.*sin(aspect_i-pi)+Phi_w_i.*sin(wind_dir_i);
theta_w_s_y=Phi_s_i.*cos(aspect_i-pi)+Phi_w_i.*cos(wind_dir_i);
theta_w_s=atan2(theta_w_s_x,theta_w_s_y);
[theta_w_s]=angular_devaluate(theta_w_s);

RoS_i=RoS0_i.*(Phi_w_i+Phi_s_i);
end

% % %% Nested Functions
% % % Nested Functions
% %     function [fuel_depth_i,wind_dir_i,slope_i,aspect_i]=GetGRDValueIfNeeded
% %         %Slope
% %         if isstruct(slope) % get aspect values vector
% %             if ~exist('x','var') || ~exist('y','var')
% %                 error('If slope is input as GRD, xy coordinates are required!')
% %             end
% %             slope_i =getGRDvalue(slope,x,y);
% %         else
% %             slope_i=slope;
% %         end
% %         % FUEL
% %         if isstruct(fuel_depth) % get aspect vlaues vector
% %             if ~exist('x','var') || ~exist('y','var')
% %                 error('If slope is input as GRD, xy coordinates are required!')
% %             end
% %             fuel_depth_i =getGRDvalue(fuel_depth,x,y);
% %         else
% %             fuel_depth_i=fuel_depth;
% %         end
% %         
% %         % wind dir
% %         if isstruct(wind_dir)
% %             if ~exist('x','var') || ~exist('y','var')
% %                 error('If WIND is input as GRD, xy coordinates are required!')
% %             end
% %             % !!!!!     % PENDENT de preparar la funció per llegir un arxiu de vent 'wind' (GRID)!
% %             [wind_dir_i]=getGRDvalue(wind_dir,x,y);
% %         else
% %             wind_dir_i=wind_dir;
% %         end
% %         
% %         if isstruct(aspect) % get aspect vlaues vector
% %             if ~exist('x','var') || ~exist('y','var')
% %                 error('If aspect is input as GRD, xy coordinates are required!')
% %             end
% %             aspect_i =getGRDvalue(aspect,x,y);
% %         else
% %             aspect_i=aspect;
% %         end
% %         
% %     end


