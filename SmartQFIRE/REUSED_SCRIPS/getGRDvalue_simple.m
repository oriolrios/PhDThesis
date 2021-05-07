function [value]=getGRDvalue_simple(grd,x,y)
% Extracts de GRD value of a given x y coordinates
% GRD is either a file in Esri format or a struct (loaded variable)
% If VARARGIN='e' --> Extrapoles grd value for coordinates out of domain!
% Oriol 2015 - CERTEC
%% (simplified)
% % if nargin>3
% %     if strcmp(varargin{1},'extrapol')
% %         [x,y]=extrapoleGRDcoordinates(x,y);
% %     else
% %         error('Invalid Option. Use: e=extrapol')
% %     end
% % end
% % 
% % if ~isreal(x) || ~isreal(y)
% %     error('Error, ''x'' or ''y'' are not real')
% % end
% % 
% % if ~isa(grd,'struct')
% %     grd_txt=grd;
% %     %clear(grd)
% %     fprintf('Loading ''%s'' EsriGRD file as STRUCT...\n',grd_txt');
% %     grd=loadEsriGRD(grd);
% %     %save(strcat(grd_txt,'.mat'),'grd'); % DO NOT save it to workspace
% % end
%% 
[x,y]=extrapoleGRDcoordinates(x,y,grd);
[c,r]=getcr(grd, x, y);% aixo són x y.... 

if ~isreal(c) || ~isreal(r)
    error('Error, ''r'' or ''c'' are not real')
end
%%
if any(r>grd.dims(1))|| any(r<0) || any(c>grd.dims(2))|| any(c<0)
    bug
end
value_ind=sub2ind(grd.dims,r,c);
value=grd.data(value_ind);


end