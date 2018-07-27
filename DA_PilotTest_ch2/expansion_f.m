% Script to create huygens expancion for ANY closed initial perimeter
% Need to chance REF system (adapted on equations)!! (centered on the curve!) (previously created only for circular ignition fronts)
%
% CERTEC-ORios-07/14-
%
%   INPUTS
%   theta    wind direction DEG
%   xiyi     initial perimeter curve 
%   U        wind speed
%   fuel_depth_map.mat   Workspace generated with Fuel_depth_Map.m % loads fuel map and georeferencing!
%   dt      time step seg
%   tf       forcasted fronts
%   OUTPUTS
%   xy_fronts{t,x-y(1-2)} CELL ARRAY CANVIANT-ho!!
%
function [xy_fronts]=expansion_f(Imfw,U,theta,xiyi,fuel_depth, dt, tf)
%***************************%
flag_real       =   0;      % if 0 = real!,     1 = elliptical
%***************************%
flag_method     =   3;      % if 3 = euler,     2 = my,     1 = Richard93
%***************************%
flag_smooth     =   0;      % if 0 = NO smooth, 1 = YES splines 2 neighbors
%***************************%
%color_map=colormap(lines);
%color_map=colormap(hsv(128));
%load('fuel_depth_map.mat','fuel_depth') % loads fuel map and georeferencing!

%----could be set as inputs----
%dt    = 1; % time step seg
%tf    = 8;  % forcasted fronts
tf=tf-2; %Fronts number correction
tt=0:dt:tf;  
Nt=length(tt);

theta = theta*pi/180+pi/2; %DEG->RAD -90º OFFSET!!!!              %RAD wind direction, can depend on time!! (modify!)
%theta = 0;
Nds   = 20;              % number of discretized points
%n=length(s); % time steps (adding 0 (initial) time
%% REAL ignition or SYNTHETIC
if flag_real==0
%%%%%load('isochrons_mod.mat', 'isochrons_mod')
    %xiyi=isochrons_mod.xy{9};
%%%%%xiyi=isochrons_mod.xy{10};
% Aranging and creating mirror symetry!! /HALF CURVE!!! 
    xiyi=flipud(xiyi);
        xRef= min(xiyi(:,1));
        yRef= min(xiyi(:,2));
        %xiyi(:,1)=xiyi(:,1);
        %xiyi(:,2)=xiyi(:,2);
        
%     b=xiyi(1:end-1,:);
%     b(:,2)=2*yRef-b(:,2);
%     b=flipud(b);
%     xiyi=[xiyi;b]; %MIRALL SIMETRIC
    
    if xiyi(1,:)~=xiyi(end,:)
        xiyi=[xiyi;xiyi(1,:)]; %Close perimeter if open
    end
    
    xi=xiyi(:,1);
    yi=xiyi(:,2);
    %s=0:2*pi/(length(xi)-1):2*pi;
    %n=length(s);
    %m =Nt+1;
else
%% TEST with circular ignition
    Nds=100;
    s=0:2*pi/(Nds-1):2*pi;
    %s=-pi/2:2*pi/(Nds-1):3*pi/2;
    n=length(s);
    m =Nt+1;
    x=zeros(n,m); %+1 to close the perimeter last point equals first
    y=zeros(n,m);
    r=10; %m %initial radius
    xi=0.7*r.*cos(s)'+300;
    yi=0.2*r.*sin(s)'+300;
    xRef= mean(xi);
    yRef= min(yi);
    %close it
    %xi(n+1,1)=xi(1,1); %fallava pq si augemntes la dimensió es creen zeros
    %yi(n+1,1)=yi(1,1);
    
end

% SPACE DEPENDENT FUEL!!!!
RoS=Imfw.*fuel_depth; %fuel_depth loaded in 'fuel_depth_map.mat' workspace!
LB=0.936*exp(0.2566*U)+0.461*exp(-0.1548*U)-0.397;
HB=(LB+sqrt(LB^2-1))/(LB-sqrt(LB^2-1));
       
%% Temporal loop (spatially discretized!!) vectorization!?? 
%x(:,1)=xi;
%y(:,1)=yi;
xy_fronts{1}=[xi yi];

for t=2:1:Nt+1
    % dependencia en a,b,c si RoS o! U o theta depenen del temps! 

    xy_fuel=round(xy_fronts{t-1,1});
    xy_fuel(isnan(xy_fuel))=1; %ELIMINA NaNs NO se pq surten!! l'enviem a la cordanada (0,0) del RoS!!
    % if xy_fuel points out of the fuel plot assign RoS=0!!!
        %%ind=find(x(:,t-1)>ReF.XWorldLimits(2)|x(:,t-1)<ReF.XWorldLimits(1)|y(:,t-1)>ReF.YWorldLimits(2)|y(:,t-1)<ReF.YWorldLimits(1));
        if sum(sum(isnan(xy_fuel)))>1
         fprintf('MyErr:%d NaN encountered!!!\n',numel(isnan(xy_fuel)))
        end
    RoSkk=RoS(sub2ind(size(RoS), xy_fuel(:,2), xy_fuel(:,1))); % Correcte!
    a=0.5*RoSkk.*(1+1/HB)/LB;
    b=RoSkk.*(1+1/HB)/2;
    c=b-RoSkk./HB;
    

    if flag_method==1
        % FÓRMULA TEORICA- NO VA
           xiyi=flipud(xiyi);
               xRef= min(xiyi(:,1));
               yRef= min(xiyi(:,2));
            A=a.*((xi-xRef).*sin(theta)+(yi-yRef).*cos(theta)); %AQUI corregeixo referència
            B=b.*((-(xi-xRef)).*cos(theta)+(yi-yRef).*sin(theta));
            cos_phi=A./sqrt(A.^2+B.^2);
            sin_phi=B./sqrt(A.^2+B.^2);
     
        x(:,t)=x(:,t-1)+dt*(a.*cos(theta).*cos_phi+b.*sin(theta).*sin_phi+c.*sin(theta));
        y(:,t)=y(:,t-1)+dt*(-a.*sin(theta).*cos_phi+b.*cos(theta).*sin_phi+c.*cos(theta));
        
    elseif flag_method==2
        %FÓRMULA CORRECTA!!!!
           xiyi=flipud(xiyi);
               xRef= min(xiyi(:,1));
               yRef= min(xiyi(:,2));
            A=a.*((xi-xRef).*sin(theta)+(yi-yRef).*cos(theta)); %AQUI corregeixo referència
            B=b.*((-(xi-xRef)).*cos(theta)+(yi-yRef).*sin(theta));
            cos_phi=A./sqrt(A.^2+B.^2);
            sin_phi=B./sqrt(A.^2+B.^2);
        
        xy_fronts{t,1}=[xy_fronts{t}(:,1)+dt*(a.*sin(theta).*cos_phi-b.*cos(theta).*sin_phi+c.*cos(theta)) xy_fronts{t-1,1}(:,2)+dt*(a.*cos(theta).*cos_phi+b.*sin(theta).*sin_phi+c.*sin(theta))];
        %xy_fronts{t,1}=xy_fronts{t-1,1}+dt*(a.*sin(theta).*cos_phi-b.*cos(theta).*sin_phi+c.*cos(theta));
        %xy_fronts{t,2}=xy_fronts{t-1,2}+dt*(a.*cos(theta).*cos_phi+b.*sin(theta).*sin_phi+c.*sin(theta));
        
    else
        % FÓRMULA ORIGINAL 1990 INTEGRADA PER CENTRED DIFERENCES
        theta_cor=theta-pi/2; %les meves equacions tene un desfasament que cal corregir!! 
        [xy_fronts{t,1}]=huygns_integration(xy_fronts{t-1,1}(:,1),xy_fronts{t-1,1}(:,2),a,b,c,theta_cor,dt);
        
        % regridding & loop clipping! NO SÉ QUÈ FER ABANS!!! 
        % looks nicer 1st REGRID +CLIPP (lasts litle longer) CHECK!!! -> TRUE
        
    %%%%%[xy_fronts{t,1}]=regridding(xy_fronts{t,1}(:,1),xy_fronts{t,1}(:,2));
%    plot (xy_fronts{t,1},xy_fronts{t,2}, '-+r')
        [xy_fronts{t,1}]=loop_clipping(xy_fronts{t,1}(:,1),xy_fronts{t,1}(:,2));
        [xy_fronts{t,1}]=regridding(xy_fronts{t,1}(:,1),xy_fronts{t,1}(:,2));
        [xy_fronts{t,1}]=loop_clipping(xy_fronts{t,1}(:,1),xy_fronts{t,1}(:,2));
        
        
        
        %CLOSE PERIMETER
        xy_fronts{t,1}=[xy_fronts{t,1};xy_fronts{t,1}(1,:)];
        
        
        % DEGRIDDING (twice necessary)?¿ why?
%    fprintf('DEGRID START. Time %d \n',t)
% !!!!![xy_fronts{t,1},xy_fronts{t,2}]=degridding(xy_fronts{t,1},xy_fronts{t,2});
%    disp('one done')
        %[xy_fronts{t,1},xy_fronts{t,2}]=degridding(xy_fronts{t,1},xy_fronts{t,2});
              
        % RECLOSE PERIMETER IF DEGRIDING HAS OPEN IT
        if xy_fronts{t,1}(1,:)~=xy_fronts{t,1}(end,:)
            xy_fronts{t,1}(end+1,:)=xy_fronts{t,1}(1,:);
        end
        % SMOOTHING Y (only)
% % %         if flag_smooth==1
% % %             [xy_fronts{t,2}]=smooth(xy_fronts{t,1},xy_fronts{t,2},3);
% % %         end
        
% %         hold on
% %         %plot (xy_fronts{1,1},xy_fronts{1,2}, '-xr')
% %         plot (xy_fronts{t,1},xy_fronts{t,2}, '--x', 'color',color_map(t,:))
% %         plot (xy_fronts{t,1},xy_fronts{t,2}, '--xg')
    end
end

%% PLOTTING
%figure
%grid minor
% % % % % % hold on
% % % % % % for t=2:m
% % % % % %     if flag_method==3
% % % % % %     %plot (xy_fronts{t,1}, xy_fronts{t,2}, '--xk')
% % % % % %     plot (xy_fronts{t,1}, xy_fronts{t,2}, '--x', 'color', color_map(t,:))
% % % % % %     else
% % % % % %     plot (xy_fronts{t,1}, xy_fronts{t,2}, '--xm')
% % % % % %     end
% % % % % % end
% % % % % % hold on
% % % % % % plot (xy_fronts{1,1}, xy_fronts{1,2}, '-xr')

%for i=1:n
%  plot(x(i,:), y(i,:), 'g')  
%end
% plot(x(1,:), y(1,:), 'r')  
% plot(x(2,:), y(2,:), 'r')  
end
    