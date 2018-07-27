% Script to create huygens expancion for ANY closed initial perimeter
% Need to change REF system (adapted on equations)!! (centered on the curve!) (previously created only for circular ignition fronts)
%
% CERTEC-ORios-07/14-
%
%
% History
% 05/11/14- Modificat per a no propagar el punt inici i final (g_expansion_new)
% 09/12/14- df no és input, posar-lo com a argument del dt. Adimat no suporota varargin
% 07/01/16 - SIMPLE version to differentiate with addimat
% 04/03/16 - Change theta to GRD
% 23/07/16 - U and theta are measo winds! WindNinja interpolation to downscale
% $24.12.16- NOVELTY ->interpolates map in EXPANSION and NOT IN HUYGENS
% $06.01.17- 
%
%
function [xy_fronts]=expansion_f_s_simple_7i_WND_fmsk(Mf,Mx,SAV,Wo,MesoU,MesoDir,fuelDepth,xiyi,aspect,slope,fmask,AllSpeedMapStrucGRD,AllDirMapStrucGRD,At,dt,res)
tic
xiyi= check_sense_xiyi(xiyi);
% artificial constraint
if Mf>Mx
    fprintf('reseting Mf. %.3f>%.3f\n',Mf,Mx)
   Mf=Mx-0.01; 
end
%% INPUTS
% INVARIANTS
%       Imfw        Wind-fuel
%       I_Wo        ovendry density
%       U           wind speed
%       xiyi        initial perimeter curve. MUST BE CCW!
%       theta       wind direction RAD. (Towards where blow from HORZ CCW!)
%   fuel_depth  GRD fuel depth
%   aspect      GRD aspect from North
%   slope       GRD STRUCT slope (for efficiency should be read de *.asc just once)
%   WN_Map_path Directory with windNinja RUN base maps. 
%   At          time vector to be integrated (starts at 0)[s] !!!SEGONS!!!
%   dt          fixed diff eq. integration time (s)
%   res         degridding distance ressolution (m)
%
% OUTPUTS
%   xy_fronts{t,x-y(1-2)} CELL ARRAY CANVIANT-ho!!

%%
% wind_dir = aspect;
% wind_dir.data=MesoDir*ones(size(wind_dir.data));

%
%***************************%
flag_smooth     =   0;      % if 0 = NO smooth, 1 = YES splines 2 neighbors
%***************************%

%----could be set as inputs----
%dt    = 1; % time step seg
%tf    = 8;  % forcasted fronts

% if nargin>6 % Adimat no ho soporta!
%     tf=varargin{1};
% end
 %plot(xiyi(:,1),xiyi(:,2),'-*m');
 %% Program
 [MesoDirN]=AngularHorz2North_Blow2FromCW(MesoDir, 'r');
if numel(At)>1
    if At(1)~=0
        error('dt(1) vector must start at 0 not at %d',At(1))
    end
else
    %    tf=tf-2; %Fronts number correction ???
    %    dt=0:dt:tf;
    error('define dt as a vector with expansion times')
end

%[xiyi]=check_sense_xiyi(xiyi,'reverse');  % xiyi inverts sense if needed

% SPACE DEPENDENT FUEL!!!!
if MesoU<0
    disp('U has a negative value!!!')
end

%% Temporal loop (spatially discretized!!) vectorization!??->NO, cal flitrar clipping i regrid!!
xy_fronts.xy{1}=xiyi;
%muted
%h = waitbar(0,'1','Name','Generating fronts...');
%must start at 2!
%
%
%% INTERPOLATED WIND MAPS
%
[NewSpeedMapGRD,NewDirMapGRD]=SpeedDirMapInterpolFromGRD(AllSpeedMapStrucGRD,AllDirMapStrucGRD,MesoU,MesoDirN);
NewDirMapGRD.data=NewDirMapGRD.data/180*pi;
%% INTEGRATION LOOP
for t=2:1:length(At)
%muted    
%waitbar(t/length(dt),h,sprintf('%2.2f %% integreted...',t/length(dt)*100))
% %!  Aclarir aixó!    
%     theta=theta-pi/2; %les meves equacions tene un desfasament que cal corregir!!  
    
%!  Dummy és necessary ?
    %[dummy]=huygns_integration(xy_fronts{t-1,1}(:,1),xy_fronts{t-1,1}(:,2),a,b,c,theta_cor,dt(t));
    last_front2expand=xy_fronts.xy{t-1,1}(:,1:2);
    %[dummy]=huygns_integration_s_7i_WND(last_front2expand(:,1),last_front2expand(:,2),Mf,Mx,SAV,Wo,MesoU,MesoDirN,fuelDepth,aspect,slope,NewSpeedMapGRD,NewDirMapGRD,At(t)-At(t-1),dt,res);
    [dummy]=huygns_integration_s_7i_WND_fmsk(last_front2expand(:,1),last_front2expand(:,2),Mf,Mx,SAV,Wo,fuelDepth,aspect,slope,fmask,NewSpeedMapGRD,NewDirMapGRD,At(t)-At(t-1),dt,res);
    
    xy_fronts.xy{t,1}=double(dummy);
    
    % Tanquem el perímetre abans del loop clipping i regrid pq es poden produir més loops
    if xy_fronts.xy{t,1}(1,:)~=xy_fronts.xy{t,1}(end,:)
        xy_fronts.xy{t,1}(end+1,:)=xy_fronts.xy{t,1}(1,:);
    end

    xy_fronts.time=At;
end
etime=toc;
fprintf('Forward run took: %.2f s \n',etime)
end
