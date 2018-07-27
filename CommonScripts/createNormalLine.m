function line=createNormalLine(x,y,m)
% creates NORMAL to m line represented in parametric form:
% [x0 y0 dx dy], given a point and the slope of the direction vector.
%   x = x0 + t*dx
%   y = y0 + t*dy;
m=-1./m;
line=[x y cos(atan(m)) sin(atan(m))]; % estan tots els valors contemplats?? 
end