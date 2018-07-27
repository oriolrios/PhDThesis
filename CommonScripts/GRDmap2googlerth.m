function GRDmap2googlerth(out_filename, GRD,zone,hemisphere, datum, varargin)
%IMFFIELD2GOOGLERTH(out_filename, field_image_name,refpoints,zone,hemisphere, varargin)
%
% plots any field map (input as a GRD)  as a georeferenced image
% INPUTS
%
% FILENAME          = Nombre del archivo GRD.
% GRD               = either a GRD file or 'png' image (if PNG refpoint of corners must be given
%
% varargin{1} = transparency [0-100]
% varargin{2} = refpoints = refpoints.gps (UTM data) refpoints.xy (pix
%                     data) of the image cornenrs [Xmin Xmax Ymin Ymax]

% ZONE= Número de la zona (por ejemlo: 31, 30; Por defecto=31): NOTA: mirar% al eath a quina correspont (opcions-marcator)
% HEMISPHERE = 'N' ó 'S' (Por defecto 'N')
% DATUM DEFECTO 70
%           = Indica el datum utilizados en las cooredenadas UTM del GRD.
%          Por el momento, se aceptan sólo algunos de los siguientes datums:
%           40 - GRS80 - Geodetic Reference System 1980 -IUGG 1980-
%           41 - Hayford 1909, ED50
%           46 - International 1909
%           47 - International 1924, ED50
%           70 - WGS84 (Google Hearth)

%% PROGRAM
if nargin<=2
    zone=31;
    hemisphere='N';
    datum=70;
elseif nargin==3
    hemisphere='N';
    datum=70;
elseif nargin==4
    datum=70;
end  

% if nargin>5
%     mask=round(varargin{1}*255);
%     if nargin>6
%         xy_pix_lim=varargin{2};
%         if any(xy_pix_lim)<1
%            error('Els límits de la imatge han de ser més grans que 1!!!') 
%         end
%         fuel_depth_new=field_image_name(1:xy_pix_lim(2),1:xy_pix_lim(1));
%         field_image_name=[];
%         field_image_name=fuel_depth_new;
%     end
% else
%     mask=100; % means 0.4*255
% end
% %% Print fuel map
% max_map=max(max(field_image_name));
% min_map=min(min(field_image_name));
% 
% new_fuel_map=mat2gray(field_image_name, [min_map max_map]);
% new_fuel_map=new_fuel_map*255;
%     fuel_colormap= [255 153 51; 178 255 102]/255; % color orange and light green
%     %imshow(new_fuel_map,fuel_colormap);
%     imwrite(new_fuel_map,fuel_colormap,image_name,'jpg')

if ischar(GRD)
    try 
        IMG=imread(GRD);
        refpoints=varargin{1};
    catch
        error('MyErr:GRDmap2googlerth. Invalid PNG file name or refpoints.');
    end
else
    IMG=GRD.data;
    refpoints=GRD.lim;
    II=imagesc(IMG);
    cc=colormap;
    %IMG=repmat(II,[1,1,3]);
    set(gca,'XTick',[]) % Remove the ticks in the x axis!
    set(gca,'YTick',[]) % Remove the ticks in the y axis
    set(gca,'Position',[0 0 1 1]) % Make the axes occupy the hole figure
    imwrite(II.CData,cc,strcat(out_filename,'.png'),'png')
    
end


%% Geoposisionate image bounds
xdim=[0 size(IMG,2)];
ydim=[0 size(IMG,1)];
xy_dim_gps=[refpoints(1:2)',refpoints(3:4)'];

%[xy_dim_gps]=refpoints2gps(ref_mat,[xdim' ydim']);
[lat,long]=utm2latlon(xy_dim_gps(:,1),xy_dim_gps(:,2),zone,hemisphere,datum);

if nargin>5
    mask=varargin{1};
else
    mask=100; % means 0.4*255
end
%% Write KML
disp(sprintf('Writing file ...')); %#ok<*DSPS>
filekml=[out_filename '.kml'];
fid=fopen(filekml,'w','n','UTF-8');

fwrite(fid,sprintf('<?xml version="1.0" encoding="UTF-8"?>\n'));
fwrite(fid,sprintf('<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">\n'));
fwrite(fid,sprintf('<GroundOverlay>\n'));
fwrite(fid,sprintf('  <name>%s</name>\n',upper(out_filename)));
fwrite(fid,sprintf('  <color>%0.2xffffff</color>\n',mask));
fwrite(fid,sprintf('  <Icon>\n'));
fwrite(fid,sprintf('      <href>%s</href>\n',strcat(out_filename,'.png')));
fwrite(fid,sprintf('      <viewBoundScale>1</viewBoundScale>\n'));
fwrite(fid,sprintf('  </Icon>\n'));
fwrite(fid,sprintf('    <LatLonBox>\n'));

fwrite(fid,sprintf('      <north>%8.7f</north>\n',max(lat))); %max min pq funcioni en 'S' i 'N'
fwrite(fid,sprintf('      <south>%8.7f</south>\n',min(lat)));
fwrite(fid,sprintf('      <east>%8.7f</east>\n',max(long)));
fwrite(fid,sprintf('      <west>%8.7f</west>\n',min(long)));

fwrite(fid,sprintf('	</LatLonBox>\n'));
fwrite(fid,sprintf('</GroundOverlay>\n'));
fwrite(fid,sprintf('</kml>\n'));

fclose(fid);
disp(sprintf('Obrint %s.kml ...',out_filename));
winopen(filekml);
end














