% INPUT FILE FOR smartQFIRE_all
% **************** %
%WindNinjaOutFolder='d:\Dropbox\QFIRE_tests\SmartQGIS_Montseny\WN_runs\out';
%NO CAL


% SAVING NAME = INPUT FILE NAME-------------------%
%SaveNameMat='VaLlobrega_Farsite_SDI_3h';         %
p=strsplit(mfilename('fullpath'),'\');            %
SaveNameMat = p{end};  % get input file name      %
% ------------------------------------------------%
RunExpansion=0; %0 no run
FigSavePath='y:\A_DOCS ORIOL\thesis_PhD_Y\INVERSE MODELLING\QFIRE_tests\SmartQFIRE_7inv_real_validations\src\gestosa\figures';
% **************** %
OptIndexCh='SDI';   % 'CostArea','SDI','Sorensen','Jaccard','SDI_a','Sorensen_a','Jaccard_a';
% ------------ PARALLEL ---------------------------------$
ParallelPool=0; % 1-> parpool (local confg) ON 0-> off
% IF PARPOOL NOT RUNNING, INNITIATE
%NWorkers=30;%if nothing, takes default setting
%parpool('local',NWorkers)
% ------------ PARALLEL ---------------------------------$
plotting=0; % hillshade plotting

%---!! DO NOT WORK IF PARPOL ON!!!-------
SaveOut=0 ;% 0-> not save 1-> save (INTERMEDIATE SDI values) 
% --------------------------------------- %


plot_GoogleEarth = 0;
inv_char={'Mf[%]','Mx[%]','SAV [1/m]','Wo[kg/m^2]','U [m/s]','\theta[deg]','\delta[m]'};
% ---------------- %
weight            = 'expN';     % idty->W=II lin->linear (no normalized)  linN->linear norm  exp->exp % 'idty','lin','linN','expN'
%light_plots      = 1;    % Cada quantes iteracions dibuixar
%max_iteration    = 6;    % Maxim number of iteration to perform
tObsIni           = 1;
numTobs           = 6;%3 % sum one!!
IsocStep          = 1; %15 % number of isochrones to jump! (defineix també el time step real DT=isochrone_step*dt_isochrone
forecastTime      = 1; % define time vector to launch forecast (from last assimilated point) = 0:60:600;
%                       % Defineix també el time step pel forecast. Necessari per comparar

% ************ %
%
dt = 25;        %  fixed diff eq. integration time (s)
res =5;        %  degridding distance ressolution (m)


OptIndexStrng={'CostArea','SDI','Sorensen','Jaccard','SDI_a','Sorensen_a','Jaccard_a'};

%% PLOT

%% MONTSENY SINTETIC
plotName='GestosaEx1_bo';
 %load('y:\A_DOCS ORIOL\thesis_PhD_Y\INVERSE MODELLING\QFIRE_tests\SmartQFIRE_7inv_real_validations\src\gestosa\gestosa_isochrones_and_MDT.mat')
 %load('y:\A_DOCS ORIOL\thesis_PhD_Y\INVERSE MODELLING\QFIRE_tests\SmartQFIRE_7inv_real_validations\src\gestosa\gestosa_isochrones_and_MDT_fmask_bo.mat')
 load('y:\A_DOCS ORIOL\thesis_PhD_Y\INVERSE MODELLING\QFIRE_tests\SmartQFIRE_7inv_real_validations\src\gestosa\gestosa_isochrones_and_MDT_fmask_bo_bo_bo.mat')
     aspect = aspect;
     slope = slope; 
     fmask=fmask;

 %isochrons=iso; 
 isochrons=isoPlus1000; %desplaçades 1000m
 
 
%Mf, Mx, SAV, L, U, theta, fuel_depth
%I=[0.3,0.4,3000,2,3,90/180*pi,1];% (form cardona)
%I=[0.2,0.304,3000,10,1,0,1];% invertir vent 180 deg
I=[0.2,0.304,3000,1,3,0/180*pi,1];% invertir vent 180 deg
% EXPANSION
%xiyi= check_sense_xiyi(isochrons.xy{tObsIni});
%realAdTime= 0:1000:6000;
%realAdTime= 0:1200:10800;
%dt=0:100:200;
