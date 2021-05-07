% Explores time step dependency of input files
%
% History
% $30.06.16 Use Mf, Mx, SAV, L, U, theta,D, fuel_depth as invariants!
% $22.07.16 Add WindNinja
% $21.10.16 IS FUNCTION and wants INPUT FILE
% $21.10.16 Runs WindNinja if does not exist! (NOT IMPLEMENTED)

%clear
%% INPUTS smartQFIRE

function TimeStepExplore(Input_file)


ReadQfireInputFile(Input_file)
load('TempWorkSpace'); % Això ho genera quan corres un QFIRE

%% PROGRAMM
%% LOAD ALL WN base maps
[AllSpeedMapStrucGRD,AllDirMapStrucGRD]=LoadAllBaseMaps(WindNinjaOutFolder);

dt=5:10:100;
%lineStyle={'-m','-c','-r','-g','-b','-k','-m','-c','-r','-g','-b','-k','-m','-c','-r','-g','-b','-k'};
%lineStyle=lines(length(dt));
% lineStyle=[0 0 0;colorcube(length(dt))];
lineStyle=[0 0 0;parula(length(dt))];

%% EXPAN
figure; 
hold on
for i=1:length(dt)
    tstart = cputime;
    [xy_fronts]=expansion_f_s_simple_7i_WN(I(1),I(2),I(3),I(4),I(5),I(6),I(7),xiyi,aspect,slope,AllSpeedMapStrucGRD,AllDirMapStrucGRD,realAdTime, dt(i), res);
    time(i)=cputime-tstart
    %h(i)=plot_fronts_cell(xy_fronts.xy,'hold',lineStyle{i});
    h(i)=plot_fronts_cell(xy_fronts.xy,'hold',lineStyle(i,:));
end
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

%% LEGEND
legend(h,sprintfc('%2d s\n',dt))
%% PLOT TIME
figure('Name', 'Time efficiency')
plot(dt, time)
title(sprintf('Performance simulating %d s',realAdTime(end)));
xlabel('Integrating time stpe [s]')
ylabel('Elapsed time [s]')
%% Last Wind map

    [mag_i, dir_i,NewSpeedMap,NewDirMap]=SpeedDirMapInterpolValue(AllSpeedMapStrucGRD,AllDirMapStrucGRD,I(5),I(6),xy_fronts.xy{end}(:,1),xy_fronts.xy{end}(:,2));
    %GRDmap2googlerth(sprintf('%sv%dms',plotName,I(5)), NewSpeedMap,31,'N',70, 50)

%% Plot Grpahs
figure; 
%sH1=subplot(1,2,1);
    PlotFrontGRD(xy_fronts.xy, slope, 'slope', '-w')
figure;
%sH2=subplot(1,2,2);
    PlotFrontGRD(xy_fronts.xy, aspect, 'aspect', '-w')
figure('Name', 'Wind DIR and MAG maps'); 
sH1=subplot(1,2,1);
    PlotFrontGRD(xy_fronts.xy, NewSpeedMap, 'Wind Speed [m/s]','-w','zoom',sH1)
    title('Wind Speed')
sH2=subplot(1,2,2);
    PlotFrontGRD(xy_fronts.xy, NewDirMap, 'Wind Dir [rad]', '-w','zoom',sH2)
    title('Wind Direction')

end
