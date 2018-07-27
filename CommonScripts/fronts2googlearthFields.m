function fronts2googlearthFields(filename, FRONTS,zone,hemisphere,varargin)
% Same as fronts2googlearth but handles new scalar STRUCT
% function fronts2googlearthFields(filename, FRONTS,zone,hemisphere,varargin)
% INPUT
% FRONTS - STRUCT with field:
%                            FRONTS.xy   -> cell array with fronts GPS coordinates. 
%                            FRONTS.time -> column vector with fronts time

% USE refpoints2gps.m
%
% fronts2googlearth(FILENAME,ZONE,ZONE,HEMISPHERE)
% fronts2googlearth(FILENAME,ZONE,ZONE,HEMISPHERE, COLOR)
% fronts2googlearth(FILENAME,ZONE,ZONE,HEMISPHERE, COLOR, MASK)
%
% FILENAME = Nombre del archivo GRD.
%
% FRONTS   = frentes georeferenciados
% ZONE= Número de la zona (por ejemlo: 31, 30; Por defecto=31): NOTA: mirar al earth a quina correspon (opcions-marcator)
% HEMISPHERE = 'N' ó 'S' (Por defecto 'N')
%
% VARARGIN 
%               - VARARGIN{1} = (DEFAULT HOT colormap) = Passar el colormap 'k','r','g','r' 
%               - VARARGIN{2} = MASK [0-1] Transparence of lines (DEFAULT=1)

% ------------------------------------------------------------------
% DATUM DEFECTO 70
%           = Indica el datum utilizados en las cooredenadas UTM del GRD.
%         La funcion SETDATUM presenta una lista de datum disponible.
%         Por el momento, se aceptan sólo algunos de los siguientes datums:
%           40 - GRS80 - Geodetic Reference System 1980 -IUGG 1980-
%           41 - Hayford 1909, ED50
%           46 - International 1909
%           47 - International 1924, ED50
%           70 - WGS84 (Google Hearth)
%
% Por defecto se datum == 41 'ED50'.
% Para la conversión se asume GRS80 ~= WGS84.
%
% NOTA: Para graficar las curvas de isorisk en GoogleMap se debe utilizar
%  el DATUM a partir del cual se obtuvieron las coordenadas UTM y no las
%  que utiliza Google. Por ejemplo si las coordenadas UTM se corresponden
%  con las ICC (Intituto cartográfico de Cataluña) se debe utilizar el
%  datum 41.
%
% See also
% grd2cad, loadgrd, grd2vec, utm2latlon, setdatum
%
% Miguel (c) 2007
% Modified Oriol 2014
%
narginchk(2, 6);

datum=70;
if ~isstruct(FRONTS) %if it's not an struct with INFO on time
    fronts.xy = FRONTS;
    fronts.time =60*[0:1:size(fronts.xy,1)-1]'; %Assume time step 1min (60sec)
else
    fronts=FRONTS;
end

Nfronts_times=length(fronts);
Style_id_fronts_times=cell(1,Nfronts_times);
StyleUrl_id_fronts_times=cell(1,Nfronts_times);

%% SET COLOR & MASK
if nargin>=5 && ischar(varargin{1})
    color=lower(varargin{1});
    switch color
        case {'k','black'}
            fronts_colormap=zeros(Nfronts_times,3);
        case {'b', 'blue'}
            fronts_colormap=zeros(Nfronts_times,3);
            fronts_colormap(:,1)=255;
        case {'g', 'green'}
            fronts_colormap=zeros(Nfronts_times,3);
            fronts_colormap(:,2)=255;
        case {'r', 'red'}
            fronts_colormap=zeros(Nfronts_times,3);
            fronts_colormap(:,3)=255;
        case {'y', 'yellow'}
            fronts_colormap=zeros(Nfronts_times,3);
            fronts_colormap(:,2:3)=255;
        case {'m', 'magenta'}
            fronts_colormap=zeros(Nfronts_times,3);
            fronts_colormap(:,3)=255;
            fronts_colormap(:,1)=127;
        case {'lb', 'light blue'}
            fronts_colormap=zeros(Nfronts_times,3);
            fronts_colormap(:,1:2)=255;
    end
    if nargin>5 
        if varargin{2}<=1 && varargin{2}>=0
        mask=round(varargin{2}*255);
        else
        error('Mask must be between [0-1]')
        end
    else
        mask=255; %Default
    end    
else %DEFAULT HOT colormap
    fronts_colormap=fliplr(floor(colormap(hot)*255)); %google uses bgr!! (no grb)
    mask=255; %Default
end
kk=size(fronts_colormap,1);

if Nfronts_times>kk
    k=Nfronts_times-kk;
    fronts_colormap(kk+1:Nfronts_times,:)=fronts_colormap(1:k,:);
end
% ADD mask info
fronts_colormap=[mask*ones(size(fronts_colormap,1),1) fronts_colormap];
%NOTA:  ff per es el 255 del canal alpha!! 
%colors=sprintf('#ff%0.2x%0.2x%0.2x \n',hotmap()');
%%
%Folder_name=
%  &lt;sub&gt;0&lt;sub&gt; <sub>0<sub>
for i=1:Nfronts_times
    %Style_id_fronts_times{i}=upper(sprintf('t &lt;sub&gt;0&lt;sub&gt; + %d min',fronts.time(i)));
    Style_id_fronts_times{i}   =upper(sprintf('t0 + %d sec',fronts(i).time));
    StyleUrl_id_fronts_times{i}=upper(sprintf('t0 + %d sec',fronts(i).time));
end
disp(sprintf('Writing file ...')); %#ok<*DSPS>
filekml=[filename '.kml'];
fid=fopen(filekml,'w','n','UTF-8');

fwrite(fid,sprintf('<?xml version="1.0" encoding="UTF-8"?>\n'));
fwrite(fid,sprintf('<kml xmlns="http://www.opengis.net/kml/2.2">\n'));
fwrite(fid,sprintf('<Document>\n'));
fwrite(fid,sprintf('<name>%s</name>\n',upper(filename)));
fwrite(fid,sprintf('<open>1</open>\n'));
fwrite(fid,sprintf('<description><![CDATA[Front isochrones from <n>%s</n>.',filename));
fwrite(fid,sprintf('<br/>By Miguel Muñoz & Oriol Rios copy; 2014]]></description>\n'));

for i=1:Nfronts_times
    fwrite(fid,sprintf('<Style id="%s">\n',Style_id_fronts_times{i}));
    fwrite(fid,sprintf(' <LineStyle>\n'));
%    fwrite(fid,sprintf('   <color>%s</color>\n',sprintf('#ff%0.2x%0.2x%0.2x ',fronts_colormap(i,:)')));
    fwrite(fid,sprintf('   <color>%s</color>\n',sprintf('#%0.2x%0.2x%0.2x%0.2x ',fronts_colormap(i,:)')));
    fwrite(fid,sprintf('   <width>4</width>\n'));
    fwrite(fid,sprintf(' </LineStyle>\n'));
    fwrite(fid,sprintf('</Style>\n'));
end

for i=1:Nfronts_times
    fwrite(fid,sprintf('<Folder>\n'));
    fwrite(fid,sprintf('<name>%s</name>\n',Style_id_fronts_times{i}));
    fwrite(fid,sprintf('<open>0</open>\n'));    
    
    [lat,long]=utm2latlon(fronts(i).xy(:,1),fronts(i).xy(:,2),zone,hemisphere,datum);
    
    fwrite(fid,sprintf('<Placemark>\n'));
    fwrite(fid,sprintf(' <name>%s</name>\n',Style_id_fronts_times{i}));
    fwrite(fid,sprintf(' <styleUrl>#%s</styleUrl>\n',StyleUrl_id_fronts_times{i}));
    fwrite(fid,sprintf(' <LineString>\n'));
    fwrite(fid,sprintf('   <extrude>0</extrude>\n'));
    fwrite(fid,sprintf('   <tessellate>0</tessellate>\n'));
    fwrite(fid,sprintf('   <altitudeMode>clampToGround</altitudeMode>\n'));
    fwrite(fid,sprintf('   <coordinates>'));
    
    fwrite(fid,sprintf('%8.7f,%8.7f',long(1),lat(1)));
    for jj=2:size(fronts(i).xy,1)
        fwrite(fid,sprintf(' %8.7f,%8.7f',long(jj),lat(jj)));
    end
    fwrite(fid,sprintf('</coordinates>\n'));
    fwrite(fid,sprintf(' </LineString>\n'));
    fwrite(fid,sprintf('</Placemark>\n'));
    fwrite(fid,sprintf('</Folder>'));

end

fwrite(fid,sprintf('\n</Document>\n</kml>\n'));

fclose(fid);
disp(sprintf('Obrint %s.kml ...',filename));
winopen(filekml);
end