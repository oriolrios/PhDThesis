%
% "fronts_distance" Computes the sum of the norm distance between all the
% correspondinf fronts curves by summing normal distance from every node
% in xy_model(t)->xy_real(t) and divides it *by the number of nodes*!!!
%   INPUTS
%   xy_real         real fronts cell array
%   xy_model        model fronts cell array
%
%   OUTPUTS
%   Cost_total
%   xy_diff         cell array with x
%   nan_logic       logical vector of eliminated intersacions (due to NaN). Length 1 element shorte /segment between nodes

%function [Cost_total, N]=real_model_cost(xy_real,xy_model) %OLD FUNCTION
function [Cost_total, xy_diff,nan_logic]=real_model_cost(xy_real,xy_model)
% ************ %
plotting=0;    % 1= PLOT, 0= NO plot
% ************ %

% *********** %
filter= 1;    % Filter distances >mean+2*std 1=ON, 0=OFF
% *********** % S'ha de canviar el filtre per registrar els que s'eliminen

% check same isochrons in xy_real and xy_model
if length(xy_real)~=length(xy_model)
    error('MyErr:real_model_cost-> different isochrones number')
end
N=nan(length(xy_model),1);

%% PLOTTING AS CALCULATES
if plotting==1
    figure
    hold on
    Hax1=gca;
    set(Hax1,'DataAspectRatio',[1 1 1]); %%SAME AS: axis equal
end

xy_diff=cell(size(xy_real,2),2);
for t=1:length(xy_model)
    if plotting==1  % PLOTTING   %plot intersections
        plot(xy_real{t}(:,1),xy_real{t}(:,2),'-k',xy_model{t}(:,1),xy_model{t}(:,2),'-xr')
    end
    [N(t),mode2real_x1_front,xy_real_diff,xy_model_midle]=front_distance(xy_real{t},xy_model{t},t); %no es pot posar ~ per fer AD!!
    
    %% GET the adjacent matrix with deleted index (to delete Jacobian elements)
    nan_logic{t}=~isnan(mode2real_x1_front); % 1 no NaN, 0 NaN
    
%    % FILTER sums >mean+2*std
    if filter==1
        mean_c=mean(mode2real_x1_front(~isnan(mode2real_x1_front))); %without NaN's
        %std_c=std(mode2real_x1_front(~isnan(mode2real_x1_front)));
        ind=(mode2real_x1_front>(2*mean_c+0));
        % Update delete index vector
        nan_logic{t}=logical(nan_logic{t}-ind);
        %disp('filter on "function: real_model_cost"!')
    end
         % FILTER NaN (that's why xy_,, dimensions and nan dimensions don't match
    xy_real_diff=xy_real_diff(nan_logic{t},:);
    xy_model_midle=xy_model_midle(nan_logic{t},:);
    
    xy_diff{t,1}=xy_real_diff;
    xy_diff{t,2}=xy_model_midle;
end
% Filtering spurious values!
Cost_total=mean(N);
end
