function [fmaskGRD]=CreateFMASK(GRD,xylb,xyrt)
% scrip to set fuel breaks, (0 value) given a reference GRD map and
% coordinates of the square to set to 0
% INPUT
% GRD   = reference GRD
% xylb  = XY left botom (2X1)
% xyrt  = XY right top (2X1)
%
% OUTPUT
% fmaskGRD = Modified GRD
%
% Example:
% 
% CreateFMASK(fmask,[1000,1000],[2000,2000]);
fmaskGRD=GRD;
fmaskGRD.data=ones(size(fmaskGRD.data));
[c,r]=getcr(fmaskGRD, [xylb(1);xyrt(1)], [xylb(2);xyrt(2)]);% aixo són x y.... 

fmaskGRD.data(r(1):r(2), c(1):c(2))=0;
end