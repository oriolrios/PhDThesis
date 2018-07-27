function [xy_fronts_mod]=desplaca_isochrones(xy_fronts, xoffset, yoffset, iterations)
% Desplaça isochrones per tal de poder fer correr l'optimització lluny del 0
% INPUTS
% 
% (optional)
% iterations= Size of cell (columns)

if nargin>3
    dim_ji(1)=size(xy_fronts,1);
    dim_ji(2)=iterations;
else
    dim_ji=size(xy_fronts);
end

xy_fronts_mod=cell(dim_ji);
for j=1:dim_ji(2)
    for i=1:dim_ji(1)
        xy_fronts_mod{i,j}=[(xy_fronts{i,j}(:,1)+xoffset),(xy_fronts{i,j}(:,2)+yoffset)];
    end
end
