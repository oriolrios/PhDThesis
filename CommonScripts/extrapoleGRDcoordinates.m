%% (simplified) Nested Functions
% If any X or Y is beyond grd.lims they are reset to bounded values
% flag might be also launched. 
%
% History:
% $ 10.06.16 Fixed a bug with upper bounds.
%
function [x_f,y_f]=extrapoleGRDcoordinates(x,y,grd)
% extrapoles coordinates of th GRD for coordinates out of fuel map domain
filt1=x<grd.lim(1);
filt2=y<grd.lim(3);
filt3=x>grd.lim(2)+grd.dx/2;
filt4=y>grd.lim(4)+abs(grd.dy)/2;

x_f=x;
y_f=y;
if any(filt1==1)
    fprintf('Extrapolating GRD values x<%g ...\n',grd.lim(1))
    %fprintf('\t %g\n',x_f(filt1))
    
    x_f(filt1)=grd.lim(1);
    %disp('Extrapolating "fuel_map"...')
end
if any(filt2==1)
    fprintf('Extrapolating GRD values y<%g ...\n',grd.lim(3))
    %fprintf('\t %g\n',y_f(filt2))
    y_f(filt2)=grd.lim(3);
    %disp('Extrapolating "fuel_map"...')
end
if any(filt3==1)
    fprintf('Extrapolating GRD values x>%g ...\n',grd.lim(2))
    %fprintf('\t %g\n',x_f(filt3))
    x_f(filt3)=grd.lim(2);
    %disp('Extrapolating "fuel_map"...')
end
if any(filt4==1)
    fprintf('Extrapolating GRD values y>%g ...\n',grd.lim(4))
    %fprintf('\t %g\n',y_f(filt4))
    y_f(filt4)=grd.lim(4);
    %disp('Extrapolating "fuel_map"...')
end
end