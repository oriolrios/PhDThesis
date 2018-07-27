realAdTime=0:120:1800; % s->30min

plotting= 1; %no plot
tObsIni           = 1;
numTobs           = length(realAdTime);%3 % sum one!!
IsocStep          = 1; %15 % number of isochrones to jump! (defineix també el time step real DT=isochrone_step*dt_isochrone

plotName='Montseny Synth Compare';
 load('y:\A_DOCS ORIOL\thesis_PhD_Y\INVERSE MODELLING\QFIRE_tests\SmartQGIS_Montseny_WN\WN_vs_INTER_NoWN\MO_MDT\MO2matlab.mat')
%      fuel = fuelMO; 
%      aspect = aspectMO;
      slope = slopeHalf; % halved slope to have LESS terrain effect!
 %load('xy_fronts_MO.mat')
 %isochrons=xy_fronts;
dt=10;
res=20;
 
 xy_real=xy_ini;
 
 xy_iniMAT=flipud(xy_ini{1});
 xy_real{1}=xy_iniMAT;
 xiyi=xy_iniMAT;
 
 % CAL SELECCIONAR U i D q estiguin SIMULADES!!! (manulament!)
%Mf, Mx, SAV, L, U, theta, fuel_depth
% I=[0.3,0.4,5000,1,7,3*pi/2,1];
% I=[0.3,0.4,3000,2,8,pi/3,1];
I=[0.2,0.4,5000,2,8,pi,1];
I(5)=5; %m/s
% I(5)=2.7; %m/s
% I(5)=1.1; %m/s
%I(6)=45*pi/180; %m/s
%I(6)=(360-30)*pi/180; %m/s % HI HA UNA DESCORRLACIÓ DE 90º!!

%I(6)=30*pi/180; %m/s % HI HA UNA DESCORRLACIÓ DE 90º!!

WindNinjaOutFolder='y:\A_DOCS ORIOL\thesis_PhD_Y\INVERSE MODELLING\QFIRE_tests\SmartQGIS_Montseny_WN\WN_vs_INTER_NoWN\WNRUNS_Montseny_NO_Inter';