% Script to analyze WindNinja dependencies on WindSpeed!
% Process data from PythonBatch.py wrapper for WindNinja
%
function WindNinjaAnalysis
original_path=pwd;
%*******************%
read_data = 1;          % 1= read 2=no read
plot_flag=1;        % 1= MULTI PLOT, 0= NO MULTI PLOT
i_Box_Plot = 0;         % Index of U_base to plot boxplot!
%plot_type = 'map'; % 'hist'=HISTOGRAM, 'map'=map contours
%*******************%
%
%% MANUAL Initial Statements. Folders
%-- make MAX one -------
% wind_speeds = 1:2:15;
% wind_speed2cmp = 1:2:15; % DO NOT SELECT ALL! (too much combinations!)
% wind_speed_cte=2;
% 
% wind_directions = 0:45:315; % 0:15:345
% wind_dir2cmp = 0:45:315; % DO NOT SELECT ALL! (too much combinations!)
% wind_dir_cte=45;
% vegetation_types ={'grass'};%,'brush','trees'}; %'brush', 'trees'
% %-- constant ----------
% % WNoutResolution=5; 
% % map_name='MO_05m';
% WNoutResolutionStr=30; 
% %map_name='Missoula_30m';
% %map_name='canada30m';
% % map_name='maipo90m';
% % map_name='valpo90m';
% %map_name='santiago90m'; JA NO CAL!
%% *******************%
% data_folder='d:\01_CERTEC\thesis_PhD_Y\WindNinja\MO_15\';
data_folder='Y:\A_DOCS ORIOL\thesis_PhD_Y\INVERSE MODELLING\WindNinja_CALCS\MO_05';
% data_folder='d:\01_CERTEC\thesis_PhD_Y\WindNinja\Missoula30\';
% data_folder='d:\01_CERTEC\thesis_PhD_Y\WindNinja\SensitivityAnalysis\canada30m\';
% data_folder='d:\01_CERTEC\thesis_PhD_Y\WindNinja\SensitivityAnalysis\maipo90m\';
% data_folder='d:\01_CERTEC\thesis_PhD_Y\WindNinja\SensitivityAnalysis\valpo90m\';
% data_folder='d:\01_CERTEC\thesis_PhD_Y\WindNinja\SensitivityAnalysis\santiago90m\';
% data_folder='d:\01_CERTEC\thesis_PhD_Y\WindNinja\SensitivityAnalysis\alaska30m\';

[map_name,U,deg,v_types,WNoutResolutionStr]=ParseFolderInFolder(data_folder);
wind_speeds = unique(U);
wind_speed2cmp = wind_speeds; %wind_speeds(1:2:end)
indWu_cte=2;
wind_speed_cte=wind_speeds(indWu_cte);
% 
wind_directions = unique(deg);
wind_dir2cmp = wind_directions; %wind_directions(1:2:end);
indWd_cte=3;
wind_dir_cte=wind_directions(indWd_cte);

vegetation_types=unique(v_types(1)); %unique(v_types(1))

cd(data_folder)

%% get comparation index
i=1;
%speed
for U=wind_speed2cmp
    try
        i_u2c_ind(i)=find(U==wind_speeds); %correcte NO FIX!
        i=i+1;
    catch
        error(sprintf('MyErr: ''wind_speed2cmp'' wind speed incorrect.\n %d NO %s',U,sprintf('%d,',wind_speeds)));
    end
end
%dir
i=1;
for U=wind_dir2cmp
    try
        i_d2c_ind(i)=find(U==wind_directions); %correcte NO FIX!
        i=i+1;
    catch
        error(sprintf('MyErr: ''wind_directions'' wind speed incorrect.\n %d NO %s',U,sprintf('%d,',wind_directions)));
    end
end

%% Reading loop & Save as MATALB
if read_data==1;
    tic
    fprintf('Reading new data...')    
    h = waitbar(0,'Reading new data...');
    n_total=length(wind_speeds)*length(wind_directions)*length(vegetation_types);
    nn=1;
    Mag=cell(length(wind_speeds),length(wind_directions),length(vegetation_types));
    Dir=cell(length(wind_speeds),length(wind_directions),length(vegetation_types));
    for i=1:length(wind_speeds)
        for j=1:length(wind_directions)
            for k=1:length(vegetation_types)
                
                SubFolderName=sprintf('s-%04d_d-%04d_v-%s',wind_speeds(i)*100,wind_directions(j)*100,vegetation_types{k});
                cd(SubFolderName)
                
                filenameVel=sprintf('%s_%d_%d_%s_vel.asc',map_name,wind_directions(j),wind_speeds(i),WNoutResolutionStr);
                filenameAng=sprintf('%s_%d_%d_%s_ang.asc',map_name,wind_directions(j),wind_speeds(i),WNoutResolutionStr);
                
                %Dir{i,j,k}=loadEsriGRD(filenameVel);%m/S
                %Mag{i,j,k}=loadEsriGRD(filenameAng);%DEG
                Mag{i,j,k}=dlmread(filenameVel,'\t',7,0);%m/S
                Dir{i,j,k}=dlmread(filenameAng,'\t',7,0);%DEG
                cd ..
                %fprintf('.')
                waitbar(nn/n_total,h)
                nn=nn+1;
            end
            %fprintf('.')
        end
        %fprintf('.')
    end
    %fprintf('\n Ended Reading!\n')
    toc
else
    load(map_name)
end
close(h)
cd(original_path)

%% HERE MUST BE A LOOP for DIR and a LOOP for MAG!!!
%ShaddedMultiPlotDir(i_d2c_ind,Dir,Mag,wind_directions,wind_speed_cte,'grass','save',data_folder)
if plot_flag==1
    h2 = waitbar(0,'Generating (and saving) plots...');
    nn=1;
    n_total=length(vegetation_types)*2+1;

    for i=1:length(vegetation_types)
        [F_MagD{i},F_DirD{i}]=ShaddedMultiPlotDir2(i_d2c_ind,Dir(indWu_cte,:,i),Mag(indWu_cte,:,i),wind_directions,wind_speed_cte,vegetation_types{i},'save',data_folder);
%         [F_MagS{i},F_DirS{i}]=ShaddedMultiPlotSpeed2(i_u2c_ind,Dir(:,indWd_cte,i),Mag(:,indWd_cte,i),wind_speeds,wind_dir_cte,vegetation_types{i},'save',data_folder);
        nn=nn+2;
        waitbar(nn/n_total,h2)
    end
close(h2)
end

%Regression analysis ans saving Data Tables
for i=1:length(vegetation_types)
%     RegresionAndSaveU(F_MagS(i),sprintf('%s_%s',map_name,vegetation_types{i}))
    RegresionAndSaveD(F_DirD(i),sprintf('%s_%s',map_name,vegetation_types{i}))
end

 
% ShaddedMultiPlotDir(i_d2c_ind,Dir(1,:,1),Mag(1,:,1),wind_directions,wind_speed_cte,'grass','save',data_folder)
% ShaddedMultiPlotDir(i_d2c_ind,Dir(1,:,2),Mag(1,:,2),wind_directions,wind_speed_cte,'brush','save',data_folder)
% ShaddedMultiPlotDir(i_d2c_ind,Dir(1,:,3),Mag(1,:,3),wind_directions,wind_speed_cte,'trees','save',data_folder)


%% Nested Functions

    function RegresionAndSaveU(StrucIn,MatName)
        % regresion MAG
        coef=nan(2,length(StrucIn{1,1}.F));
        for kk=1:length(StrucIn{1,1}.F)
            % compute R^2
            mdl = fitlm(StrucIn{1,1}.Ub,StrucIn{1,1}.mean(:,kk));
            R(kk)=mdl.Rsquared.Ordinary;
            coef(:,kk)=mdl.Coefficients.Estimate;
        end
        tableNames=arrayfun(@(x) sprintf('Ub%g',x),StrucIn{1,1}.U2cmp,'un',0);
        CoefTable=array2table([StrucIn{1,1}.U2cmp;StrucIn{1,1}.D2cmp;coef;R],'VariableNames',tableNames,'RowNames',{'Ub','Db','b','ax','R'});
        save(sprintf('%s_U_median',MatName),'CoefTable')
    end

    function RegresionAndSaveD(StrucIn,MatName)
        % regresion MAG
        coef=nan(2,length(StrucIn{1,1}.F));
        for kk=1:length(StrucIn{1,1}.F)
            % compute R^2
            mdl = fitlm(StrucIn{1,1}.Db,StrucIn{1,1}.mean(:,kk));
            R(kk)=mdl.Rsquared.Ordinary;
            coef(:,kk)=mdl.Coefficients.Estimate;
        end
        tableNames=arrayfun(@(x) sprintf('Ub%g',x),StrucIn{1,1}.D2cmp,'un',0);
        CoefTable=array2table([StrucIn{1,1}.U2cmp;StrucIn{1,1}.D2cmp;coef;R],'VariableNames',tableNames,'RowNames',{'Ub','Db','b','ax','R'});
        save(sprintf('%s_D_median',MatName),'CoefTable')
    end

    function leg_str = parseLegend(arg1,arg2)
        u2str=repmat(arg1,1,length(arg2));
        
        d2str=repmat(arg2,length(arg1),1);
        d2str=d2str(:)';
        leg_str=strsplit(sprintf('s%02d-d%03d ',[u2str; d2str]));
        leg_str(end)=[];
    end

    function [map_name,U,deg,v_types,WNoutResolutionStr]=ParseFolderInFolder(folder_path);
        current_folder=pwd;
        cd(folder_path)
        files = dir();
        % Get a logical vector that tells which is a directory.
        dirFlags = [files.isdir];
        subFolders = files(dirFlags);
        N_real_folders=length(subFolders)-2;
        U=nan(1,N_real_folders);
        deg=nan(1,N_real_folders);
        
        cd(subFolders(3).name)
        [map_name,~,~,WNoutResolutionStr]=ParseFilesInFolder;
        cd(current_folder)
        v_types=cell(1,N_real_folders);
        for kk=1:N_real_folders;
            split=strsplit(subFolders(kk+2).name,'_');
            U(kk)=str2double(split{1}(3:end))/100; %1/100 m/s
            deg(kk)=str2double(split{2}(3:end))/100;
            v_types{kk}=split{3}(3:end);
        end 
    end

    function [map_name,U,deg,dxdy]=ParseFilesInFolder
        % now can handle '_' in the name!
        % DO NOT USE _ in the MAP NAME!!!!
        list=ls('*vel.asc'); %take only one of ang.asc or vel.asc
        list=cellstr(list);
        split=strsplit(list{1},'_');
        dxdy=split{end-1};
        U=nan(1,length(list));
        deg=nan(1,length(list));
        for kk=1:length(list)
            split=strsplit(list{kk},'_');
            deg(kk)=str2double(split{end-3});
            U(kk)=str2double(split{end-2});
        end
        if length(split)==5
            map_name=split{1};
        else
            map_name=[sprintf('%s_',split{1:end-5}),split{end-4}];
        end
    end

end