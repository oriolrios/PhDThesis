function [theta_new]=AngularBound_Pi3Pi(theta,unit)
% Bounds angles between pi and 3pi.
%[theta_new]=angular_devaluate(theta,unit)
% Resets theta between pi-3pi [rad]
%
% - theta (vector accepted)
% - unit [default 'r'] = 'r' = radians or 'd'= degree
%
%By ORios-16
% devaluate just in case
[theta_new]=angular_devaluate(theta,unit);

%Handle Units
flagDeg=0;
if nargin>1
    switch unit
        case {'d','deg'}
            theta_new=theta_new*pi/180;
            flagDeg=1;
        case {'r','rad'}
            
        otherwise
            error('MyErr: Not valid unit!')
    end
end
theta_new(theta_new<pi())=theta_new(theta_new<pi)+2*pi();

if flagDeg==1
    theta_new=theta_new*180/pi;
end
        

%% Nested
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
                case {'r','rad'}
                    
                otherwise
                    error('MyErr: Not valid unit!')
            end
        end
        pi2=2*pi;
        theta_new=theta-pi2*(floor(theta/pi2));
        
        if flag_deg==1
            theta_new=theta_new*180/pi;
        end
    end
end