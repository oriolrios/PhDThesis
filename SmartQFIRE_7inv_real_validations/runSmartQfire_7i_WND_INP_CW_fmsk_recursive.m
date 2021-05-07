% Same as SmartQFIRE but prepared to use a no WN configuration (constnat
% one). Actually a fake one. DOES all process anyway. Charges a fake
% windnija path.
% No NEED to pass in windninja path!
% Uses Matlab optimization FMINUNC i FMINCON algorithms to run the
% assimilation
%
% History:
% $30.06.16 Use Mf, Mx, SAV, L, U, theta,D, fuel_depth as invariants!
% $22.07.16 Add WindNinja
% $21.10.16 IS FUNCTION and wants INPUT FILE
% $21.10.16 Runs WindNinja if does not exist! (NOT IMPLEMENTED)
% $27.12.16 Updated to *WND* versions that perform interpolations in due time!
%
%
%% INPUTS smartQFIRE

function [TotalTimeMIN]=runSmartQfire_7i_WND_INP_CW_fmsk_recursive(Input_file)

tstart = clock;

ReadQfireInputFile(Input_file)
load('TempWorkSpace');
%create folder to save all outputs!
New_FigSavePath=strcat(FigSavePath,'\',SaveNameMat);
mkdir(New_FigSavePath)
FigSavePath=New_FigSavePath;

%save all command window display to a log file
diary(strcat(FigSavePath,'\','log.out'))


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
%% RECURSIVE LOOP STARTS. (forecastTime=1 in setting)
Sorensen_Recursive   = zeros(1,length(isochrons.time));
Jaccard_AD_Recursive = zeros(1,length(isochrons.time));
SDI_AD_Recursive     = zeros(1,length(isochrons.time));
    
%for numTobs=numTobs:numTobs;
for numTobs=2:length(isochrons.time)% BO
%for numTobs=3:length(isochrons.time)% only for EX1
    if numTobs==6
        stop
    end
    AllIsocAbsTime=round(isochrons.time-isochrons.time(1))'; % rounded to [SEC]
    indAdTime=tObsIni:IsocStep:tObsIni+numTobs*IsocStep-1;   % asimilation times
    
    
    if indAdTime(end)>size(AllIsocAbsTime,1)
        error('not enought observed isocrhones %d (%d available)',indAdTime(end),size(AllIsocAbsTime,1))
        
    elseif indAdTime(end)==size(AllIsocAbsTime,1)
        disp('No Isochrones left for forecast validation')
    end
    
    absAdTime=AllIsocAbsTime(indAdTime);
    realAdTime= (absAdTime-absAdTime(1))'; %-> cal que sigui vector [1,n]%
    xy_real=isochrons.xy(indAdTime);
    xy_real{1}=check_sense_xiyi(xy_real{1}); % COUNTER CLOCK WISE!
    
    %% forecast time! SOLUCIONAR AIXO!
    avblFwTimeIso = numel(isochrons.time)-indAdTime(end);
    
    if avblFwTimeIso>0% si queden fronts
        if isa(forecastTime,'char') && strcmp(forecastTime,'All') %agafem tots els temps possibles
            indRelFwTime=indAdTime(end):IsocStep:numel(isochrons.time);% we also use stpe for forecast
            RelFwTime=isochrons.time(indRelFwTime)-isochrons.time(indAdTime(end)); %agafem tot
            IsoLeft4Vali=1;
            xy_real_Forecast=isochrons.xy(indRelFwTime);
            
        elseif isa(forecastTime,'double')
            RelFwTime=forecastTime;
            IsoLeft4Vali=0;
        end
        
    elseif avblFwTimeIso<0 && isa(forecastTime,'double')
        RelFwTime=forecastTime;
        IsoLeft4Vali=0;
    elseif avblFwTimeIso<0
        
        error('Forecasting %d fronts and only %d fronts of obserbations available!!!',isochrone_step*max_forecast_fronts, length(all_isochrones_abs_time)-ind_AD_time(end))
    end
    
    
    
    
    
    %% LOAD ALL WN base maps
    %Normal RUN:
    
    %% [AllSpeedMapStrucGRD,AllDirMapStrucGRD]=LoadAllBaseMaps(WindNinjaOutFolder);
    % INSTEAD
    
    load('y:\A_DOCS ORIOL\thesis_PhD_Y\INVERSE MODELLING\QFIRE_tests\SmartQFIRE_7inv_real_validations\src\gestosa\Constant_WN_STUCT_maps.mat')
    %FAKE one
    %%load('.\src\gestosa\Constant_WN_STUCT_maps_false_asINITIAL.mat')
    
    
    % MEX RUN:
    % [AllSpeedMapStrucGRD,AllDirMapStrucGRD]=LoadAllBaseMapsC(WindNinjaOutFolder); %-> read minimal (7) FIELDS!
    
    %% OPTIMIZATION
    % Unconstraiuned optimization
    %[x, fval, Invariants, CostVal] = optSmartQFIRE(xy_real,fuelA,aspectA,slopeA,weight,realAdTime,I);
    
    % Constrained Optimization
    %[x, fval, Invariants, CostVal] = ConstOptSmartQFIRE_all(xy_real,aspect,slope,weight,realAdTime,I,OptIndexCh,fId);
    [x, fval, Invariants, CostVal] = ConstOptSmartQFIRE_7i_WND_fmsk(xy_real,aspect,slope,fmask,AllSpeedMapStrucGRD,AllDirMapStrucGRD,weight,realAdTime,I,OptIndexCh,dt,res,fId,ParallelPool);
    TotalTime=clock-tstart;
    TotalTimeMIN=TotalTime(4)*60+TotalTime(5)+TotalTime(6)/60;
    OptTimeStr=sprintf('+++++++++++ FINISH +++++++++++++ \n Optimization took: %.2f min\n+++++++++++ FINISH +++++++++++++\n',TotalTimeMIN);
    
    if SaveOut==1
        fclose(fId);
    end
    %% Recomput initial fronts (WND version!)
    % [xy_model_ini_guess]=expansion_f_s_simple_7i_WN(I(1),I(2),I(3),I(4),I(5),I(6),I(7),xy_real{1},aspect,slope,AllSpeedMapStrucGRD,AllDirMapStrucGRD,realAdTime,dt,res);
    % [xy_model]=expansion_f_s_simple_7i_WN(x(1),x(2),x(3),x(4),x(5),x(6),x(7),xy_real{1},aspect,slope,AllSpeedMapStrucGRD,AllDirMapStrucGRD,realAdTime,dt,res);
    [xy_model_ini_guess]=expansion_f_s_simple_7i_WND_fmsk(I(1),I(2),I(3),I(4),I(5),I(6),I(7),xy_real{1},aspect,slope,fmask,AllSpeedMapStrucGRD,AllDirMapStrucGRD,realAdTime,dt,res);
    [xy_model]=expansion_f_s_simple_7i_WND_fmsk(x(1),x(2),x(3),x(4),x(5),x(6),x(7),xy_real{1},aspect,slope,fmask,AllSpeedMapStrucGRD,AllDirMapStrucGRD,realAdTime,dt,res);
    
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
    %figure; % needed to prevent malfunctioning
    [f1,f2]=PlotAssimilationFigures(Invariants,CostVal,xy_real,xy_model,xy_model_ini_guess,inv_char,info_str_n);
    if SaveOut==1
        [f3]=PlotIndexConvergence(filename);
        MyExportFigPngStyle(f3,strcat(SaveNameMat,f3.Name), 'w30h25', FigSavePath)
    end
    %% Isochrone comparation
    %[costFunc, SDI_AD, Sorensen_AD, Jaccard_AD,SDI_a,Sorensen_a,Jaccard_a,f4a,f4b]=real_model_AREA_cost(xy_real,xy_model.xy(:,end),'plot', sprintf('Assimilated_Fronts_Optimizing%sIndex',OptIndexCh));
    [~, SDI_AD, Sorensen_AD, Jaccard_AD,~,~,~,BianchiIndx,f4a,f4b]=real_model_AREA_cost_asBianchi(xy_real,xy_model.xy(:,end),'plot', sprintf('Assimilated_Fronts_Optimizing%sIndex',OptIndexCh));
    
    Sorensen_Recursive(numTobs)=Sorensen_AD(numTobs);
    Jaccard_AD_Recursive(numTobs)=Jaccard_AD(numTobs);
    SDI_AD_Recursive(numTobs)=SDI_AD(numTobs);
    BianchiIndx_Recursive(numTobs)=BianchiIndx(numTobs);
    
    %ONLY FOR GESTOSA!
    %    InvertRLsubplots(f4a); %CORRECT DE FACT THAT GESTOSA IS INVERTED LR
    % ex5
    InvertUDsubplots(f4a);  % FOT EX 5
    %% Plot fronts and GRD
    
    %% GOOGLE EARTH
    if plot_GoogleEarth ==1
        % IMPORTANT! 31,'N' is the UTM zone and hemisphere
        fronts2googlearth(sprintf('fronts_assimilated_%s_%s',OptIndexCh,weight), xy_model,31,'N','b')
        fronts2googlearth(sprintf('fronts_observed%s_%s',OptIndexCh,weight), xy_real,31,'N','r')
        fronts2googlearth(sprintf('fronts_1st_Guess%s_%s',OptIndexCh,weight), xy_model_ini_guess,31,'N','g')
        
        %% Last Wind map PLOT IN GEARTH
        %    [mag_i, dir_i,NewSpeedMap,NewDirMap]=SpeedDirMapInterpolValue(AllSpeedMapStrucGRD,AllDirMapStrucGRD,I(5),I(6),xy_real{1}(:,1),xy_real{1}(:,2));
        %GRDmap2googlerth(sprintf('%sv%dms',plotName,I(5)), NewSpeedMap,31,'N',70, 50)
    end
    
    %% PLTING HILLSHADE FRONTS AND WIND MAPS PLOTS
    % if plotting==1
    %     try
    %         f5=figure('Name', 'FrontsANDHillshade');
    %         h5=axes(f5);
    %         %PlotFrontGRD(xy_fronts.xy, hillshade, 'hillshade [º]', '-w','zoom')
    %         HillPlot=Plot3FrontGRD(xy_model.xy,xy_real,xy_model_ini_guess.xy, hillshade,'hillshade','--r','-k','--g','zoom',h5);
    %         colormap gray
    %         MyExportFigPngStyle(f5,strcat(SaveNameMat,f5.Name), 'w30h25', FigSavePath)
    %     catch ME %if hillshade does not exist!
    %         f5=figure('Name', 'SLOPE and ASPECT maps');
    %         sH1=subplot(1,2,1);
    %         slopeGrad=slope;
    %         slopeGrad.data=slope.data/pi*180;
    %         %PlotFrontGRD(xy_fronts.xy, slopeGrad, 'slope [º]', '-w')
    %         PlotFrontGRD(xy_fronts.xy, slopeGrad, 'slope [º]', '-w',sH1)
    %         %figure;
    %         sH2=subplot(1,2,2);
    %         aspectGrad=slope;
    %         aspectGrad.data=aspect.data/pi*180;
    %         %PlotFrontGRD(xy_fronts.xy, aspectGrad, 'aspect [º azimuth]', '-w')
    %         PlotFrontGRD(xy_fronts.xy, aspectGrad, 'aspect [º azimuth]', '-w',sH2)
    %         MyExportFigPngStyle(f5,strcat(SaveNameMat,f5.Name), 'w30h25', FigSavePath)
    %     end
    %  %% SUBPLOT FIGURES
    %     f6=figure('Name', 'Wind DIR and MAG maps');
    %     sH1=subplot(1,2,1);
    %         Plot3FrontGRD(xy_model.xy,xy_real,xy_model_ini_guess.xy, NewSpeedMap,'Wind Speed [m/s]','--r','-k','--g','zoom',sH1,[0,30]);
    %         title('Wind Speed')
    %     sH2=subplot(1,2,2);
    %         %NewDirMap_deg=NewDirMap;
    %         %NewDirMap_deg.data=NewDirMap_deg.data/pi*180;
    %         Plot3FrontGRD(xy_model.xy,xy_real,xy_model_ini_guess.xy, NewDirMap,'Wind Dir [deg]','--r','-k','--g','zoom',sH2);
    %         title('Wind Direction')
    %         colormap(sH2,'gray')
    %    MyExportFigPngStyle(f6,strcat(SaveNameMat,f6.Name), 'w30h25', FigSavePath)
    % end
    
    %save a copy of the input file in the folder!
    if strcmp(Input_file(end-1:end),'.m')
        copyfile(Input_file,FigSavePath)
    else
        copyfile(strcat(Input_file,'.m'),FigSavePath)
    end
    
    
    %% PRINTING FIGURES
    
    MyExportFigPngStyle(f1,strcat(sprintf('%d_',numTobs),f1.Name), 'w30h25', FigSavePath)
    MyExportFigPngStyle(f2,strcat(sprintf('%d_',numTobs),f2.Name), 'w30h12', FigSavePath)% 3 subplots convergence
    F4Name=f4b.Name;
    MyExportFigPngStyle(f4a,strcat(sprintf('%d_',numTobs),'AreesPlot'), 'w30h25', FigSavePath)
    MyExportFigPngStyle(f4b,strcat(sprintf('%d_',numTobs),F4Name(13:end)), 'w30h25', FigSavePath)
    
    %MyExportFigPngStyle(f5,strcat(SaveNameMat,f6.Name), 'MyDefault', FigSavePath)
    close all
end % ENDS RECURSIVE LOOP

%% RECURSIVE INDEX
FRec=figure; plot(Sorensen_Recursive);hold on; plot(Jaccard_AD_Recursive); plot(SDI_AD_Recursive); plot(BianchiIndx_Recursive)
ha=gca; ha.XTick=1:1:6;
MyExportFigPngStyle(FRec,'Recursive_index', 'default', FigSavePath)
%% others
disp(OptTimeStr);

%% EXPANSION (RunExpansion=0)
if RunExpansion==1
    NewI=Invariants(end,:);
    [xy_model_expan]=expansion_f_s_simple_7i_WND_fmsk(NewI(1),NewI(2),NewI(3),NewI(4),NewI(5),NewI(6),NewI(7),xy_real{end},aspect,slope,fmask,AllSpeedMapStrucGRD,AllDirMapStrucGRD,RelFwTime,dt,res);
    
    if IsoLeft4Vali==1 %forecast validation
        [~, ~, ~, ~,~,~,~,fF1,fF2]=real_model_AREA_cost(xy_real_Forecast,xy_model_expan.xy(:,end),'plot', sprintf('Forecasted_Fronts_Optimizing%sIndex',OptIndexCh));
        MyExportFigPngStyle(fF1,strcat(SaveNameMat,'Forecast_Area'), 'w30h25', FigSavePath)
        MyExportFigPngStyle(fF2,strcat(SaveNameMat,'Forecast_Indx'), 'w30h25', FigSavePath)
    else
        fF1=figure('Name','Forecast_Fronts_no_validation');
        plot_fronts_cell(xy_real.xy,'hold','-*r')
    end
    
end

%% SAVING WORKSPACE
%save(SaveNameMat)
%save(SaveNameMat,'-regexp','^(?!(f1|f2|f3)$). ')
%save(SaveNameMat, '-regexp', '^(?!f.*$).') % save all except f* handles!!
%save(strcat(FigSavePath,SaveNameMat), '-regexp', '^(?!f.*$).') % save all except f* handles!!
save(strcat(FigSavePath,'\',SaveNameMat), '-regexp', '^(?!(f.*|AllDirMapStrucGRD|AllSpeedMapStrucGRD)$).') % save all except f* handles and WINDMAPS!!! (redundant)
diary OFF
