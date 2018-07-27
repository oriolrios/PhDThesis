function [thetaH]=AngularNorth2Horz_From2BlowCW(thetaN, unit)
% Translate Angles:
%                  from NORTH and FROM where wind blows to:
%                  from HORZ  and TOWARDS wind blows
%                  from CCW to CC
% thetaN -> [rad]
% Transforms form CC to CCW and from NORTH to HORZ angle
% verified!

if nargin==1
    unit='r'; %default
end

[thetaN,flag_deg]=angular_devaluate2rad(thetaN,unit);

[thetaH]=angular_devaluate(thetaN-pi/2); %% from where blows towards
[thetaH]=angular_devaluate(pi-thetaH);
if flag_deg==1
    thetaH=thetaH/pi*180;
end