function [thetaH]=AngularNorth2HorzCCW(thetaN)
%
% thetaN -> [rad]
% Transforms form CC to CCW and from NORTH to HORZ angle
% verified!
[theta]=angular_devaluate(thetaN);
[theta]=angular_devaluate(-thetaN); %% CC -> CCW
theta=theta+pi/2;
[thetaH]=angular_devaluate(theta);