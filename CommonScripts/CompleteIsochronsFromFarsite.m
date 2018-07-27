function [isochrons_OK]=CompleteIsochronsFromFarsite(isochronsFromFarsite)

isochrons_OK=isochronsFromFarsite;
isochrons_OK.timesec=[cell2mat(isochronsFromFarsite.timesec)]'*60;
isochrons_OK.time=isochrons_OK.timesec-isochrons_OK.timesec(1);
isochrons_OK.hour=isochrons_OK.time/3600;

end
% VEURE ->  csvqgis2isochrones()
%% PASSAR SLOPE A RAD 
% slope.data=tan(slope.data/180*pi);

%% PASSAR ASPECT A GAUS!!