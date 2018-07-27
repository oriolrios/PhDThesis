% SmartQFIRE
% Uses Matlab optimization FMINUNC i FMINCON algorithms to run the
% assimilation
%
% History
% $30.06.16 Use Mf, Mx, SAV, L, U, theta,D, fuel_depth as invariants!
% $22.07.16 Add WindNinja
% $21.10.16 IS FUNCTION and wants INPUT FILE
% $21.10.16 Runs WindNinja if does not exist! (NOT IMPLEMENTED)

%clear
%% INPUTS smartQFIRE

function [TotalTimeMIN]=runSmartQfire_7i_WN_INP(Input_file)
%clear
tstart = clock;

ReadQfireInputFile(Input_file)
load('TempWorkSpace');

%% Initial Checks
if ParallelPool==1 && SaveOut==1
   error('MyErr: If ParallelPool==1 -> SaveOut must be 0 (no parallel wrtting of intermediate convergence index is permitted') 
end

%% PROGRAMM
if SaveOut==1
    filename=sprintf('cost2optData_%s.csv',OptIndexCh);
    %filename='cost2optData.csv';
    fId=fopen(filename,'w');
    fprintf(fId, '%s(OptIndex), %s, %s, %s, %s, %s, %s, %s\n',OptIndexCh,OptIndexStrng{:});
else
    fId=[];
end



%% TIMES
AllIsocAbsTime=round(isochrons.time-isochrons.time(1))'; % rounded to [SEC]
indAdTime=tObsIni:IsocStep:tObsIni+numTobs*IsocStep-1;   % asimilation times
if indAdTime(end)>size(AllIsocAbsTime,1)
    error('not enought observed isocrhones %d (%d available)',indAdTime(end),size(AllIsocAbsTime,1))
end
absAdTime=AllIsocAbsTime(indAdTime);
realAdTime= (absAdTime-absAdTime(1))'; %-> cal que sigui vector [1,n]
xy_real=isochrons.xy(indAdTime);
xy_real{1}=check_sense_xiyi(xy_real{1}); % COUNTER CLOCK WISE!


%% LOAD ALL WN base maps
%Normal RUN:
[AllSpeedMapStrucGRD,AllDirMapStrucGRD]=LoadAllBaseMaps(WindNinjaOutFolder);
% MEX RUN:
% [AllSpeedMapStrucGRD,AllDirMapStrucGRD]=LoadAllBaseMapsC(WindNinjaOutFolder); %-> read minimal (7) FIELDS!

%% OPTIMIZATION
% Unconstraiuned optimization
%[x, fval, Invariants, CostVal] = optSmartQFIRE(xy_real,fuelA,aspectA,slopeA,weight,realAdTime,I);

% Constrained Optimization
%[x, fval, Invariants, CostVal] = ConstOptSmartQFIRE_all(xy_real,aspect,slope,weight,realAdTime,I,OptIndexCh,fId);
[x, fval, Invariants, CostVal] = ConstOptSmartQFIRE_7i_WN(xy_real,aspect,slope,AllSpeedMapStrucGRD,AllDirMapStrucGRD,weight,realAdTime,I,OptIndexCh,dt,res,fId,ParallelPool);
TotalTime=clock-tstart;
TotalTimeMIN=TotalTime(4)*60+TotalTime(5)+TotalTime(6)/60;
OptTimeStr=sprintf('Optimization took: %.2f min\n',TotalTimeMIN);
disp(OptTimeStr);
if SaveOut==1
    fclose(fId);
end
%% Recomput initial fronts
[xy_model_ini_guess]=expansion_f_s_simple_7i_WN(I(1),I(2),I(3),I(4),I(5),I(6),I(7),xy_real{1},aspect,slope,AllSpeedMapStrucGRD,AllDirMapStrucGRD,realAdTime,dt,res);
[xy_model]=expansion_f_s_simple_7i_WN(x(1),x(2),x(3),x(4),x(5),x(6),x(7),xy_real{1},aspect,slope,AllSpeedMapStrucGRD,AllDirMapStrucGRD,realAdTime,dt,res);

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

info_str_n{2}=sprintf(...
    [
    'INFO: %s \nDA ADfronts(step): %d(%d) [sec] - ConvIter: '...
    '%d // \n Igues:[',strAll(1:end-1),'] // \n I_{DA}:[',strAll(1:end-1),'] //'...
    '\n T_{ini}= %d, T_{step}=%d, T_{ad}=%d, - W=%s //'
    ], plotName, numTobs,mean(diff(realAdTime)),size(Invariants,1), I(1,:), Invariants(end,:),tObsIni,IsocStep,numTobs,weight);


%% Plot Grpahs
[f1,f2]=PlotAssimilationFigures(Invariants,CostVal,xy_real,xy_model,xy_model_ini_guess,inv_char,info_str_n);
if SaveOut==1
    [f3]=PlotIndexConvergence(filename);
    MyExportFigPngStyle(f3,strcat(SaveNameMat,f3.Name), 'MyDefault', FigSavePath)
end
%% Isochrone comparation 
[costFunc, SDI_AD, Sorensen_AD, Jaccard_AD,SDI_a,Sorensen_a,Jaccard_a,f4]=real_model_AREA_cost(xy_real,xy_model.xy(:,end),'plot', sprintf('Assimilated_Fronts_Optimizing%sIndex',OptIndexCh));


%% Plot fronts and GRD
% AllDirMapStrucGRD.data=AllDirMapStrucGRD.dataStrc{7,1};
% plotFrontAndGRDmap(AllDirMapStrucGRD,xy_model.xy)

if plot_GoogleEarth ==1    
    % IMPORTANT! 31,'N' is the UTM zone and hemisphere
    fronts2googlearth(sprintf('fronts_assimilated_%s_%s',OptIndexCh,weight), xy_model,31,'N','b')
    fronts2googlearth(sprintf('fronts_observed%s_%s',OptIndexCh,weight), xy_real,31,'N','r')
    fronts2googlearth(sprintf('fronts_1st_Guess%s_%s',OptIndexCh,weight), xy_model_ini_guess,31,'N','g')
        
    %% Last Wind map
    [mag_i, dir_i,NewSpeedMap,NewDirMap]=SpeedDirMapInterpolValue(AllSpeedMapStrucGRD,AllDirMapStrucGRD,I(5),I(6),xy_real{1}(:,1),xy_real{1}(:,2));
    GRDmap2googlerth(sprintf('%sv%dms',plotName,I(5)), NewSpeedMap,31,'N',70, 50)
end


%% saving 
%save(SaveNameMat)
%save(SaveNameMat,'-regexp','^(?!(f1|f2|f3)$). ')
save(SaveNameMat, '-regexp', '^(?!f.*$).') % save all except f* handles!!

MyExportFigPngStyle(f1,strcat(SaveNameMat,f1.Name), 'MyDefault', FigSavePath)
MyExportFigPngStyle(f2,strcat(SaveNameMat,f2.Name), 'MyDefault', FigSavePath)
F4Name=f4.Name;
MyExportFigPngStyle(f4,strcat(SaveNameMat,F4Name(13:end)), 'MyDefault', FigSavePath)
