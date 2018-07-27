function [W_char, S_char, M_char]=Original2Reduce(w,s,m)  
% WARNIRNG!! for the moment only works if  ALL INPUTS ARE FOM SAME CLASS!!!
% ie. [w1 0 0 0 0; w2 0 0 0 0]
%% REMEMBER ONLY WORKS FOR STATIC FUELS!!
% INPUT
% w [1x5]
% s [1x5]
% m [1x5]

% (no needed) its defined by w input CAT (fuel cateogry 1-6 possibles)
%
% OUTPUT
% % W_char
% S_char
% M_char

% this comes from an numerical optimization process
CoefMat= [1.00, 0,0,0,0,0  , 1.00, 0  , 0  , 0  , 1.00, 0  , 0  , 0  , 0;...     
 0.14, 4.15, 3.41, 0  , 0  , 3.12, 3.24, 3.55, 0  , 0  , 0.89, 6.89, 15.00, 0  , 0;...
 0.88, 0.15, 0.12, 0  , 4.49, 4.03, 3.24, 2.40, 0  , 0.21, 0.68, 15.00, 15.00, 0  , 0.49;...   
 15.00, 2.47, 0  , 0  , 0.56, 0.15, 2.87, 0  , 0  , 0  , 0.16, 2.92, 0  , 0  , 0.23;...   
 1.06, 0  , 0  , 0  , 10.32, 2.12, 0  , 0  , 0  , 0.05, 0.81, 0  , 0  , 0  , 1.06;...   
 0.00, 9.97, 7.54, 1.47, 0  , 1.04, 0.04, 0.53, 0.30, 0  , 1.07, 6.82, 15.00, 2.11, 0];

% find Categry
CatV=w./w;
CatV(isnan(CatV))=0;
CAT_MAT=[1 0 0 0 0;...
        1 1 1 0 0;...
        1 1 1 0 1;...
        1 1 0 0 1;...
        1 0 0 0 1;...
        1 1 1 1 0];
flag=0;
%% ONLY WORKS IF ALL INPUTS ARE FOM SAME CLASS!!!
for i=1:6
    if sum(CatV(1,:)==CAT_MAT(i,:))==5
        CAT=i;
        flag=1;
    end
end
if flag==0
    error('You input a dynamic fuel')
end

% overdetermined system.. mean of results.
W_w0= bsxfun(@times, w, CatV(1,:)./CoefMat(CAT,1:5));
%W_w0= w.*CatV./CoefMat(CAT,1:5);
W_w0(W_w0==0)=NaN;
W_char = nanmean(W_w0,2);

S_w0= bsxfun(@times, s, CatV(1,:)./CoefMat(CAT,6:10));
%S_w0= s.*CatV./CoefMat(CAT,6:10);
S_w0(S_w0==0)=NaN;
S_char = nanmean(S_w0,2);

M_w0= bsxfun(@times, m, CatV(1,:)./CoefMat(CAT,11:15));
%M_w0= m.*CatV./CoefMat(CAT,11:15);
M_w0(M_w0==0)=NaN;
M_char = nanmean(M_w0,2);

end