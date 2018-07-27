function [theta_new,bounded_matx]=AngularBound(theta,unit,bound)
% Function to devaluate and bound angles
%
% INPUTS
% theta = vector or matrix of angles to bound
% units = units of theta:
%                       rad={'r'},{'rad'} (default)
%                       deg={'d'},{'deg'}
% bound = bound limits: (pay attencion in () [])
%                       {'0_2Pi'}= [0:2pi) (default)
%                       {'-Pi_Pi'}= (-pi:pi]
%                       {'Pi_3Pi'}= [pi:3pi)
%                       ...
% 
% OUTPUT
% theta_new
% bounded_matx = 1 or 0 if values is bounded. Works for vectors as well
%
%
% Example:
%
% AngularBound(3*pi)
% AngularBound(400,'d')
% AngularBound(-5*pi,'r','pi_3pi')
%
% History:
% $23/11/16: Add optional output bounded_matx
% ORios 2016
%% PROGRAM
% first devaluate to 0-2pi and converto to rad
[theta_new,flagDeg]=angular_devaluate2rad(theta,unit);

if nargin>2
%particular bounds    
    switch bound
        case '0_2Pi'
            
        case '-Pi_Pi'
            theta_new(theta_new>pi())=theta_new(theta_new>pi)-2*pi();
        case 'Pi_3Pi'
            theta_new(theta_new<pi())=theta_new(theta_new<pi)+2*pi();
        otherwise
            error('MyErr:AngularBound invalid input bound!')
    end
end

if flagDeg==1
    theta_new=theta_new*180/pi;
end

% Bounded Matrix
bounded_matx=theta_new./theta;
bounded_matx(bounded_matx~=1)=0;
bounded_matx=abs(bounded_matx-1);

%% Nested
    function [theta_new,flag_deg]=angular_devaluate2rad(theta,unit)
        %[theta_new]=angular_devaluate2rad(theta,unit)
        % Resets theta between 0-2pi [rad] (and converts to rad!)
        %
        % - theta (vector accepted)
        % - unit [default 'r'] = 'r' = radians or 'd'= degree
        %
        %By ORios-14
        if nargin>1
            switch unit
                case {'d','deg'}
                    theta=theta*pi/180;
                    flag_deg=1;
                case {'r','rad'}
                    flag_deg=0;
                otherwise
                    error('MyErr: Not valid unit!')
            end
        end
        pi2=2*pi;
        theta_new=theta-pi2*(floor(theta/pi2));
    end
end