function [newGRD]=desplacaGRDtoZero(GRD)
%%This function moves a GRD to a 0,0 coordinats properly

newGRD=GRD;
newGRD.lim(2)=newGRD.lim(2)-newGRD.lim(1);
newGRD.lim(4)=newGRD.lim(4)-newGRD.lim(3);
newGRD.lim(1)=0;
newGRD.lim(3)=0;

newGRD.left=0;
newGRD.bottom=0;

%% Only for wind field struct
 for i=1:length(GRD.Deg)
      newGRD.dataStrc{i,1}=ones(size(GRD.dataStrc{i,1}))*GRD.Deg(i);
     %newGRD.dataStrc{i,1}=ones(size(GRD.dataStrc{i,1}))*GRD.AllU(1);
 end

end
