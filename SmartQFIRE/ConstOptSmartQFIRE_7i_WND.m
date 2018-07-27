% Constrained Optimization
% http://es.mathworks.com/help/optim/ug/fmincon.html
%
% x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub) defines a set of lower and upper 
% bounds on the design variables in x, so that the solution is always in 
% the range lb ? x ? ub. If no equalities exist, set Aeq = [] and beq = []. 
% If x(i) is unbounded below, set lb(i) = -Inf, and if x(i) is unbounded 
% above, set ub(i) = Inf.

%
% HISTORY
% $ 27/10/16 passing dt and res

function [x,fval,Invarians,CostVal] = ConstOptSmartQFIRE_7i_WND(xy_real,aspectA,slopeA,AllSpeedMapStrucGRD,AllDirMapStrucGRD,weight,At,I,OptIndexCh,dt,res,fId,ParallelPool)
    Invarians = [];
    CostVal = [];

% http://es.mathworks.com/help/optim/ug/optimoptions-and-optimset.html    
% WITHOUT OptimizationToolbox
%    opt=optimset; %creat an optimization object
%     opt.OutputFcn=@SaveTheOutputs;
%     %opt.PlotFcns=@optimplotx;
%     opt.PlotFcns=@optimplotfval;  
%     % Convergence criteria (default 1e-4!) both
%     %opt.TolX=1e-0;
%     %opt.TolFun=1e-0;

% WITH OptimizationToolbox
%opt = optimoptions('fmincon','Algorithm','quasi-newton'); FMINCON!!
opt = optimoptions('fmincon','Algorithm','interior-point');
% opt = optimoptions('fmincon','Algorithm','sqp');
% opt = optimoptions('fmincon','Algorithm','active-set');

opt.TolX=1e-10;%1e-5; %1e-10 DEFAULT
opt.TolFun=1e-10;%1e-5; %1e-6 DEFAULT

% opt.TolX=1e-3;%1e-5; %1e-10 DEFAULT
% opt.TolFun=1e-3;%1e-5; %1e-6 DEFAULT


if ParallelPool==1
    opt.UseParallel=true;
end

%EXPLORE THIS! (it is faster??)
%options = optimoptions('fmincon','SpecifyObjectiveGradient',true);

%opt.Display = 'iter'; %print iterations at command line
opt.OutputFcn=@SaveTheOutputs;
opt.PlotFcns=@optimplotfval; 

%Definitions
% inequality Mx-Mf>0
    A   = [1,-1,0,0,0,0,0];  
    b   = [0];
    Aeq = [];
    beq = [];
    % REPASSAR AQUEST LIMITS
    % Mf, Mx, SAV, Wo, U, theta, D 
    % CHANGE THETA LIMITS and bound them better
    lb  = [0.01, 0.12, 3753, 0.067,  0, -2*pi(), 0.06]; %low domain value
    ub  = [0.4,   0.4, 7270, 2.925, 15,  2*pi(), 1.83]; % high domain value
    nonlcon= [];
%     subjects the minimization to the nonlinear inequalities c(x) or 
%     equalities ceq(x) defined in nonlcon. 
    f=@(v) cost2opt_7i_WND(v,xy_real{1},xy_real,aspectA,slopeA,AllSpeedMapStrucGRD,AllDirMapStrucGRD,weight,At,OptIndexCh,dt,res,fId);
    
    %Run optimization
    [x fval] = fmincon(f,I,A,b,Aeq,beq,lb,ub,nonlcon,opt);
    
    %close(gcf) %close invariant plot
    
    % Nested functions
    function stopIt = SaveTheOutputs(x,optimvalues,state)
        stopIt = false;
        if isequal(state,'iter')
          Invarians = [Invarians; x];
          CostVal = [CostVal; optimvalues.fval];
        end
    end
    
end