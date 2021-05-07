function [Hax]= plot_fronts_cell(xy_fronts,var_in1,varargin)
%%PLOT_FRONTS_CELL is used to plot fronts stored as CELL.
%
% PLOT_FRONTS_CELL(xy_fronts)
%
% PLOT_FRONTS_CELL(xy_fronts,'hold')
%
% PLOT_FRONTS_CELL(xy_fronts,'hold','--r')
%
% INPUT
% xy_fronts     fronts cell
% var_in1       'hold'   keeps plotting in gca axis
%                GRD     plots fronts and GRD data
% varargin      any plot style string (ex. '-*r') (will be used for all
%               fronts). If not stated, gradual degradation.
% OUTPUT (optional)
% Hax = plot handle

%whitebg([1 1 1])
%whitebg([0 .5 .6])
if nargin>1
    if strcmp(var_in1,'hold')
        hold on
    elseif isstruct(var_in1)
        %pendennt
    else
        figure
    end
else
    figure
end
if nargin>2
    if isnumeric(varargin{1})
        Vcolor=varargin{1};
        for t=1:length(xy_fronts)
            Hax= plot (xy_fronts{t}(:,1), xy_fronts{t}(:,2), '-','color',Vcolor);
            hold on
        end
    else
        line_style=varargin{1};
        for t=1:length(xy_fronts)
            Hax= plot (xy_fronts{t}(:,1), xy_fronts{t}(:,2), line_style);
            hold on
        end
    end
else
    color_map=colormap(hsv(128));
    for t=1:length(xy_fronts)
        Hax=plot (xy_fronts{t}(:,1), xy_fronts{t}(:,2), '-x', 'color', color_map(2*t,:));
        %plot (xy_fronts{t}(:,1), xy_fronts{t}(:,2), '-k')
        hold on
    end
end



set(gca,'Xcolor','k')
set(gca,'Ycolor','k')
ylabel('lat (m)')
xlabel('lon (m)')
axis equal
grid on

