function [a_i,b_i,c_i]=getABC(U_i,RoS_i)
% Calculates Huygens a,b,c ellipse parameters as FARSITE (Anderson1983 & Alexander1985)
% Canadian system alternative definition:
%   Rate of Spread       ROS  = a+c
%   Flank Rate of Spread FROS = b 
%   Back Rate of Spread  BROS = a-c
% ROS, FROS, BROS can be taken from CFSFBP database.
% 
% History
% 15/04/16 - Correcció UNITATS!
% INPUTS
% U [m/s]
% RoS_i [m/s]
% 
% OUTPUTS
% a_i,b_i,c_i [m/s]
%
% NO cal fer canvi unitats de ROS (és només un factor!) Comprovat. PER

LB=0.936*exp(0.2566.*U_i)+0.461*exp(-0.1548*U_i)-0.397;
HB=(LB+sqrt(LB.^2-1))./(LB-sqrt(LB.^2-1));

    a_i=0.5*RoS_i.*(1+1./HB)./LB;
    b_i=RoS_i.*(1+1./HB)/2;
    c_i=b_i-RoS_i./HB;

end