function PlotShadedError(x,y,err,ax)
% PlotShadedError plots multiple lines as a shadow line plot
% x = vect
% y = vect or matrx
% err= vect or matx [m n] -> m=length(x)
% -Oriol 2016-
% 
% EXAMPLE
% x = linspace(0, 2*pi, 50);
% y1 = sin(x);
% y2 = cos(x);
% y=[y1',y2'];
% err = rand(size(y1))*.5+.5;
% PlotShadedError(x,y,err)

set(0,'defaultlinelinewidth',1)

if nargin>3
    ax=ax;
else
    figure
    ax=axes;    
end

% map=parula(size(y,2));
  map=lines(size(y,2));
% map=hsv(size(y,2));

for i=1:size(y,2)
    boundedline(x,y(:,i),err(:,i),'-*','cmap', map(i,:), 'alpha',ax)
    %shadedErrorBar(x,y,err,style_vec(i),1); %MEMORY ERROR
end
grid on
%restore settings
set(0,'defaultlinelinewidth',0.5)