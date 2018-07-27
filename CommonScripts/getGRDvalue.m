function [value]=getGRDvalue(grd,x,y,varargin)
% Extracts de GRD value of a given x y coordinates
% GRD is either a file in Esri format or a struct (loaded variable)
% If VARARGIN='e' --> Extrapoles grd value for coordinates out of domain!
%
% Examples: 
% [value]=getGRDvalue(fuel,x,y)
% [value]=getGRDvalue('fuel.asc',x,y)
% [value]=getGRDvalue('fuel.asc',x,y,'e')
% [value]=getGRDvalue('fuel.asc',x,y,'extrapol')
%
% Oriol 2015 - CERTEC

%% Program
if nargin>3
    if strcmp(varargin{1},'e') || strcmp(varargin{1},'extrapol')
        [x,y]=extrapoleGRDcoordinates(x,y,grd);
    else
        error('MyErr:getGRDvalue. Input Invalid Option. Use: ''e'' or ''extrapol''.')
    end
end

if ~isreal(x) || ~isreal(y)
    error('MyErr:getGRDvalue. Error, ''x'' or ''y'' are not real')
end

% if ~isa(grd,'struct')
%     grd_txt=grd;
%     %clear('grd')
%     fprintf('Loading ''%s'' EsriGRD file as STRUCT...\n',grd_txt');
%     grd=loadEsriGRD(grd_txt);
%     save(strcat(grd_txt,'.mat'),'grd');
% end

[c,r]=getcr(grd, x, y);% aixo són x y.... 

if ~isreal(c) || ~isreal(r)
    error('MyErr:getGRDvalue. Error, ''r'' or ''c'' are not real')
end

value_ind=sub2ind(grd.dims,r,c);
value=grd.data(value_ind);

% Nested Functions
