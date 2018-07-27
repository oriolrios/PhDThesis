% Version 2: Vectorized
% **************************************************************************
%                        REGRIDING SCHEME (Oriol Version)
% **************************************************************************
%     l1 and l2 are the lengths of line segments where v1, v2, v2r and v3 are vectors of 3 conjoining line segments.  The angle between
%     v1/v2 and v2r/v3 is determined using the dot product.  Once the angles, omega1 and omega2 have been determined they are compared to a preset
%     criterion.
%     The miminum of the two angles is determined and if it is less than approximately 90 degrees than  The newx and newy points are inserted into the
%     previous x and y array and % the process is repeated until the onditions are satisfied and the curve is adequately discretized.
%     the following algorithms is necessary when the fire front is making its way around a boundary and the curve produces
%
%     ADD DEGRID capabilities in else case!
%     TRESHOLDS in LINE 42 & 58!!!
function [newxy]=regridding(x,y)
%T= 1;% Recgridding threshold (Richards 1)
T=pi/10; % the smaller T the smoother the front!
norm_min = 2; % [m] min distance between nodes TO DEGRID (whatever angular relation!
% Sensiblitat actual >pi/4

% create all vectors
xy_1 = [x y];
xy_2 = [x(2:end) y(2:end); x(1) y(1)];
xy_3 = [x(3:end) y(3:end); x(1:2) y(1:2)];

v_1=diff(xy_1);
v_2=diff(xy_2);
v_3=diff(xy_3);

N_1=sqrt(v_1(:,1).^2+v_1(:,2).^2);
N_2=sqrt(v_2(:,1).^2+v_2(:,2).^2);
N_3=sqrt(v_3(:,1).^2+v_3(:,2).^2);

cosomega1 = dot(v_1,v_2,2)./(N_1.*N_2);
cosomega2 = dot(v_2,v_3,2)./(N_2.*N_3);

omega1 = acos(cosomega1); %in radians
omega2 = acos(cosomega2);

newx=x;
newy=y;
j=0;
%%% old regridd % % % % degrid=[];
delete_points_ind=[];
count=0;
for i=1:(size(cosomega1,1)-1)
    [c,ind]=max([omega1(i) omega2(i)]);
    %if c >(T/180*pi) %as Sara McAlister
    if c >T %&& N_1(i)>norm_min/2
        if ind==1
            %disp('dins1')
            xt=x(i)+0.5*(x(i+1)-x(i)); % point in the midle of the segment
            yt=y(i)+0.5*(y(i+1)-y(i));
            newx=[newx(1:i+j);xt;x(i+1:end)];
            newy=[newy(1:i+j);yt;y(i+1:end)];
        else %second angle
            %disp('dins2')
            xt=x(i+1)+0.5*(x(i+2)-x(i+1));
            yt=y(i+1)+0.5*(y(i+2)-y(i+1));
            newx=[newx(1:i+1+j);xt;x(i+2:end)];
            newy=[newy(1:i+1+j);yt;y(i+2:end)];
        end
        j=j+1;
% DEGRID of points with distance less than norm_min and flats
    elseif  N_1(i)<norm_min %&& c<2*5/180*pi % 5 deg
        %newx(i+j+1)=[];
        %newy(i+j+1)=[];
        delete_points_ind=[delete_points_ind, (i+j+1)];
        %j=j-1;
%%% old regridd % % % %         degrid=[degrid;newx(i+j+1),newy(i+j+1)];
    end
end
%% OLD
%remove DEGRIDDING points PQ NO VA SENSE AIXÖ? PQ ES GENEREN TANTS PUNTS?
%%% old regridd % % % % if ~isempty(degrid)
%%% old regridd % % % %     disp('dins')
%%% old regridd % % % %     ind_logic=ismember([newx newy],degrid ,'rows');
%%% old regridd % % % %     % què tal fer anar Unique??
%%% old regridd % % % %     % unique(A,'rows'
%%% old regridd % % % %     ind=1:(size(newx,1));
%%% old regridd % % % %     index=ind(ind_logic);
%%% old regridd % % % %     %[newx(index) newy(index)]
%%% old regridd % % % %     %disp('degridded')
%%% old regridd % % % %     newx(index)=[];
%%% old regridd % % % %     newy(index)=[];
%%% old regridd % % % %
%%% old regridd % % % % end
%% end OLD
delete_points_ind=unique(delete_points_ind); %filter repetitions!
newx(delete_points_ind)=[];
newy(delete_points_ind)=[];
newxy=[newx newy];
end










