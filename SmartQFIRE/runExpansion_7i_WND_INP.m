% SmartQFIRE
% Uses Matlab optimization FMINUNC i FMINCON algorithms to run the
% assimilation
%
% History
% $30.06.16 Use Mf, Mx, SAV, L, U, theta,D, fuel_depth as invariants!
% $22.07.16 Add WindNinja
% $21.10.16 IS FUNCTION and wants INPUT FILE
% $21.10.16 Runs WindNinja if does not exist! (NOT IMPLEMENTED)
% $24.12.16 NOVELTY ->interpolates map in EXPANSION and NOT IN HUYGENS

%clear
%% INPUTS smartQFIRE

function [xy_fronts]=runExpansion_7i_WND_INP(Input_file)
tstart = cputime;

ReadQfireInputFile(Input_file)
load('TempWorkSpace');


%% PROGRAMM
%% LOAD ALL WN base maps
[AllSpeedMapStrucGRD,AllDirMapStrucGRD]=LoadAllBaseMaps(WindNinjaOutFolder);


%% EXPAN
[xy_fronts]=expansion_f_s_simple_7i_WND(I(1),I(2),I(3),I(4),I(5),I(6),I(7),xiyi,aspect,slope,AllSpeedMapStrucGRD,AllDirMapStrucGRD,realAdTime, dt, res);

%% Info string
nItem=length(I);
str='%.3f ';
strAll=repmat(str,[1,nItem]);
% Initial info
info_str_n{1}=sprintf(...
    [
    'INFO: %s \nDA ADfronts(step): %d(%d) [sec] //\n'...
    'Igues:[',strAll(1:end-1),'] // \n'...
    'T_{ini}= %d, T_{step}=%d, T_{ad}=%d//'
    ],plotName,numTobs,mean(diff(realAdTime)), I(1,:),tObsIni,IsocStep,numTobs);

% info_str_n{2}=sprintf(...
%     [
%     'INFO: %s \nDA ADfronts(step): %d(%d) [sec] - ConvIter: '...
%     '%d // \n Igues:[',strAll(1:end-1),'] // \n I_{DA}:[',strAll(1:end-1),'] //'...
%     '\n T_{ini}= %d, T_{step}=%d, T_{ad}=%d, - W=%s //'
%     ], plotName, numTobs,mean(diff(realAdTime)),size(Invariants,1), I(1,:), Invariants(end,:),tObsIni,IsocStep,numTobs,weight);

%% Last Wind map
    [mag_i, dir_i,NewSpeedMap,NewDirMap]=SpeedDirMapInterpolValue(AllSpeedMapStrucGRD,AllDirMapStrucGRD,I(5),I(6),xy_fronts.xy{end}(:,1),xy_fronts.xy{end}(:,2));
    %GRDmap2googlerth(sprintf('%sv%dms',plotName,I(5)), NewSpeedMap,31,'N',70, 50)

%% Plot Grpahs
if plotting==1
    try
        figure('Name', 'FrontsANDHillshade');
        PlotFrontGRD(xy_fronts.xy, hillshade, 'hillshade [º]', '-w','zoom')
    catch ME %if hillshade does not exist!
        figure('Name', 'SLOPE and ASPECT maps');
        sH1=subplot(1,2,1);
        slopeGrad=slope;
        slopeGrad.data=slope.data/pi*180;
        %PlotFrontGRD(xy_fronts.xy, slopeGrad, 'slope [º]', '-w')
        PlotFrontGRD(xy_fronts.xy, slopeGrad, 'slope [º]', '-w',sH1)
        %figure;
        sH2=subplot(1,2,2);
        aspectGrad=slope;
        aspectGrad.data=aspect.data/pi*180;
        %PlotFrontGRD(xy_fronts.xy, aspectGrad, 'aspect [º azimuth]', '-w')
        PlotFrontGRD(xy_fronts.xy, aspectGrad, 'aspect [º azimuth]', '-w',sH2)
    end
 %% SUBPLOT FIGURES
    figure('Name', 'Wind DIR and MAG maps'); 
    sH1=subplot(1,2,1);
        PlotFrontGRD(xy_fronts.xy, NewSpeedMap, 'Wind Speed [m/s]','-w','zoom',sH1)
        title('Wind Speed')
    sH2=subplot(1,2,2);
        PlotFrontGRD(xy_fronts.xy, NewDirMap, 'Wind Dir [rad]', '-w','zoom',sH2)
        title('Wind Direction')
end
end
