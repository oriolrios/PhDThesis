function [MagMap,DirMap]=getCaseC(wind_speed,wind_dir,veg_type,data_folder,WNoutResolutionStr,map_name,o_path)
    %o_path=pwd;
%    cd(data_folder)

%char *stringa[30];
%sprintf(stringa, "Number of fingers making up a hand are %f", fingers);

    %SubFolderName=sprintf('s-%04d_d-%04d_v-%s',wind_speed*100,wind_dir*100,veg_type);
    % #Sprintf codegen alternative
    SubFolderName=WNfolderPrintName([wind_speed*100,wind_dir*100],veg_type);
    
%    cd(SubFolderName)
    
    %filenameVel=sprintf('%s_%d_%d_%s_vel.asc',map_name,wind_dir,wind_speed,WNoutResolutionStr);
    %filenameAng=sprintf('%s_%d_%d_%s_ang.asc',map_name,wind_dir,wind_speed,WNoutResolutionStr);
    % #Sprintf codegen alternative
    filenameVel=AscPrintName(map_name,[wind_dir wind_speed],WNoutResolutionStr, 'vel');
    filenameAng=AscPrintName(map_name,[wind_dir wind_speed],WNoutResolutionStr, 'ang');
    

    fullPathVel=[data_folder '\' SubFolderName '\' filenameVel];
    fullPathDir=[data_folder '\' SubFolderName '\' filenameAng];
    
    MagMap=getASCdata(fullPathVel);
    DirMap=getASCdata(fullPathDir);
    
%     MagMap=dlmread(fullPathVel,'\t',6,0);%m/S
%     MagMap=flipud(MagMap(:,1:end-1)); %correction due to file format!
%     DirMap=dlmread(fullPathDir,'\t',6,0);%DEG
%     DirMap=flipud(DirMap(:,1:end-1)); %correction due to file format!

%    cd(o_path)
end