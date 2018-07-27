function strOut = AscPrintName(mapName,values,resolution, field)
% values =[dir wind](x 100)

%
% EXAMPLE:
% name=AscPrintName('smpa30',[225 5], '30m', 'vel')
%
    str_cell=cell(1,length(values));
    for i=1:length(values)
        n = values(i);
        l = fix(n);
        r = n-l;
        str_cell{i} = Double2String(l);
        %str_cell{i} = strjoin({Double2String(l),Reminder2String(r)},'.');
    end
    str = strjoin(str_cell,'_');
    strOut=[mapName '_' str '_' resolution '_' field '.asc'];
end



