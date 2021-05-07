function [xy_inter, int_adj]= intersect2segments(Vxy1, Vxy2)
%% Finds if segment xy1 intersects with segment xy2
%  If doesn't intersect xy_inter=NaN
% MODIFICAR per acceptar matrius fetes
% FALLA QUAN NOMÉS S'INTRUDEIX UN VECTOR I NO INTERSECCIONA!!!
% Adapted from: [intersect_flag]= intersect4points(xy1, xy2)
%
%  INPUTS
%   Vxy1,Vxy2       = Nx4 aray with [x_i y_i x_f y_f]
%
% OUTPUTS
%   xy_inter        = [x_inter, y_inter]
%   int_adj         = adjacent intersection matrix; 0= no intersection; 1=intersection
%
% ALGORITHM
% r= p2-p1
% s= p4-p3
% u = (p3 - p1) × r / (r × s)
% intersect_flag=s1 ifonly u<1
%
% Now there are five cases:
%
% -If r × s = 0 and (q ? p) × r = 0, then the two lines are collinear. If in
%       addition, either 0 ? (q ? p) · r ? r · r or 0 ? (p ? q) · s ? s · s, then
%       the two lines are overlapping. NOT POSSIBLE HERE
% -If r × s = 0 and (q ? p) × r = 0, but neither 0 ? (q ? p) · r ? r · r
%       nor 0 ? (p ? q) · s ? s · s, then the two lines are collinear but disjoint.
% -If r × s = 0 and (q ? p) × r ? 0, then the two lines are parallel and non-intersecting.
% -If r × s ? 0 and 0 ? t ? 1 and 0 ? u ? 1, the two line segments meet at the point p + t r = q + u s.
% Otherwise, the two line segments are not parallel but do not intersect.?¿?
%%
if size(Vxy1)~=size(Vxy2)
    error('MyErr: Size Vxy1~Vxy2!!!')
end

r= [Vxy1(:,3)-Vxy1(:,1) Vxy1(:,4)-Vxy1(:,2)];
s= [Vxy2(:,3)-Vxy2(:,1) Vxy2(:,4)-Vxy2(:,2)];

cross_r_s=r(:,1).*s(:,2)-r(:,2).*s(:,1);

%if cross_r_s~=0 %meaning intersection MODIFICAR AIXÖ!!! VECTORITZAR!! PETA
%SI UN FALS!!!! SEMBLA QUE ARA SIII

q_p=(Vxy2(:,1:2)-Vxy1(:,1:2)); 

% % Tried this for efficiency but does not speed it up
% % Vxy2_pq=Vxy2(:,1:2);
% % Vxy1_pq=Vxy1(:,1:2);
% % q_p=Vxy2_pq-Vxy1_pq;


cross_q_p_r=q_p(:,1).*r(:,2)-q_p(:,2).*r(:,1);
cross_q_p_s=q_p(:,1).*s(:,2)-q_p(:,2).*s(:,1);

u=cross_q_p_r./cross_r_s;
t=cross_q_p_s./cross_r_s;

%         if t>=0 && t<=1 && u>=0 && u<=1
%         %if t>0 && t<1 && u>0 && u<1
%             xy_inter=Vxy1(:,1:2)+t*r;
%         end
% VECTORITZACIÓ LÒGICA (també funciona d'un en un)


% ACTIVAR l'IF pq no peti si no entra una matriu.

%només dos punts
if size(Vxy1,1)==1 
    xy_inter=Vxy1(:,1:2)+t*r;
    int_adj=~isnan(xy_inter(1,1));
% més de dos punts
else 
    %int_adj=t>0.01 & t<0.99 & u>0.01 & u<0.99; % NO volem que si es toquen pel vertex sigui intersecció
    int_adj=t>0.001 & t<0.999 & u>0.001 & u<0.999; % NO volem que si es toquen pel vertex sigui intersecció
% ABANS
%   xy_inter=Vxy1(int_adj,1:2)+[t(int_adj),t(int_adj)].*r(int_adj,:);

%MODIFICAT Si es compleix, corregim AQUEST PAS FALLA ADIMAT VECTORIAL!    
    if any(int_adj~=0) 
        xy_inter=Vxy1(int_adj,1:2)+[t(int_adj),t(int_adj)].*r(int_adj,:);
    else
        xy_inter=Vxy1(int_adj,1:2);
    end
end

end
%cases
%intersect_flag=zeros(length(u),1);
%filtering cases
%intersect_flag(isinf(intersect_flag))=0;
%intersect_flag(isnan(intersect_flag))=0;
%intersect_flag(0<u & u<1)=1;

