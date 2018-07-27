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