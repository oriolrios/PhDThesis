function str = Double2String(n)
    str = '';
    while n > 0
        d = mod(n,10);
        str = [char(48+d), str];
        n = (n-d)/10;
    end
    if isempty(str)
        str='0' ;
    end
end