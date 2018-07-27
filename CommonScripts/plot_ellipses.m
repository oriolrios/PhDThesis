function plot_ellipses(x,y,a,b,c,dir)
% Plot ellipses getting DIR from AZIMOUTH and CW direction
grey = [0.4,0.4,0.4];
theta=0:0.1:2*pi;
if numel(dir)==1
    dir=dir*ones(size(x));
end
if numel(a)==1
    a=a*ones(size(x));
    b=b*ones(size(x));
    c=c*ones(size(x));
end
% ES pot fer sense loop (i llavors no cal el filtres del principi) però cal
% plotejar en loop
for i=1:numel(x)
    x_el=b(i)*cos(theta); % a and b are swiched in FARSITE definition
    y_el=a(i)*sin(theta);
    
    [x_el,y_el]=rotate_m(x_el,y_el,-dir(i)-pi/2); % clockwise and from N CORRECTE!!
    
%     x_el_O=x_el+x(i);
%     y_el_O=y_el+y(i);
%     plot(x_el_O,y_el_O,'--b')
    
    x_el=x_el+x(i)+c(i).*sin(dir(i));
    y_el=y_el+y(i)+c(i).*cos(dir(i));
    
    plot(x_el,y_el,'--','color',grey)
    plot(x_el,y_el,'-','color',[0.9,0.9,0.9])
%
    hold on
end

    function [x_r,y_r]=rotate_m(x,y,rot_rad)
        x_r=x.*cos(rot_rad)-y.*sin(rot_rad);
        y_r=x.*sin(rot_rad)+y.*cos(rot_rad);
    end

end
