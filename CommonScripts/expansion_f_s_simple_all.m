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
function [xy_fronts]=expansion_f_s_simple_all(Mf,Mx,SAV,Wo,U,theta,D,xiyi,aspect,slope,dt)


%% INPUTS
% INVARIANTS
%       Imfw        Wind-fuel
%       I_Wo        ovendry density
%       U           wind speed
%       xiyi        initial perimeter curve
%       theta       GRD wind direction RAD. (Where it goes to...!)
%   fuel_depth  GRD fuel depth
%   aspect      GRD aspect from North
%   slope       GRD slope
%   dt          time vector to be integrated (starts at 0)[s] !!!SEGONS!!!
%
% OUTPUTS
%   xy_fronts{t,x-y(1-2)} CELL ARRAY CANVIANT-ho!!

%%
wind_dir = aspect;
wind_dir.data=theta*ones(size(wind_dir.data));

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
 %%
if numel(dt)>1
    if dt(1)~=0
        error('dt(1) vector must start at 0 not at %d',dt(1))
    end
else
    %    tf=tf-2; %Fronts number correction ???
    %    dt=0:dt:tf;
    error('define dt as a vector with expansion times')
end

[xiyi]=check_sense_xiyi(xiyi,'reverse');  % xiyi inverts sense if needed

% SPACE DEPENDENT FUEL!!!!
if U<0
    disp('U has a negative value!!!')
end

%% Temporal loop (spatially discretized!!) vectorization!??->NO, cal flitrar clipping i regrid!!
xy_fronts.xy{1}=xiyi;
%muted
%h = waitbar(0,'1','Name','Generating fronts...');
%must start at 2!
for t=2:1:length(dt)
%muted    
%waitbar(t/length(dt),h,sprintf('%2.2f %% integreted...',t/length(dt)*100))
% %!  Aclarir aixó!    
%     theta=theta-pi/2; %les meves equacions tene un desfasament que cal corregir!!  
    
%!  Dummy és necessary ?
    %[dummy]=huygns_integration(xy_fronts{t-1,1}(:,1),xy_fronts{t-1,1}(:,2),a,b,c,theta_cor,dt(t));
    last_front2expand=xy_fronts.xy{t-1,1}(:,1:2);
    [dummy]=huygns_integration_s_all(last_front2expand(:,1),last_front2expand(:,2),Mf,Mx,SAV,Wo,U,wind_dir,D,aspect,slope,dt(t)-dt(t-1));
    
    xy_fronts.xy{t,1}=double(dummy);
    
    % Tanquem el perímetre abans del loop clipping i regrid pq es poden produir més loops
    if xy_fronts.xy{t,1}(1,:)~=xy_fronts.xy{t,1}(end,:)
        xy_fronts.xy{t,1}(end+1,:)=xy_fronts.xy{t,1}(1,:);
    end

    xy_fronts.time=dt;
end

end
