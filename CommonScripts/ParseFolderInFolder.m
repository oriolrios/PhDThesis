function [map_name,U,deg,v_types,WNoutResolutionStr]=ParseFolderInFolder(folder_path)
    current_folder=pwd;
    cd(folder_path)
    %files = dir(folder_path);
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