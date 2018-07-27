function [MagMapGRD]=getUCaseGRDStruct(data_folder)
%gets and pass only one U GRD struct.
o_path=pwd;
[map_name,U,rdeg,v_types,WNoutResolutionStr]=ParseFolderInFolder(data_folder);
wind_speed=U(1);
wind_dir=rdeg(1);
veg_type=v_types{1};
cd(data_folder)
SubFolderName=sprintf('s-%04d_d-%04d_v-%s',wind_speed*100,wind_dir*100,veg_type);
cd(SubFolderName)
filenameVel=sprintf('%s_%d_%d_%s_vel.asc',map_name,wind_dir,wind_speed,WNoutResolutionStr);
%filenameAng=sprintf('%s_%d_%d_%s_ang.asc',map_name,wind_dir,wind_speed,WNoutResolutionStr);
MagMapGRD=LoadWNasc2GRD(filenameVel);%m/S
%DirMapGRD=LoadWNasc2GRD(filenameAng);%DEG
cd(o_path)

%(STANDALONE functions)
% %% Nested Functions 
%     function [map_name,U,deg,v_types,WNoutResolutionStr]=ParseFolderInFolder(folder_path)
%         current_folder=pwd;
%         cd(folder_path)
%         files = dir();
%         % Get a logical vector that tells which is a directory.
%         dirFlags = [files.isdir];
%         subFolders = files(dirFlags);
%         N_real_folders=length(subFolders)-2;
%         U=nan(1,N_real_folders);
%         deg=nan(1,N_real_folders);
%         
%         cd(subFolders(3).name)
%         [map_name,~,~,WNoutResolutionStr]=ParseFilesInFolder;
%         cd(current_folder)
%         v_types=cell(1,N_real_folders);
%         for kk=1:N_real_folders;
%             split=strsplit(subFolders(kk+2).name,'_');
%             U(kk)=str2double(split{1}(3:end))/100; %1/100 m/s
%             deg(kk)=str2double(split{2}(3:end))/100;
%             v_types{kk}=split{3}(3:end);
%         end
%     end
%     function [map_name,U,deg,dxdy]=ParseFilesInFolder
%         % now can handle '_' in the name!
%         % DO NOT USE _ in the MAP NAME!!!!
%         list=ls('*vel.asc'); %take only one of ang.asc or vel.asc
%         list=cellstr(list);
%         split=strsplit(list{1},'_');
%         dxdy=split{end-1};
%         U=nan(1,length(list));
%         deg=nan(1,length(list));
%         for kk=1:length(list)
%             split=strsplit(list{kk},'_');
%             deg(kk)=str2double(split{end-3});
%             U(kk)=str2double(split{end-2});
%         end
%         if length(split)==5
%             map_name=split{1};
%         else
%             map_name=[sprintf('%s_',split{1:end-5}),split{end-4}];
%         end
%     end

end