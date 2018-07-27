function [theta_new]=angular_devaluate(theta,unit)
%[theta_new]=angular_devaluate(theta,unit)
% Resets theta between 0-2pi [rad]
%
% - theta (vector accepted)
% - unit [default 'r'] = 'r' = radians or 'd'= degree
%
%By ORios-14
flag_deg=0;
if nargin>1
    switch unit
        case {'d','deg'}
            theta=theta*pi/180;
            flag_deg=1;
    end
end
pi2=2*pi;
theta_new=theta-pi2*(floor(theta/pi2));
% if theta<0 
%     theta_new=theta-pi2*(ceil(theta/pi2)-1);
% elseif theta>pi2
%     theta_new=theta-pi2*floor(theta/pi2);
% else
%     theta_new=theta;
% end

if flag_deg==1
    theta_new=theta_new*180/pi;
end
end