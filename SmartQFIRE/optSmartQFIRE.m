% Exemple de guardar dades:
% http://es.mathworks.com/help/matlab/math/output-functions.html
function [x fval Invarians CostVal] = optSmartQFIRE(xy_real,fuelA,aspectA,slopeA,weight,dt,I)
    Invarians = [];
    CostVal = [];
    
   opt=optimset; %creat an optimization object
    opt.OutputFcn=@SaveTheOutputs;
    %opt.PlotFcns=@optimplotx;
    opt.PlotFcns=@optimplotfval;
    
    % Convergence criteria (default 1e-4!) both
%     opt.TolX=1e-0;
%     opt.TolFun=1e-0;
%     
    f=@(v) cost2opt(v,xy_real{1},xy_real,fuelA,aspectA,slopeA,weight,dt);
    
    %Run optimization
    [x fval] = fminsearch(f,I,opt);
        
    % Nested functions
    function stop = SaveTheOutputs(x,optimvalues,state)
        stop = false;
        if isequal(state,'iter')
          Invarians = [Invarians; x];
          CostVal = [CostVal; optimvalues.fval];
        end
    end
    
end