function CompareAndPlotWindMaps(U,D,Ubase,DbaseSet,AX,AY,AllSpeedMapStrucGRD,AllDirMapStrucGRD,WindNinjaOutFolder)
% Aux finction to plot wind maps

% CALCULATING
Ui=find(AllDirMapStrucGRD.AllU==U,1);
if isempty(find(AllDirMapStrucGRD.AllU==Ubase, 1))
    error('MyErr: Wanted Ubase is not existent in folder (%s)',sprintf('%d,',AllDirMapStrucGRD.AllU))
end

if isempty(Ui)
    error('MyErr: Wanted Speed is not existent in folder (%s)',sprintf('%d,',AllDirMapStrucGRD.AllU))
end

Di=find(AllDirMapStrucGRD.Deg==D,1);
if isempty(Di)
    error('MyErr: Wanted Dir is not existent in folder (%s)',sprintf('%d,',AllDirMapStrucGRD.Deg))
end


UU=AllSpeedMapStrucGRD.dataStrc{Di,Ui};
DD=AllDirMapStrucGRD.dataStrc{Di,Ui}; % deg to rad
%quiver(UU.*cos(DD),UU.*sin(DD))
UU_crop=UU(AX(1):AX(2),AY(1):AY(2));
DD_crop=DD(AX(1):AX(2),AY(1):AY(2));
u=UU_crop.*cos(DD_crop./180*pi);
v=UU_crop.*sin(DD_crop./180*pi);
%quiver(u,v) -> maltab func (no color)


%% perform interpolation
% [NewSpeedMap,
% NewDirMap]=SpeedDirMapInterpol_Select(WindNinjaOutFolder,15,D,Ubase,DbaseSet);DEBUG ONLY
[NewSpeedMap, NewDirMap]=SpeedDirMapInterpol_Select(WindNinjaOutFolder,U,D, Ubase,DbaseSet);
New_UU_crop=NewSpeedMap(AX(1):AX(2),AY(1):AY(2));
New_DD_crop=NewDirMap(AX(1):AX(2),AY(1):AY(2));
New_u=New_UU_crop.*cos(New_DD_crop./180*pi);
New_v=New_UU_crop.*sin(New_DD_crop./180*pi);

u_diff=u-New_u;
v_diff=v-New_v;

figure
%% Just to compare --------------------
% ss1=subplot(2,3,4);
ss1=subplot(1,3,1);
imagesc(sqrt(u.^2+ v.^2));hh1=colorbar;set(gca,'YDir','normal');
% ss2=subplot(2,3,5);
ss2=subplot(1,3,2);
imagesc(sqrt(New_u.^2+ New_v.^2));hh2=colorbar;set(gca,'YDir','normal');
% a=hh1.Xtick;

Tmax=max([hh1.Limits(2),hh2.Limits(2)]);
Tmin=min([hh1.Limits(1),hh2.Limits(1)]);
    caxis(ss1,[Tmin,Tmax])
    caxis(ss2,[Tmin,Tmax])

    
% ss3=subplot(2,3,6);
ss3=subplot(1,3,3);
imagesc(sqrt(u_diff.^2+ v_diff.^2));hh3=colorbar;set(gca,'YDir','normal')
fH=figure('Name',sprintf('%s, U=%d [m/s], D=%d [deg], Ub=%d [m/s], Dstp=%d [deg]', AllSpeedMapStrucGRD.MapName, AllSpeedMapStrucGRD.AllU(Ui), AllSpeedMapStrucGRD.Deg(Di),Ubase,DbaseSet(2)-DbaseSet(1)));
%% Just to compare --------------------

%% homogenization
maxU=max([max(UU_crop(:)),max(New_UU_crop(:))]);
[autoscale1]=GetCommonCBarScaling(u,v);
[autoscale2]=GetCommonCBarScaling(New_u,New_v);
MaxAutoscale=min([autoscale1,autoscale2]);
[u, v]=DoAutoScaling(u,v,MaxAutoscale);
[New_u, New_v]=DoAutoScaling(New_u,New_v,MaxAutoscale);

%% PLOTTING
sp1=subplot(2,3,1);
%plotMyquiver(UU_crop,DD_crop./180*pi,sp1)

% MyQuivercAuto(u,v,MaxAutoscale)

MyQuiverc(u,v,maxU)
caxis(sp1,[Tmin*MaxAutoscale,Tmax*MaxAutoscale])

xlim([0, size(UU_crop,1)])
ylim([0, size(UU_crop,2)])
box on
title('Wn original run')
% axis equal

sp2=subplot(2,3,2);
%plotMyquiver(New_UU_crop,New_DD_crop./180*pi,sp2)

% MyQuivercAuto(New_u,New_v,MaxAutoscale)

MyQuiverc(New_u,New_v,maxU)
caxis(sp2,[Tmin*MaxAutoscale,Tmax*MaxAutoscale])

xlim([0, size(UU_crop,1)])
ylim([0, size(UU_crop,2)])
title('Interpolation')
% axis equal
box on

%% Plot Difference
sp3=subplot(2,3,4);

%plotMyquiver(New_UU_crop-UU_crop,(New_DD_crop-DD_crop)./180*pi,sp2)

% u_diff=(New_UU_crop-UU_crop).*cos((New_DD_crop-DD_crop)./180*pi);
% v_diff=(New_UU_crop-UU_crop).*sin((New_DD_crop-DD_crop)./180*pi);
[u_diff, v_diff]=DoAutoScaling(u_diff,v_diff,MaxAutoscale);
hC=MyQuiverc(u_diff,v_diff,MaxAutoscale);
caxis(sp3,[Tmin*MaxAutoscale,Tmax*MaxAutoscale])
xlim([0, size(UU_crop,1)])
ylim([0, size(UU_crop,2)])
title('Original-Interpolation')
fH.Position=[1763         229        1410         722];% MOlt necessar pq surti bé!
box on
hC.Ticks=hC.Limits(1):(hC.Limits(2)-hC.Limits(1))/(numel(hh3.Ticks)-1):hC.Limits(2);
hC.TickLabels=hh3.TickLabels;
% axis equal

%% Add common colorbar
%
% hC1=colorbar('peer',sp1);
% hC2=colorbar('peer',sp2);
% %find max
% Max_1=max(UU_crop(:));
% Max_2=max(New_UU_crop(:));
% CeilMax=ceil(max([Max_1,Max_2]));
% MaxDifTick1=(CeilMax-Max_1)/Max_1;
% MaxDifTick2=(CeilMax-Max_2)/Max_2;
% 
% hC1.Ticks=[0:(1+MaxDifTick1)/10:1+MaxDifTick1];
% hC1.TickLabels=sprintf('%g\n',hC1.Ticks.*CeilMax);
% hC1.Label.String='Wind Speed [m/s]';
% 
% hC2.Ticks=[0:(1+MaxDifTick2)/10:1+MaxDifTick2];
% hC2.TickLabels=sprintf('%g\n',hC2.Ticks.*CeilMax);
% hC2.Label.String='Wind Speed [m/s]';


%% NESTED FUNCITONS
    function [autoscale]=GetCommonCBarScaling(u,v)
        [~,x,y,u,v] = xyzchk(u,v);
        if min(size(x))==1, n=sqrt(numel(x)); m=n; else [m,n]=size(x); end
        delx = diff([min(x(:)) max(x(:))])/n;
        dely = diff([min(y(:)) max(y(:))])/m;
        len = sqrt((u.^2 + v.^2)/(delx.^2 + dely.^2));
        autoscale = 0.9 / max(len(:));
    end

    function [u_scaled, v_scaled]=DoAutoScaling(u,v,autoscale)
        u_scaled = u*autoscale; v_scaled = v*autoscale;
    end
end