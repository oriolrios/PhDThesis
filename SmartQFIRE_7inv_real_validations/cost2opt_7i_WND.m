function CostFuncValue=cost2opt_7i_WND(v,xiyi,xy_real,aspect,slope,AllSpeedMapStrucGRD,AllDirMapStrucGRD,weight,At,OptIndexCh,dt,res,fId)
%
% Dumm function to pass parameters to the optimizer and select COST Index
% 
%
% HISTORY
% $ 27/10/16 passing dt and res
%
%
% Write outputs on a file
if isempty(fId)
    SaveOut=0;
else
    SaveOut=1;
end
%Mf, Mx, SAV, L, U, theta,D

Mf   = v(1);
Mx   = v(2);
SAV  = v(3);
L    = v(4);
U    = v(5);
theta= v(6);
D    = v(7);

%% CHOSE WHICH ALGORITHM YOU WANT (MAT O MEX)
%matlab
 [xy_model]=expansion_f_s_simple_7i_WND(Mf,Mx,SAV,L,U,theta,D,xiyi,aspect,slope,AllSpeedMapStrucGRD,AllDirMapStrucGRD,At,dt,res);                               
% C expansion                            
% [xy_model]=Cexpansion_f_s_simple_7i_WN_bo_mex(Mf,Mx,SAV,L,U,theta,D,xiyi,aspect,slope,AllSpeedMapStrucGRD,AllDirMapStrucGRD,At,dt,res);                               

[CostArea,SDI,Sorensen,Jaccard,SDI_a,Sorensen_a,Jaccard_a]=real_model_AREA_cost(xy_real,xy_model.xy);

%% Select Index to Optimize

switch OptIndexCh
    case 'CostArea'
        OptIndex= CostArea; ind=1; % ERROR! Falla en els fronts grans!
        
    case 'SDI'
        OptIndex= SDI; ind=2;
        
    case 'Sorensen'
        OptIndex= Sorensen; ind=3;
        
    case 'Jaccard'
        OptIndex= Jaccard; ind=4;
        
    case 'SDI_a'
        OptIndex= SDI_a; ind=5;
        
    case 'Sorensen_a'
        OptIndex= Sorensen_a; ind=6;
        
    case 'Jaccard_a'
        OptIndex= Jaccard_a; ind=7;
        
end


%eliminate NaN at 2st position(identical shapes)


%% Weight
switch weight
    case 'idty' % -> II
        CostFuncValue=sum(OptIndex);
        
    case 'lin' % -> linear
        N=length(OptIndex);
        CostFuncValue=[1:1:N]*OptIndex; %vect multp. (multp & sum)
        
    case 'linN' % -> linear-norm
        N=length(OptIndex);
        CostFuncValue=([1:1:N]./N)*OptIndex; %vect multp. (multp & sum)
        
    case 'expN' % -> exp
        N=length(OptIndex);
        i=1:1:N;
        CostFuncValue=(exp(i)./N)*OptIndex; %vect multp. (multp & sum)
    otherwise
        error('MyErr: incorrect OptIndex value inputted')
        
end

if SaveOut==1
    fprintf(fId,'%f,%f,%f,%f,%f,%f,%f,%f\n',mean(OptIndex),mean(CostArea),mean(SDI),mean(Sorensen),mean(Jaccard),mean(SDI_a),mean(Sorensen_a),mean(Jaccard_a));
    %fprintf(fId,'%f,%f,%f,%f,%f,%f,%f,%f\n',OptIndex,CostArea,SDI,Sorensen,Jaccard,SDI_a,Sorensen_a,Jaccard_a);
end

end
