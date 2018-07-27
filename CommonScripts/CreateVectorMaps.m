% Script to creates figure 1 of WN paper (error calc example)

%function CreateVectorMaps()
%WindNinjaOutFolder='y:\A_DOCS ORIOL\thesis_PhD_Y\INVERSE MODELLING\PERIMETRES IF CARDONA\Cardona\QFire_files\WN_runs\out';
WindNinjaOutFolder='y:\A_DOCS ORIOL\thesis_PhD_Y\WindNinja\NEW_WN_runs\RUN_cases\Montseny\Montseny_300x300_15m\out';
[AllSpeedMapStrucGRD,AllDirMapStrucGRD]=LoadAllBaseMaps(WindNinjaOutFolder);


%% SETTINGS
U=5;
D=105;%135
Ubase=9;
DbaseSet=0:90:359;
%MAP subset to PLOT
% AX=[200,225]; %crop
% AY=[50,75]; %crop
AX=[200,210]; %crop
AY=[50,60]; %crop

CompareAndPlotWindMaps(U,D,Ubase,DbaseSet,AX,AY,AllSpeedMapStrucGRD,AllDirMapStrucGRD,WindNinjaOutFolder)


