function [MagMap,DirMap]=getCase(wind_speed,wind_dir,veg_type,data_folder,map_name,WNoutResolutionStr)
% Function to het WN maps for a givenb case (and WN default OUTPUT
% file structure
%
%
%
%Runs as a nested function in multiple functions.. but is beter in this way
o_path=pwd;
cd(data_folder)
SubFolderName=sprintf('s-%04d_d-%04d_v-%s',wind_speed*100,wind_dir*100,veg_type);
cd(SubFolderName)
filenameVel=sprintf('%s_%d_%d_%s_vel.asc',map_name,wind_dir,wind_speed,WNoutResolutionStr);
filenameAng=sprintf('%s_%d_%d_%s_ang.asc',map_name,wind_dir,wind_speed,WNoutResolutionStr);
MagMap=dlmread(filenameVel,'\t',7,0);%m/S
DirMap=dlmread(filenameAng,'\t',7,0);%DEG
cd(o_path)
end