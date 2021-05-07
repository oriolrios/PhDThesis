function [theta_front]=front_normal_angle(x,y)
% To obtain the normal direction of a front (perpendicular to it)
% After Lautenberger 2013 pg 291
% Nota: això es calcula també a richard_integration (optimitzar?)
%
% History:
% Centered spatial diferences (As FARSITE, (no divided by anything))
% For rows and columns!
% Cases optimization: TO DO!

% % if ~isequal([x(end),y(end)],[x(1),y(1)])
% %     x(end+1)=x(1);
% %     y(end+1)=y(1);
% % end
% %
% % dxs=diff(x);
% % dys=diff(y);

if size(x,1)>size(x,2) % if colum
    dxs=[x(end); x(1:end-1)]-[x(2:end) ; x(1)];
    dys=[y(end); y(1:end-1)]-[y(2:end) ; y(1)];
    
else % if row
    dxs=[x(end) x(1:end-1)]-[x(2:end) x(1)];
    dys=[y(end) y(1:end-1)]-[y(2:end) y(1)];
end

%theta_front = atan2((-dys),(dxs)); % NO VA, DEMOSTRAT!

for i=1:length(dxs)
    % cases
    if     dxs(i)>0 && dys(i)>=0
        theta_front(i)=pi/2-atan(dys(i)/dxs(i));
        
    elseif dxs(i)<0 && dys(i)>=0
        theta_front(i)=3*pi/2+atan(dys(i)/abs(dxs(i)));
        
    elseif dxs(i)<0 && dys(i)<=0
        theta_front(i)=3*pi/2-atan(dys(i)/dxs(i));
    elseif dxs(i)>0 && dys(i)<=0
        theta_front(i)=pi/2+atan(abs(dys(i))/dxs(i));
        
    end
    
end
theta_front=theta_front'+pi/2; % CORRECTE! Respecte l'eix N.
[theta_front]=angular_devaluate(theta_front); %Resets theta between 0-2pi [rad]
end