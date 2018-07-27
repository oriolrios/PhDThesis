%#########################################################################%
%       DIRECT JACOBIAN CALCULATION using AUTOMATIC DIFFERENTIATION       %
% code differentiated using  https://adimat.sc.rwth-aachen.de             %
%               Oriol Rios 2014                                           %
%                                                    oriolrios@gmail.com  %
%#########################################################################%
% Can Run in scalar mode or using derivative class
% Use varargin in case of many invariants?
function [xy_fronts, Jacobian]=JacAD_expansion_f_2class(Imfw,U,theta,xiyi,fuel_depth, dt, tf)


%% ----- SELECT MODE ----- %%
mode='scalar';             %%
%mode='derivclass';         %%
%% ----- ----------- ----- %%

if strcmpi(mode,'scalar')
    adimat_derivclass('scalar_directderivs'); % select runtime environment for scalar mode
    % create gradient arrays
    g_Imfw = zeros(size(Imfw)); % create zero derivative inputs
    g_U = zeros(size(U)); % create zero derivative inputs
    g_theta = zeros(size(theta)); % create zero derivative inputs
    
    % create the 3 directions for
    dir_vect=[1 0 0; 0 1 0; 0 0 1];
    % aixó passa per no poder fer-ho vectorialment!
    for dir=1:3
        
        g_Imfw(1)  = dir_vect(1,dir); % set derivative direction
        g_U(1)     = dir_vect(2,dir); % set derivative direction
        g_theta(1) = dir_vect(3,dir); % set derivative direction
        
        [g_xy_fronts, xy_fronts] =g_expansion_f(g_Imfw, Imfw, g_U, U, g_theta, theta, xiyi, fuel_depth, dt, tf); % run the differentiated function
        %[g_xy_fronts_old, xy_fronts_old] =g_expansion_f_old(g_Imfw, Imfw, g_U, U, g_theta, theta, xiyi, fuel_depth); % run the differentiated function
        
        dirder_xy{1,dir} = cell2mat(g_xy_fronts(:,1));

    end
    Jacobian1=cell2mat(dirder_xy);
    Jacobian=[Jacobian1(:,1:2:end);Jacobian1(:,2:2:end)];
    
else
    adimat_derivclass('opt_derivclass')
    [g_Imfw,] = createFullGradients(Imfw);
    [g_U]     = createFullGradients(U);
    [g_theta] = createFullGradients(theta);
    
    [g_xy_fronts, xy_fronts]= g_expansion_f(g_Imfw, Imfw, g_U, U, g_theta, theta, xiyi, fuel_depth, dt, tf); %--> changed this as well
    Jacobian= admJacFor(g_xy_fronts{:,1},g_xy_fronts{:,2});
end

end
