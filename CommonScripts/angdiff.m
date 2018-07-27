function a = angdiff(v1, v2, unit)
% Calc proper angular substraction. Default Unit rad!
% falta potser posar un AngularBound...
% EXAMPLES: 
% a = angdiff(10, 359, 'd')
% a = angdiff(0, pi)
% a = angdiff([10,0], [359,1], 'd')
%
% UPDATED
% $ 23/11/16 Supports row-vector input! (same length both!)
unit_change=0;
if nargin>2
    if strcmp(unit,'d')
        v1=d2r(v1);
        v2=d2r(v2);
        unit_change=1;
    end     
end

% v1=AngularBound(v1);
% v2=AngularBound(v2);

v1x = cos(v1);
v1y = sin(v1);

v2x = cos(v2);
v2y = sin(v2);

% a = acos([v1x v1y]*[v2x v2y]'); %ORIGINAL
a = acos([v1x' v1y']*[v2x' v2y']');
a=a(:,1)'; %->correct calc!

if unit_change==1
    a= r2d(a);
end

%nested functions
function vr= d2r(vd)
    vr=vd/180*pi;
end

function vd= r2d(vr)
    vd=vr*180/pi;
end

end
