function [AllSpeedMapStrucGRD,AllDirMapStrucGRD]=LoadAllBaseMapsLight(DirMapFolder)
% This LIGHT VERSION loads same fields in struct as LoadAllBaseMapsC version!
%Loads all available WindNinja run maps and outputs a struc:
% STRUCTURE StrucGRD:
% 	.DATA = Matriz de puntos
% 	.xdist = Vector de distancia en X
% 	.ydist = Vector de distancia en Y
%   .lim = Grid Limits
%   .dx = resolution horizontal (X)
%   .dy = resolution vertical (Y) 
% Interpoles dir&speed and gives coordinates value! 
% DirMapFolder = folder with Python wrapper folders
% Dir2Inter = Direction to interpolate.
% GRD0  = is the GRD info of all MAPS... if passed by speed computation!
%
% History
% $22.07.16 if more than one U run in folder, use closer one
% $22.07.16 outputs a col vector of dir_i and mag_i PENDENT

%% PROGRAMM

% Read available directions
tic;
[map_name,U,rdeg,v_types,WNoutResolutionStr]=ParseFolderInFolder(DirMapFolder);


[MagMapGRD]=getUCaseGRDStruct(DirMapFolder);

MyStruct=MagMapGRD;
MyStruct=rmfield(MyStruct,'data'); %es per no arrosegar la metriu DATA
MyStruct.MapName=map_name;
MyStruct.DirInfo='Direction toward wind blows. From north';
AllU=unique(U);
MyStruct.AllU=AllU;
Deg=unique(rdeg,'sorted'); % Unique SORT and ->RAD
MyStruct.Deg=Deg;
VegType=unique(v_types);
MyStruct.VegType=VegType{1}; % -> CHAR!!

AllSpeedMapStrucGRD=MyStruct;
AllDirMapStrucGRD=MyStruct;

%just to allocate
%[DumbMapU,~]=getCase(AllU(1),Deg(1),MyStruct.VegType{1},DirMapFolder);
AllSpeedMapStrucGRD.dataStrc=cell(length(Deg),length(AllU));
AllDirMapStrucGRD.dataStrc=cell(length(Deg),length(AllU));

for i=1:length(Deg)
    for j=1:length(AllU)
       [AllSpeedMapStrucGRD.dataStrc{i,j},AllDirMapStrucGRD.dataStrc{i,j}]=getCase(AllU(j),Deg(i),VegType{1},DirMapFolder);
% 		[AllSpeedMapStrucGRD.dataStrc(:,:,i,j),AllDirMapStrucGRD.dataStrc(:,:,i,j)]=getCaseC(AllU(j),Deg(i),VegType{1},DirMapFolder,WNoutResolutionStr,map_name,o_path);
    end
end

time=toc;
w=whos;
Vsize=(w(1).bytes+w(2).bytes)/2^20; %byte2megabyte
fprintf('All maps loaded. Time=%.3f s, Memory=%.2f MB\n',time,Vsize)

%% NESTED FUNCTIONS

    function [map_name,U,deg,v_types,WNoutResolutionStr]=ParseFolderInFolder(folder_path)
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

    function [MagMap,DirMap]=getCase(wind_speed,wind_dir,veg_type,data_folder)
        o_path=pwd;
        cd(data_folder)
        SubFolderName=sprintf('s-%04d_d-%04d_v-%s',wind_speed*100,wind_dir*100,veg_type);
        cd(SubFolderName)
        filenameVel=sprintf('%s_%d_%d_%s_vel.asc',map_name,wind_dir,wind_speed,WNoutResolutionStr);
        filenameAng=sprintf('%s_%d_%d_%s_ang.asc',map_name,wind_dir,wind_speed,WNoutResolutionStr);
        
        if isempty(filenameVel)
            stop
        end
        MagMap=dlmread(filenameVel,'\t',6,0);%m/S
        MagMap=flipud(MagMap(:,1:end-1)); %correction due to file format!
        
        DirMap=dlmread(filenameAng,'\t',6,0);%DEG
        DirMap=flipud(DirMap(:,1:end-1)); %correction due to file format!
         
        cd(o_path)
    end

    function [MagMapGRD]=getUCaseGRDStruct(data_folder)
        %gets and pass only one U GRD struct.
        o_path=pwd;
        [map_name,Uu,Ddeg,vv_types,WNoutResolutionStr]=ParseFolderInFolder(data_folder);
        wind_speed=Uu(1);
        wind_dir=Ddeg(1);
        veg_type=vv_types{1};
        cd(data_folder)
        SubFolderName=sprintf('s-%04d_d-%04d_v-%s',wind_speed*100,wind_dir*100,veg_type);
        cd(SubFolderName)
        filenameVel=sprintf('%s_%d_%d_%s_vel.asc',map_name,wind_dir,wind_speed,WNoutResolutionStr);
        %filenameAng=sprintf('%s_%d_%d_%s_ang.asc',map_name,wind_dir,wind_speed,WNoutResolutionStr);
%        MagMapGRD=LoadWNasc2GRD(filenameVel);%m/S
        MagMapGRD=LoadWNasc2GRDLight(filenameVel);%m/S -> 5 fields
        %DirMapGRD=LoadWNasc2GRD(filenameAng);%DEG
        cd(o_path)
    end
end