function [thetaH]=AngularHorz2North_Blow2FromCW(thetaN, unit)
% Translate Angles:
%                  from HORZ and TOWARDS where wind blows to:
%                  from NORTH  and  FROM wind blows
%                  from CC to CCW
% thetaN -> [rad]
% Transforms form CCW to CC and from HORZ to NORTH angle
% verified!

if nargin==1
    unit='r'; %default
end

[thetaN,flag_deg]=angular_devaluate2rad(thetaN,unit);

[thetaH]=angular_devaluate(thetaN-pi);
thetaH=angular_devaluate(pi/2-thetaH); %% from where blows towards

if flag_deg==1
    thetaH=thetaH/pi*180;
end