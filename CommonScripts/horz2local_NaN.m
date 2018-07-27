function [xL_s,yL_s]=horz2local_NaN(x_s,y_s,aspect,slope)
% transformation equations after FARSITE (page7)
% aspect in [rad] ?¿? comprovar!
% aspect/slope can be BOTH GRD_struct or grd value vectors
%
% History:
% $comentat l'obrir fronts! fallen dimensions aspect i slope si no..
%
%ADIMAT change!
%[slope_i,aspect_i]=GetGRDValueIfNeeded;
aspect_i=aspect;
slope_i=slope;

aspect180_i= aspect_i-pi; % Aspect N means S direction! 
[aspect180_i]=angular_devaluate(aspect180_i,'r'); % Important [0,2pi]

% AIXÒ ho comento perquè fallen les dimensions de l'aspect si no!
% %obre front
% if isequal([x_s(end),y_s(end)],[x_s(1),y_s(1)]) %(es pot utilitzar una divisio si es vol acceptar una diferencia ~1)
%     x_s(end)=[];
%     y_s(end)=[];
% end
% hypot (built in function, not recomended for adimat)

% atan2 (sembla que no modifica res!)
alpha_i = atan2((y_s),(x_s));
[alpha_i]=angular_devaluate(alpha_i,'r'); % Important [0,2pi]
%alpha_i = atan((y_s)./(x_s));

%plot(alpha_i,'-+')

di_i   = atan((tan(aspect180_i-alpha_i))./cos(slope_i));

%di_i    = atan2(tan(aspect_i-alpha_i),cos(slope_i));

s1=ones(size(aspect180_i));
s2=s1; %correcció per [3pi/2:2pi]
s3=s1;

s1(aspect180_i>=pi)=-1;
%s1((aspect_i)>=3*pi/2 | (aspect_i)<=pi/2)=-1;

s2((aspect180_i > 3*pi/2 & aspect180_i < 2*pi) | (aspect180_i >pi/2 & aspect180_i < pi) )=-1;
s3((aspect180_i <  pi/2  & aspect180_i > 0) | (aspect180_i <  3*pi/2  & aspect180_i > pi) )=-1;

%sign_aspc_i((aspect_i-alpha_i)<=pi)=-1;
%sign_aspc_i(aspect_i>=pi & aspect_i<=pi)=-1;

D_i=sqrt(x_s.^2+y_s.^2).*cos(di_i).*(1-cos(slope_i));

% In FARSITE it is said +/-... i don't know how to interpret it!!! 
% here I go with the empirically based configuration
xL_s=x_s+s1.*(-s2.*s3).*abs(D_i.*sin(aspect180_i));
yL_s=y_s+s1.*(+s2).*abs(D_i.*cos(aspect180_i));

%%% xL_s=x_s+s1.*abs(D_i.*sin(aspect_i));
%%% yL_s=y_s+s1.*abs(D_i.*cos(aspect_i));
% % % Nested Functions
% %     function [slope_i,aspect_i]=GetGRDValueIfNeeded
% %         %Slope
% %         if isstruct(slope) % get aspect vlaues vector
% %             if ~exist('x_i','var') || ~exist('y_i','var')
% %                 error('If slope is input as GRD, xy coordinates are required!')
% %             end
% %             slope_i =getGRDvalue(slope,x_s,y_s);
% %         else
% %             slope_i=slope;
% %         end
% %         %Aspect        
% %         if isstruct(aspect) % get aspect vlaues vector
% %             if ~exist('x_i','var') || ~exist('y_i','var')
% %                 error('If aspect is input as GRD, xy coordinates are required!')
% %             end
% %             aspect_i =getGRDvalue(aspect,x_s,y_s);
% %         else
% %             aspect_i=aspect;
% %         end
% %         
% %     end

end