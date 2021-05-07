% Constrained Optimization
% http://es.mathworks.com/help/optim/ug/fmincon.html
%
% x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub) defines a set of lower and upper 
% bounds on the design variables in x, so that the solution is always in 
% the range lb ? x ? ub. If no equalities exist, set Aeq = [] and beq = []. 
% If x(i) is unbounded below, set lb(i) = -Inf, and if x(i) is unbounded 
% above, set ub(i) = Inf.

function [x fval Invarians CostVal] = ConstOptSmartQFIRE(xy_real,fuelA,aspectA,slopeA,weight,dt,I,OptIndexCh,fId)
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

%EXPLORE THIS! (it is faster??)
%options = optimoptions('fmincon','SpecifyObjectiveGradient',true);

%opt.Display = 'iter'; %print iterations at command line
opt.OutputFcn=@SaveTheOutputs;
opt.PlotFcns=@optimplotfval; 

%Definitions
    A   = [];  
    b   = [];
    Aeq = [];
    beq = [];
    lb  = [0.001,0.01,0,-2*pi()]; %low domain value
    ub  = [10,1.2,20,2*pi()]; % high domain value
    nonlcon= [];
%     subjects the minimization to the nonlinear inequalities c(x) or 
%     equalities ceq(x) defined in nonlcon. 
    f=@(v) cost2opt(v,xy_real{1},xy_real,fuelA,aspectA,slopeA,weight,dt,OptIndexCh,fId);
    
    %Run optimization
    [x fval] = fmincon(f,I,A,b,Aeq,beq,lb,ub,nonlcon,opt);
    
    %close(gcf) %close invariant plot
    
    % Nested functions
    function stop = SaveTheOutputs(x,optimvalues,state)
        stop = false;
        if isequal(state,'iter')
          Invarians = [Invarians; x];
          CostVal = [CostVal; optimvalues.fval];
        end
    end
    
end