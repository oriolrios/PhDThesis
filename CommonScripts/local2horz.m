function [XH_t,YH_t]=local2horz(X_t,Y_t,aspect_i,slope_i)
%[XH_t,YH_t]=local2horz(X_t,Y_t,aspect,slope)
%
% Proejct from Local slope plane to Horizontal plane
% transformation equations after FARSITE (page7)
% aspect in [rad] ?¿? comprovar!
% aspect/slope can be BOTH GRD_struct or grd value vectors
%
aspect180_i= aspect_i-pi; % Aspect N means S direction! 
[aspect180_i]=angular_devaluate(aspect180_i,'r');

%obre front
if isequal([X_t(end),Y_t(end)],[X_t(1),Y_t(1)]) %(es pot utilitzar una divisio si es vol acceptar una diferencia ~1)
    X_t(end)=[];
    Y_t(end)=[];
end

% Alternative: hypot (built-in function, not recomended for adimat)
front_dir=atan2(X_t,Y_t);
%front_dir=atan(X_t./Y_t);
D_i=sqrt(X_t.^2+Y_t.^2).*cos(aspect180_i-front_dir).*(1-cos(slope_i));

% In FARSITE it is said +/-... i don't know how to interpret it!!! 
% here I go with +

s1=ones(size(aspect180_i));
s2=s1; %correcció per [3pi/2:2pi]
s3=s1;

s1(aspect180_i>=pi)=-1;
%s1((aspect_i)>=3*pi/2 | (aspect_i)<=pi/2)=-1;

s2((aspect180_i > 3*pi/2 & aspect180_i < 2*pi) | (aspect180_i >pi/2 & aspect180_i < pi) )=-1;
s3((aspect180_i <  pi/2  & aspect180_i > 0) | (aspect180_i <  3*pi/2  & aspect180_i > pi) )=-1;

%sign_aspc_i((aspect_i-front_dir)<=pi)=-1;
%sign_aspc_i(aspect_i>=pi & aspect_i<=pi)=-1;

XH_t=X_t+s1.*(-s2.*+s3).*abs(D_i.*sin(aspect180_i));
YH_t=Y_t+s1.*(+s2).*abs(D_i.*cos(aspect180_i));

%%% XH_t=X_t+s1.*abs(D_i.*sin(aspect_i));
%%% YH_t=Y_t+s1.*abs(D_i.*cos(aspect_i));


end