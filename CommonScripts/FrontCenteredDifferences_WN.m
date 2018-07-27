function [dxs,dys]=FrontCenteredDifferences_WN(x,y)
% Calculates front centered spatial diferences. One per each node.
% This version calculates it WRONGLY! but is needed for all version till
% *_WN
%
% HISTORY
% $29.07.16 Correcte no cal dividir per As, simplement marca 2 punts. 
% $29.07.16 Error Must be calculated counter clock wise!! Corrected
%
% Works for rows and columns!
% % %%AS FARSITE (no divided by anything))
% % if size(x,1)>size(x,2) % if colum 
% %     dxs=[x(2:end) ; x(1)] -[x(end); x(1:end-1)];
% %     dys=[y(2:end) ; y(1)]- [y(end); y(1:end-1)];
% %     
% % else % if row
% %     dxs=[x(2:end) x(1)]-[x(end) x(1:end-1)];
% %     dys=[y(2:end) y(1)]-[y(end) y(1:end-1)];
% % end
% 
% %% AS PROMETHEUS (see pag 38)
if size(x,1)>size(x,2) % if colum 
    dxs=[x(2:end) ; x(1)] -[x(end); x(1:end-1)];
    dys=[y(2:end) ; y(1)]- [y(end); y(1:end-1)];
    
else % if row
    dxs=[x(2:end) x(1)]-[x(end) x(1:end-1)];
    dys=[y(2:end) y(1)]-[y(end) y(1:end-1)];
end
dxs=dxs/(2*2*pi/numel(x));
dys=dys/(2*2*pi/numel(y));





%% OLD (inversley centered!)
%%AS FARSITE
% if size(x,1)>size(x,2) % if colum 
%     dxs=[x(end); x(1:end-1)]-[x(2:end) ; x(1)];
%     dys=[y(end); y(1:end-1)]-[y(2:end) ; y(1)];
%     
% else % if row
%     dxs=[x(end) x(1:end-1)]-[x(2:end) x(1)];
%     dys=[y(end) y(1:end-1)]-[y(2:end) y(1)];
% end

% %% AS PROMETHEUS (see pag 38)
% if size(x,1)>size(x,2) % if colum 
%     dxs=[x(end); x(1:end-1)]-[x(2:end) ; x(1)];
%     dys=[y(end); y(1:end-1)]-[y(2:end) ; y(1)];    
% else % if row
%     dxs=[x(end) x(1:end-1)]-[x(2:end) x(1)];
%     dys=[y(end) y(1:end-1)]-[y(2:end) y(1)];
% end
% dxs=dxs/(2*2*pi/numel(x));
% dys=dys/(2*2*pi/numel(y));