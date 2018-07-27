function plot_frontGRD(fronts_str,grd,units_label,varargin)
% plot_frontGRD()
%   plots fronts perimeters AND a GRD struct as a colour contour
%   example:
%   plot_frontGRD(xy_fronts.xy,slopeMO,'slope [rad]','w','zoom')
%
% INPUT
% fronts_str       fronts STRUCT (.xy) ) or CELL 
% grd              GRD-alike struct
% units_label      GRD units STRING (to label cbar)
% varargin{1}      (optional) Any plot style string (ex. '-*r') (will be used for all
%                  fronts). If not stated, gradual degradation.
% varargin{1}      (optional) 'zoom' -> zoom arround isochrones! (scale is then not
%                  conserved!)
disp('------------- MY-WARNING(plot_frontGRD())!! USE ''PlotFrontGRD()'' function instead!!! ----------------- ')
zoom_flag=0;
if nargin>3
    line_style=varargin{1};
    in_var=length(varargin);
    if in_var>1 && strcmp(varargin{2},'zoom')
        zoom_flag=1;
    end
else
    line_style='-k';
end
plotGRDimg(grd,units_label)
hold on
% Able to handel struc or cells!
if ~isstruct(fronts_str)
    xy_fronts.xy=fronts_str;
else
    xy_fronts=fronts_str;
end

for i=1:length(xy_fronts.xy)
    %[c,r]=getcr(grd, xy_fronts.xy{i}(:,1), xy_fronts.xy{i}(:,2));
    %plot(c,r,line_style)
    plot(xy_fronts.xy{i}(:,1), xy_fronts.xy{i}(:,2),line_style)
end

if zoom_flag==1
    offset=50; % in meters units
    x_minmax(1)=min(xy_fronts.xy{i}(:,1))-offset;
    x_minmax(2)=max(xy_fronts.xy{i}(:,1))+offset;
    y_minmax(1)=min(xy_fronts.xy{i}(:,2))-offset;
    y_minmax(2)=max(xy_fronts.xy{i}(:,2))+offset;
    
    axis([x_minmax y_minmax])
    
end

end