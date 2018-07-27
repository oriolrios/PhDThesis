function [fmaskGRD]=CreateFMASK_GUI(GRD,N_bloks)
% scrip to set fuel breaks, (0 value) given a reference GRD map and
% coordinates of the square to set to 0
% INPUT
% GRD   = reference GRD
% N_bloks  = number of bloks to create
% xyrt  = XY right top (2X1)
%
% OUTPUT
% fmaskGRD = Modified GRD
%
% Example:
%
% CreateFMASK(fmask,[1000,1000],[2000,2000]);
fmaskGRD=GRD;
%fmaskGRD.data=ones(size(fmaskGRD.data));

for i =1:N_bloks
    [xx,yy] = ginput(2);
    [c,r]=getcr(fmaskGRD, xx, yy);% aixo són x y....
    c=sort(c);
    r=sort(r);
   fmaskGRD.data(r(1):r(2), c(1):c(2))=0;
    %fmaskGRD.data(r(1):r(2), c(1):c(2))=1;
end
figure; 
plotGRDimg(fmaskGRD)
end