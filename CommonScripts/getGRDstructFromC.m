function [grd]=getGRDstructFromC(filename)
% creatGRDstructFromC() does the same as LoadWNasc2GRD() but performing
% reading operations in C. 
% ATENTION! Current version only supports xllcorner,yllcorner ASC files.
% Make another C (MEX) program to read the strings. 
%
% NEEDS precompiled functions
% - getASCheading.mexw64
% - getASCdata.mexw64
%
% Atention: Do not read nodata (might be NAN hard to handle)
%
% ESTRUCTURA GRD:
%   .dx = resolution horizontal (X)
%   .dy = resolution vertical (Y)
%   .lim = Límite de la grilla (punto medio) CORNER! (corregit) UTM
%   .dims= size of data
% 	.DATA = Matriz de puntos
%(NO).xdist = Vector de distancia en X
%(NO).ydist = Vector de distancia en Y
%(NO).novalue= No data value
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
%  HISTORY:
%
%
% ORios 2016
%
case_flag='LLCORNER'; % CURRENTLY only this supported!

heading=getASCheading(filename);

nrow      = heading(1);
ncol      = heading(2);
grd.dx    = heading(5);
grd.dy    = -heading(5);

% xcentered x corenr cases
switch upper(case_flag)
    %case 'LLCORNER'
    case 'LLCORNER'
        grd.lim=[heading(3) heading(3)+(ncol-1)*grd.dx heading(4) heading(4)-(nrow-1)*grd.dy];
    %case 'LLCENTER'
    case 'LLCENTER'
        error('MyErr:creatGRDstructFromC: ''LLCENTER'' Not yet supported')
        %grd.lim=[heading(3) heading(3)+(ncol-1)*grd.dx heading(4) heading(4)-(nrow-1)*grd.dy];
end

grd.dims=[nrow ncol];
grd.data=getASCdata(filename);
