% SmartQFIRE
% Uses Matlab optimization algorithms
function [Invariants,filename,xy_model,xy_real,xy_model_ini_guess,fval,info_str_n]=SmartQFIRE_func(OptIndexCh,weight,varargin)
% Què fa???
% Runs SmartQFIRE as function mode
% Comment if want to plot things or gearth
%
% Example:
%  SmartQFIRE_func('SDI')
%  SmartQFIRE_func('SDI_a',axH)
%       {'CostArea','SDI','Sorensen','Jaccard','SDI_a','Sorensen_a','Jaccard_a'};
%
% INPUTS smartQFIRE
%
% OptIndexCh = index to be optimized
% varargin = axH handle to plot index results

%
%% Programm
% **************** %
plot_GoogleEarth = 0; % 0
forecast = 1; 
ForeTime = 0:180:900;
% **************** %
if nargin>2
    axH=varargin{1};
else
    axH=[];
end
% **************** %
%OptIndexCh='Sorensen';   % 'CostArea','SDI','Sorensen','Jaccard','SDI_a','Sorensen_a','Jaccard_a';
% --------------------- %
inv_char={'Imwf[s/m]','I_Wo[]','U [m/s]','I_{\theta}[deg]'};
% --------------------- %
% weight            = 'idty';     % idty->W=II lin->linear (no normalized)  linN->linear norm  exp->exp
% 'idty','lin','linN','exp'
% --------------------- %
%light_plots      = 1;  % Cada quantes iteracions dibuixar
% --------------------- %
%max_iteration    = 6;  % Maxim number of iteration to perform
% --------------------- %
tObsIni           = 8;  %8
% --------------------- %
numTobs           = 4;  %4, 3 % sum one!!
% --------------------- %
IsocStep          = 1;  % 15 % number of isochrones to jump! (defineix també el time step real DT=isochrone_step*dt_isochrone
% --------------------- %    % Defineix també el time step pel forecast. Necessari per comparar
% ************ %
SaveOut=1 ;% 0-> not save 1-> save
% ************ %
%

OptIndexStrng={'CostArea','SDI','Sorensen','Jaccard','SDI_a','Sorensen_a','Jaccard_a'};
if SaveOut==1
    filename=sprintf('cost2optData_%s.csv',OptIndexCh);
    %filename='cost2optData.csv';
    fId=fopen(filename,'w');
    fprintf(fId, '%s(OptIndex), %s, %s, %s, %s, %s, %s, %s\n',OptIndexCh,OptIndexStrng{:});
else
    fId=[];
end
%% PLOT

% PLOT A
% plotName='PLOT A';
% load('dades_plot_A.mat')
% %I=[2/1.3526,0.02,4,1]; %Imf=Imfw/Phi_w_i
% I=[2.5/1.3526,0.02,4,1]; %Imf=Imfw/Phi_w_i
% 
% % PLOT AS2E
% % plotName='PLOT AS2E';
% %  load('dades_plot_AS2E.mat')
% %  I=[1/0.38,0.02,2,50*pi/180];
% % 
% % fuel=fuelA;
% % slope=slopeA;
% % aspect=aspectA;
% 
% MONTSENY SINTETIC
plotName='Montseny Synth';
load('Montseny_INI.mat', 'fuelMO', 'aspectMO','slopeMO')
     fuel = fuelMO;
     aspect = aspectMO;
     slope = slopeMO;
load('xy_fronts_MO.mat')
    isochrons=xy_fronts;
 I=[0.025,0.03,0,0]; %REAL ->(no és el mateix el real?)
%I=[0.005,0.53,0,0]; %TEST
% I=[0.05,0.03,0,0];
% I=[0.05/0.38,0.02,2,70*pi/180];

 

%% TIMES
AllIsocAbsTime=round(isochrons.time-isochrons.time(1))'; % rounded to [SEC]
indAdTime=tObsIni:IsocStep:tObsIni+numTobs*IsocStep-1;   % asimilation times

if indAdTime(end)>size(AllIsocAbsTime,1)
    error('not enought observed isocrhones %d (%d available)',indAdTime(end),size(AllIsocAbsTime,1))
end

absAdTime=AllIsocAbsTime(indAdTime);
realAdTime= absAdTime-absAdTime(1);
xy_real=isochrons.xy(indAdTime);
% 
% % % %%DEBUG INI GUESS
% [xy_model_ini_guess]=expansion_f_s_simple(I(1),I(2),I(3),I(4),xy_real{1,1},fuel,aspect,slope,realAdTime);
% plot_fronts_cell(xy_model_ini_guess.xy)

%% OPTIMIZATION
% Unconstraiuned optimization
%[x, fval, Invariants, CostVal] = optSmartQFIRE(xy_real,fuel,aspect,slope,weight,realAdTime,I);

% Constrained Optimization
[x, fval, Invariants, CostVal] = ConstOptSmartQFIRE(xy_real,fuel,aspect,slope,weight,realAdTime,I,OptIndexCh,fId);


fclose(fId);

%% Info string
nItem=length(I);
str='%.3f ';
strAll=repmat(str,[1,nItem]);
% Initial info
info_str_n{1}=sprintf(...
    [
    'INFO: %s \nDA ADfronts(step): %d(%g) [sec] //\n'...
    'Igues:[',strAll(1:end-1),'] // \n'...
    'T_{ini}= %d, T_{step}=%d, T_{ad}=%d//'
    ],plotName,numTobs,mean(diff(realAdTime)), I(1,:),tObsIni,IsocStep,numTobs);

info_str_n{2}=sprintf(...
    [
    'INFO: %s \nDA ADfronts(step): %d(%g) [sec] - ConvIter: '...
    '%d // \n Igues:[',strAll(1:end-1),'] // \n I_{DA}:[',strAll(1:end-1),'] //'...
    '\n T_{ini}= %d, T_{step}=%d, T_{ad}=%d, - W=%s //'
    ], plotName, numTobs,mean(diff(realAdTime)),size(Invariants,1), I(1,:), Invariants(end,:),tObsIni,IsocStep,numTobs,weight);

%% Recomput initial fronts
[xy_model_ini_guess]=expansion_f_s_simple(I(1),I(2),I(3),I(4),xy_real{1},fuel,aspect,slope,realAdTime);
[xy_model]=expansion_f_s_simple(x(1),x(2),x(3),x(4),xy_real{1},fuel,aspect,slope,realAdTime);

%% Plot Grpahs !! SELECT !!
%     PlotAssimilationFigures(Invariants,CostVal,xy_real,xy_model,xy_model_ini_guess,inv_char,info_str_n)
%     PlotIndexConvergence(filename,axH)

%% Isochrone comparation 
[f_cost, SDI_AD, Sorensen_AD, Jaccard_AD]=real_model_AREA_cost(xy_real,xy_model.xy(:,end),'plot', sprintf('Assimilated Fronts.Optimizing %s Index',OptIndexCh));

if plot_GoogleEarth ==1    
    % IMPORTANT! 31,'N' is the UTM zone and hemisphere
    fronts2googlearth(sprintf('fronts_assimilated_%s_%s',OptIndexCh,weight), xy_model,31,'N','b')
    fronts2googlearth(sprintf('fronts_observed%s_%s',OptIndexCh,weight), xy_real,31,'N','r')
    fronts2googlearth(sprintf('fronts_1st_Guess%s_%s',OptIndexCh,weight), xy_model_ini_guess,31,'N','g')
end

%% FORECAST 
if forecast==1 
    [xy_forecast]=expansion_f_s_simple(x(1),x(2),x(3),x(4),xy_real{end},fuel,aspect,slope,ForeTime);
    
    if plot_GoogleEarth ==1    
     fronts2googlearth(sprintf('fronts_forecast_%s_%s_%g',OptIndexCh,weight,ForeTime(end)), xy_forecast,31,'N','m')
    end
end
