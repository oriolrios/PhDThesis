% SmartQFIRE
% Uses Matlab optimization FMINUNC i FMINCON algorithms to run the
% assimilation
clear
%% INPUTS smartQFIRE
forecast=1; 
% **************** %
OptIndexCh='SDI';   % 'CostArea','SDI','Sorensen','Jaccard','SDI_a','Sorensen_a','Jaccard_a';
% ---------------- %
inv_char={'Imwf[s/m]','I_Wo[]','U [m/s]','I_{\theta}[deg]'};
% ---------------- %
weight            = 'idty';     % idty->W=II lin->linear (no normalized)  linN->linear norm  exp->exp
% 'idty','lin','linN','exp'
% ---------------- %
%light_plots      = 1;    % Cada quantes iteracions dibuixar
% ---------------- %
%max_iteration    = 6;    % Maxim number of iteration to perform
% ---------------- %
tObsIni           = 13;%13;
% ---------------- %
numTobs           = 8;%3 % sum one!!
% ---------------- %
IsocStep          = 1; %15 % number of isochrones to jump! (defineix també el time step real DT=isochrone_step*dt_isochrone
%                       % Defineix també el time step pel forecast. Necessari per comparar
% ************ %
SaveOut=1 ;% 0-> not save 1-> save
% **************** %
plot_GoogleEarth = 0; % 0
% **************** %
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
plotName='PLOT A';
load('dades_plot_A.mat')
%I=[2/1.3526,0.02,4,1]; %Imf=Imfw/Phi_w_i
I=[2/1.3526,0.01,10,0.1]; %Imf=Imfw/Phi_w_i
%I=[0.02,0.4,0.15,1,7216,10*pi/180]; %Imf=Imfw/Phi_w_i
fuel=fuelA;
slope=slopeA;
aspect=aspectA;
ForeTime = 0:180:900;
% PLOT AS2E
%  plot='PLOT AS2E';
%  load('dades_plot_AS2E.mat')
%  I=[1/0.38,0.02,2,70*pi/180];
 
% % % MONTSENY SINTETIC
% % plotName='Montseny Synth';
% %  load('Montseny_INI.mat', 'fuelMO', 'aspectMO','slopeMO')
% %      fuel = fuelMO; 
% %      aspect = aspectMO;
% %      slope = slopeMO; 
% %  load('xy_fronts_MO.mat')
% %     isochrons=xy_fronts;
% % I=[0.005,0.03,5,0]; %REAL
% % % I=[0.05/0.38,0.02,2,70*pi/180];
%% TIMES
AllIsocAbsTime=round(isochrons.time-isochrons.time(1))'; % rounded to [SEC]
indAdTime=tObsIni:IsocStep:tObsIni+numTobs*IsocStep-1;   % asimilation times

if indAdTime(end)>size(AllIsocAbsTime,1)
    error('not enought observed isocrhones %d (%d available)',indAdTime(end),size(AllIsocAbsTime,1))
end

absAdTime=AllIsocAbsTime(indAdTime);
realAdTime= absAdTime-absAdTime(1);
xy_real=isochrons.xy(indAdTime);


%% OPTIMIZATION
% Unconstraiuned optimization
%[x, fval, Invariants, CostVal] = optSmartQFIRE(xy_real,fuelA,aspectA,slopeA,weight,realAdTime,I);

% Constrained Optimization
[x, fval, Invariants, CostVal] = ConstOptSmartQFIRE(xy_real,fuel,aspect,slope,weight,realAdTime,I,OptIndexCh,fId);


fclose(fId);
%% Recomput initial fronts
[xy_model_ini_guess]=expansion_f_s_simple(I(1),I(2),I(3),I(4),xy_real{1},fuel,aspect,slope,realAdTime);
[xy_model]=expansion_f_s_simple(x(1),x(2),x(3),x(4),xy_real{1},fuel,aspect,slope,realAdTime);

%% Info string
nItem=length(I);
str='%.3f ';
strAll=repmat(str,[1,nItem]);
% Initial info
info_str_n{1}=sprintf(...
    [
    'INFO: %s \nDA ADfronts(step): %d(%d) [sec] //\n'...
    'Igues:[',strAll(1:end-1),'] // \n'...
    'T_{ini}= %d, T_{step}=%d, T_{ad}=%d//'
    ],plotName,numTobs,mean(diff(realAdTime)), I(1,:),tObsIni,IsocStep,numTobs);

info_str_n{2}=sprintf(...
    [
    'INFO: %s \nDA ADfronts(step): %d(%d) [sec] - ConvIter: '...
    '%d // \n Igues:[',strAll(1:end-1),'] // \n I_{DA}:[',strAll(1:end-1),'] //'...
    '\n T_{ini}= %d, T_{step}=%d, T_{ad}=%d, - W=%s //'
    ], plotName, numTobs,mean(diff(realAdTime)),size(Invariants,1), I(1,:), Invariants(end,:),tObsIni,IsocStep,numTobs,weight);


%% Plot Grpahs
PlotAssimilationFigures(Invariants,CostVal,xy_real,xy_model,xy_model_ini_guess,inv_char,info_str_n)
PlotIndexConvergence(filename)

%% Isochrone comparation 
[f_cost, SDI_AD, Sorensen_AD, Jaccard_AD]=real_model_AREA_cost(xy_real,xy_model.xy(:,end),'plot', sprintf('Assimilated Fronts.Optimizing %s Index',OptIndexCh));

%% If you want google earth
if plot_GoogleEarth ==1    
    % IMPORTANT! 31,'N' is the UTM zone and hemisphere
    fronts2googlearth('fronts_assimilated', xy_model,31,'N','b')
    fronts2googlearth('fronts_observed', xy_real,31,'N','r')
    fronts2googlearth('fronts_1st_Guess', xy_model_ini_guess,31,'N','g')
end

%% FORECAST 
if forecast==1 
    [xy_forecast]=expansion_f_s_simple(x(1),x(2),x(3),x(4),xy_real{end},fuel,aspect,slope,ForeTime);
    
    if plot_GoogleEarth ==1    
     fronts2googlearth(sprintf('fronts_forecast_%s_%s_%g',OptIndexCh,weight,ForeTime(end)), xy_forecast,31,'N','m')
    end
end
    
