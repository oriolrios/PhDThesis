% Devuelve la columna y fila de un punto (x,y) en una ISOMATRIX
% [COL,ROW]=GETREC(ISOMATRIX,X,Y]
% ISOMATRIX= Matriz de curvas de iso riesgo
% 
% Ver tambien: makeisomatrix, savegrd, 
% 	escjetfire, escpoolfire, escbleve
% 	riskjetfire, riskpoolfire, riskbleve
% 
% 
% Miguel - CERTEC (C) 2007
% Hisroty:
% OR: modified abs to filter negative dy
function [c,r]=getcr(isom, x, y)
    c=floor((x-isom.lim(1))./abs(isom.dx)+.5)+1;
    r=floor((y-isom.lim(3))./abs(isom.dy)+.5)+1;
	
