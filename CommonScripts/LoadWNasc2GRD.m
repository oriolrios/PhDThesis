function grd=LoadWNasc2GRD(txt)
% Read the *.asc WindNinja file with wind direction and speed and outputs a GRD Struct
% Convert noValue to NaN
%
% loadEsriGRD(txt,bounds)
% 
% Example:
%
% 
% ESTRUCTURA GRD:
% 	.DATA = Matriz de puntos
% 	.LIMS = Límites de la matriz
% 	.xdist = Vector de distancia en X
% 	.ydist = Vector de distancia en Y
%   .lim = Límite de la grilla (punto medio) CORNER! (corregit) UTM
%   .dx = resolution horizontal (X)
%   .dy = resolution vertical (Y)
% 
% ============================================
% ESRI ASCII raster FILE FORMAT
%     NCOLS xxx
%     NROWS xxx
%     XLLCENTER xxx | XLLCORNER xxx
%     YLLCENTER xxx | YLLCORNER xxx
%     CELLSIZE xxx
%     NODATA_VALUE xxx
%     row 1
%     row 2
%     ...
%     row n
% Row 1 of the data is at the top of the raster, row 2 is just under row 1, and so on.
%
% NCOLS	Number of cell columns.	Integer greater than 0.
% NROWS	Number of cell rows.	Integer greater than 0.
% XLLCENTER or XLLCORNER	X coordinate of the origin (by center or lower left corner of the cell).	Match with Y coordinate type.
% YLLCENTER or YLLCORNER	Y coordinate of the origin (by center or lower left corner of the cell).	Match with X coordinate type.
% CELLSIZE	Cell size.	Greater than 0.
% NODATA_VALUE	The input values to be NoData in the output raster.
% ============================================
% 
% See also:
% loadEsriGRD
% loadrpi
% grd2cad, grd2vec, grd2googlemaps,
% grd2googleearth
%
%  Miguel Muñoz - m.munoz@upc.edu & Oriol Rios 2016 - oriol.rios@upc.edu
%  HISTORY:
%
    
% narginchk(1, 2);
% nargoutchk(0, 1);

if ~ischar(txt)
    error('loadWNasc:nofname',...
        'Invalid file name.');
end

if (exist(txt,'file')~=2)
    lg=length(txt);
    if numel(txt)<=4 || ~(strcmpi(txt(lg-3:lg),'.grd'))
        txt=strcat(txt,'.grd');
    end
    if exist(txt,'file')~=2
        %error('loadgrd:nofname','File "%s" does not exist.',txt);
        error('loadgrd:nofname','File "%s" or "%s" does not exist.',txt,txt(1:end-4));
    end
end


t1=cputime;

fid=fopen(txt,'r');

nfc=textscan(fid,'%s %d',2);

if ~strcmpi(nfc{1}(1),'NCOLS') || ~strcmpi(nfc{1}(2),'NROWS')
    fclose(fid);
    error('loadgrd:fileformat',...
        'Incorrect File. ESRI GRD ASCII input file is requires.');
end

heading2=textscan(fid,'%s %n',4);
if strcmpi(heading2{1}(1),'XLLCENTER') && strcmpi(heading2{1}(2),'YLLCENTER')
    case_flag='LLCENTER';
%     fprintf('Identified %s ESRI ASCI GRID version\n \n',case_flag)
elseif strcmpi(heading2{1}(1),'XLLCORNER') && strcmpi(heading2{1}(2),'YLLCORNER')
    case_flag='LLCORNER';
%     fprintf('Identified %s ESRI ASCI GRID version\n \n',case_flag)
else
    fclose(fid);
    error('loadgrd:fileformat',...
        'Incorrect File. ESRI GRD ASCII input file is requires.');
    %error('loadgrd:fileformat',...
    %    'XLLCORNER/YLLCORNER version not implemented yet.');
end

ncol=double(nfc{2}(1));
nrow=double(nfc{2}(2));
grd.dx=heading2{2}(3);
grd.dy=-heading2{2}(3);

switch upper(case_flag)
    %case 'LLCORNER'
	case 'LLCORNER'
        lims=[heading2{2}(1) heading2{2}(1)+(ncol-1)*grd.dx heading2{2}(2) heading2{2}(2)-(nrow-1)*grd.dy];
    %case 'LLCENTER'
    case 'LLCENTER'
        lims=[heading2{2}(1)-grd.dx/2 heading2{2}(1)+(ncol-1.5)*grd.dx heading2{2}(2)+grd.dy/2 heading2{2}(2)-(nrow-1.5)*grd.dy];
end
mm=zeros(nrow,ncol);

for i=1:nrow

    dt=textscan(fid,'%n',ncol);
    %mm(nrow-i+1,:)=dt{1};
    mm(nrow-i+1,:)=dt{1};
    
end
% fprintf('\b\b\b\b\b\b\b\b\b\b\b\b%3.2f%% Done!\n',100);


fclose(fid);


x=linspace(lims(1),lims(2),ncol);
y=linspace(lims(3),lims(4),nrow);


width=lims(2)-lims(1);
height=lims(4)-lims(3);

grd.xdist=x;
grd.ydist=y;

grd.dims=[nrow ncol];

grd.lim=lims;

grd.left=lims(1);
grd.bottom=lims(3);

grd.width=width;
grd.height=height;
grd.novalue=nan;
mm(mm==heading2{2}(4))=nan;

grd.data=mm;

end

