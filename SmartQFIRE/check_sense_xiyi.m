% CHECK xiyi DIRECTION (clockwise-counter clockwise) (FER SCRIP CHECK A PART)
% and retorn the corrected XY matrix.
% If 'reverse' is stated, the algorithm works in inverse mode. 
function [xiyi_ok, inverted_flag]=check_sense_xiyi(xiyi,varargin)
rev_flag=0;
if nargin>1
    if strcmp(varargin{1},'reverse')
        rev_flag=1;
    end
end

%get front center
%[geom,~, ~]=polygeom( xiyi(:,1), xiyi(:,2));
[geom,iner, cpmo]=polygeom( xiyi(:,1), xiyi(:,2)); 

v1= [xiyi(2,1)-xiyi(1,1) xiyi(2,2)-xiyi(1,2) 0];
v2=[ geom(2)-xiyi(1,1) geom(3)-xiyi(1,2) 0];
v1_X_v2=cross(v1,v2);
%
if v1_X_v2(3)>0     % counter clockwise!
    if rev_flag==1
        xiyi_ok=flipud(xiyi);
        %disp('Warning: xiyi inverted to be clockwise (reverse ON)')
        inverted_flag=1;       
    else
        xiyi_ok=xiyi;
        inverted_flag=0;
    end
elseif v1_X_v2(3)<0 % clockwise!
    if rev_flag==1
        xiyi_ok=xiyi;
        inverted_flag=0;
    else
        xiyi_ok=flipud(xiyi);
        %disp('Warning: xiyi inverted to be counterclockwise')
        inverted_flag=1;
    end
else
    disp('Crossproduct=0, try to use other points?')
    inverted_flag=NaN;
end

end