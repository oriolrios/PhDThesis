function [dxs,dys]=FrontCenteredDifferences(x,y)
% Calculates front centered spatial diferences 
% (As FARSITE (no divided by anything))
% Works for rows and columns!
if size(x,1)>size(x,2) % if colum 
    dxs=[x(end); x(1:end-1)]-[x(2:end) ; x(1)];
    dys=[y(end); y(1:end-1)]-[y(2:end) ; y(1)];
    
else % if row
    dxs=[x(end) x(1:end-1)]-[x(2:end) x(1)];
    dys=[y(end) y(1:end-1)]-[y(2:end) y(1)];
end