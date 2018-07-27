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