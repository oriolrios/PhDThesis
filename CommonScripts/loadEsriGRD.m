function z=loadEsriGRD(txt,bounds)
% Lee un archivo ESRI-GRD y devuelve una estructura con los datos de salida.
% Convert noValue to NaN
%
% loadEsriGRD(txt,bounds)
% 
% Si BOUNDS es una matriz gráfica los datos con los datos entre los
% valores de límite. Si la matriz es vacía o no se utiliza, no gráfica nada.
% Ejemplo:
% loadEsriGRD('nuria.asc',[300:200:1500]); -> plota
% Nu=loadEsriGRD('nuria.asc'); ->no plota
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
% Ver también:
% loadrpi
% grd2cad, grd2vec, grd2googlemaps,
% grd2googleearth
%
%  Miguel Muñoz - m.munoz@upc.edu & Oriol Rios 2014 - oriol.rios@upc.edu
%  Copyright 2007
%  HISTORY:
%  $Revision: 0.0.1.8    $  $Date: 03/2008$
%  $Correction OR: grd.lim are defined from CORNER!
    
narginchk(1, 2);
nargoutchk(0, 1);

if ~ischar(txt)
    error('loadgrd:nofname',...
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

noplot=(nargout~=0);

if nargin==1
    noplot=1;
else
    if isempty(bounds)
        noplot=1;
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
    fprintf('Identified %s ESRI ASCI GRID version\n \n',case_flag)
elseif strcmpi(heading2{1}(1),'XLLCORNER') && strcmpi(heading2{1}(2),'YLLCORNER')
    case_flag='LLCORNER';
    fprintf('Identified %s ESRI ASCI GRID version\n \n',case_flag)
else
    fclose(fid);
    error('loadgrd:fileformat',...
        'Incorrect File. ESRI GRD ASCII input file is requires.');
    %error('loadgrd:fileformat',...
    %    'XLLCORNER/YLLCORNER version not implemented yet.');
end

ncol=double(nfc{2}(1));
nrow=double(nfc{2}(2));
z.dx=heading2{2}(3);
z.dy=-heading2{2}(3);

switch upper(case_flag)
    %case 'LLCENTER'
    case 'LLCORNER'
        lims=[heading2{2}(1) heading2{2}(1)+(ncol-1)*z.dx heading2{2}(2) heading2{2}(2)-(nrow-1)*z.dy];
    %case 'LLCORNER'
    case 'LLCENTER'
        lims=[heading2{2}(1)-z.dx/2 heading2{2}(1)+(ncol-1.5)*z.dx heading2{2}(2)+z.dy/2 heading2{2}(2)-(nrow-1.5)*z.dy];
end
mm=zeros(nrow,ncol);
cpu_first=0;
TT=100/nrow;

for i=1:nrow

    dt=textscan(fid,'%n',ncol);
    mm(nrow-i+1,:)=dt{1}; % SI FALLA AQUI CHECK que hi hagi CELLSIZE en lloc de dx i dy!!
    
    

    if (cputime-t1)>.7
        if cpu_first==0
            fprintf('Reading %3.2f%% ...  ',i*TT);
            cpu_first=1;
        else
        %str='\b';
        %a_str=repmat(str,1,18);
        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b%3.2f%% ...  ',i*TT);
        t1=cputime;
        end
    end
end
fprintf('\b\b\b\b\b\b\b\b\b\b\b\b%3.2f%% Done!\n',100);


fclose(fid);


x=linspace(lims(1),lims(2),ncol);
y=linspace(lims(3),lims(4),nrow);


width=lims(2)-lims(1);
height=lims(4)-lims(3);

z.xdist=x;
z.ydist=y;

z.dims=[nrow ncol];

z.lim=lims;

z.left=lims(1);
z.bottom=lims(3);

z.width=width;
z.height=height;
z.novalue=nan;
mm(mm==heading2{2}(4))=nan;

z.data=mm;

if ~noplot
    plotgrd(z,bounds); %surf 
end
end

