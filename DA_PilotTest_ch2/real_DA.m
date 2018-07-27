%#########################################################################%
%       INVERSE METHOD using INVARIANTS and AUTOMATIC DIFFERENTIATED CODE %
%               Oriol Rios 2014                                           %
%                                                    oriol.rios@upc.edu   %
%#########################################################################%
% Using data from AA plot NGARKAT 2008
% need ADiMAt functions at  /usr/adimat-0.5.7-3269-GNU_Linux-i686/share
% Input observation in a file XY_fire_FM.dat NO
% Some parameters (Dd, S...) are both AD_FWD_model and Fwd_model_Inv...
% treat them better
% Create syntehtic data with the proper time length and displays the Itrue
%------------------------------------------------------------------------
% aixÛ ho poso pq ho s√© peo ho he de pensar.......
    %forward_model_syntetic(tf);    %generates the file 'synthetic_data.dat'
%% INPUTS

clear all;

% **************** %
inv_char={'Imwf[s/m]','U [m/s]','I_{\theta}', 'Imf [m/min]', 'I_{\theta} [deg]'};
% ---------------- %
weight             = 1;    % 1= Weights on, 0->W=II        
% ---------------- %
light_plots        = 2;    % Cada quantes iteracions dibuixar
% ---------------- %
max_iteration      = 10;   % Maxim number of iteration to perform
% ---------------- %
t_obs_ini          = 13;
% ---------------- %
num_t_obs          = 10;
% ---------------- %      SELECT CONVERGENCE CRITERIA(line 95)
ConvCriteria       = 0.2;   % sum of percentual diference %0.03 hi havia
% ---------------- %
Invariants(1,:)=[9,1,10]; % [Imwf,U,theta] %that's the initial guess
% **************** %
% LOAD --------------------------------------------------------------%
         load('fuel_depth_map.mat','fuel_depth') % loads fuel map and georeferencing!
         load('isochrons_mod.mat', 'isochrons_mod')
         xy_real=isochrons_mod.xy(t_obs_ini:(t_obs_ini+num_t_obs-1));
         xy_real_forecast=isochrons_mod.xy((t_obs_ini+num_t_obs+1):end);
         %xy_real={isochrons_mod.xy{[12 13 14 17]}}';
% LOAD --------------------------------------------------------------%
% At_m=diff(cell2mat(isochrons_mod.timesec));
% At(1)=mean(At_m);
% At(2)=std(At_m);
forecast_time=size(isochrons_mod.xy,1)-(t_obs_ini+num_t_obs); %number of fronts for forecast check
if forecast_time<=0
    disp('No hi ha fronts futurs per a comparar Forcasted vs Observed')
end

%% Plotting --------- plotting observed perimeter ----------
cc=hsv(12); %coloured plots
cc(5:6,:)=[]; %elimiante two similar colors
ccm=cc(1:2:end,:); % better colour
% -------------------------------------------------------

%% TLM and gradient optimization 
xy_model=cell(num_t_obs,max_iteration);
convergence=nan(1,max_iteration); %Iterations
Cost_total=nan(1,max_iteration);
% Weights for the cost function
    
for ii=1:1:max_iteration % Iteration covergence loop maximum 12 iterations!!    
    %[xy_model, Jacobian]=JacAD_expansion_f_scalar(Imfw,U,theta,xiyi,fuel_depth);
    [xy_model(:,ii), Jacobian]=JacAD_expansion_f_2class(Invariants(ii,1), Invariants(ii,2), Invariants(ii,3),xy_real{1,1},fuel_depth, 1, num_t_obs);
    [Cost_total(ii), xy_diff,nan_logic]=real_model_cost(xy_real,xy_model(:,ii));% D'AQUI S?HA DE TREURE el VECTOR (OBS-MOD)
    % [J ~] = admDiffFor(@expansion_f_simple,Imfw,U,theta,xiyi,fuel_depth);----> AIX÷ NO VA, FALTA MEMÚRIA
    
    % ------ Delete jacobian's elements that are doubled (first and last node of each front repeated)---------%   
    del_rep=0;
    for k=1:length(xy_model(:,ii))
        del_rep=[del_rep length(xy_model{k,ii})+del_rep(k)];
    end
    del_rep(1)=[];
    del_rep=[del_rep del_rep+length(Jacobian)/2];
    Jacobian(del_rep,:)=[];
    %---------------------------------------------------------------------------------------------------------%
    % Delate NaN's from interections 
    ind=cell2mat(nan_logic');
    ind=[ind; ind];
    Jacobian=Jacobian(ind,:); % Get only the points that have been used to compute distance and b1 vector
  

    dummy_diff=cell2mat(xy_diff);
    diff=dummy_diff(:,1:2)-dummy_diff(:,3:4);
    
    %% term B= Ht*(obs-mod)
    b1=diff(:); %x values, then y values
    
    if weight==1 %Weight function with progressive increasing weight in each front
        w_el_1=cellfun('length',xy_diff);
        w_el_2=[];
        for jj=1:size(w_el_1,1)
% % % %         % PROVAAA -----------------    
% % % %             if jj<(size(w_el_1,1)) %%%%%
% % % %                 KK=0;            %%%%%
% % % %             else
% % % %                 KK=2;            %%%%%
% % % %             end                  %%%%%
% % % %         % PROVAAA -----------------
% % % %         w_el_2=[w_el_2, KK*ones(1,w_el_1(jj))];
            w_el_2=[w_el_2, jj*ones(1,w_el_1(jj))];
           
        end
        
        w_elements=[w_el_2 w_el_2];
        sum_trace=sum(w_elements*2);
        normalize=sum_trace;
        W= diag(w_elements/4);
        %W= diag(w_elements/num_t_obs/2);
        %W=eye(size(Jacobian,1));
       
        %let's find term A= H^T*H
        ad_A= Jacobian'*W*Jacobian;
        ad_B=Jacobian'*W*b1;
        
    else % Without weights
        %let's find term A= H^T*H
        ad_A= Jacobian'*Jacobian;
        % term B= Ht*(obs-mod)
        ad_B=Jacobian'*b1;
     end
    
    ad_B=Jacobian'*b1;
% solve lineal system 
    ad_p=linsolve(ad_A, ad_B);
 
    Invariants(ii+1,:)=Invariants(ii,:)+ad_p'; %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ CANVIO AIX√ñ PER NO SALTAR DE M√?NIM
%% REPASSAR IF NEGATIU
% % % % %     if any (Invariants(ii+1,:)<=0) % If any invariant is smaller than 0 !!!!
% % % % %         REPASSAR AIX÷OOO
% % % % %         disp('ERROR: does not converge (see last I above)!!!!')
% % % % %         I=Invariants(ii+1,:)
% % % % %         $$$ CORRECTION WHEN BREAKS BECAUSE NEGATIVE I
% % % % %         
% % % % %             [r,c] = find(I(end,:) < 0);
% % % % %             if length(c)>=2;
% % % % %                    disp('ERROR: two negative invariants')
% % % % %                 else
% % % % %                 I(c)=Invariants(2,c); % EL TORNO A ENVIAR A Iguess PRINCIPI???
% % % % %             end
% % % % %     
% % % % %     end
    
    % If invariants are corrected we don't plot the iteration
% % %     if flag_plot==1;
% % %         for j=2:length(xfm(2,:))
% % %             plot (x(:,j), y(:,j), ':r', 'LineWidth',2');
% % %             hplot(ii+2)=plot (xfm(:,j), yfm(:,j), '--', 'color',cc(ii+1,:));
% % %         end
% % %     end
% % %  Invariants(ii+2,:)=I;
%%   
if isnan(Invariants(ii,:))
    Invariants
    ii
    disp('Invariants are NaN')
    break
end
    convergence(ii)=sum(abs((Invariants(ii+1,:)-Invariants(ii,:))./Invariants(ii,:)),2); % parameters convergence (percentage diference!!)
    if convergence(ii)<ConvCriteria
    %if JJcost(ii+1)<JJcost_conv
        %disp('\n Required convergence is reached!!!! \n')
        text=sprintf('\n Required convergence has been reached with %d iterations!!!\n',ii);
        disp(text)
        break %terminates cinvergence loop
    end
end


%% PLOTTING
figure('Name', 'Fronts')
hold on
Hax1=gca;
set(Hax1,'DataAspectRatio',[1 1 1]);
hplot=0;
%hold on
kk=1;
for j=1:light_plots:ii %number of converging loops
    for i=1:size(xy_model,1)
        hp=plot (xy_model{i,j}(:,1), xy_model{i,j}(:,2), ':', 'Color',cc(j,:), 'linewidth',2);
        
        %plot (x(:,j), y(:,j), ':r', 'LineWidth',2');
        %hplot(length(hplot)+1)=plot (xy_model{j}(:,1), xy_model{j}(:,2), ':^', 'MarkerFaceColor',cc(ii+1,:));
    end
    hplot(length(hplot)+1)=hp;
end
char={'observed','1st guess','iteration 1','iteration 2','iteration 3', 'iteration 4', 'iteration 5', 'Iteration 6', 'Iteration 7', 'Iteration 8', 'Iteration 9', 'Iteration 10', 'Iteration 11', 'Iteration 12'};

for i=1:num_t_obs
    hplot(1)=plot(xy_real{i,1}(:,1), xy_real{i,1}(:,2),'-k', 'linewidth',2);
    hold on
end
xlabel('distance [m]')
ylabel('distance [m]')
legend(hplot, char([1 2:light_plots:ii]))
%ACABAR AIX÷!!!
nItem=size(Invariants(1,:));
str='%.3f ';
strAll=repmat(str,[1,nItem]);

% aa=sprintf([strAll(1:end-1),'\n'],Invariants(2:end,:));
% Plot_info = [sprintf('INFO: \n I_guess [%s]',inv_char(1:nItem)),sprintf('%d ',Invariants(1,:)),sprintf('] \n I_iteration ['),sprintf([strAll(1:end-1),'\n'],Invariants(2:end,:))];
% Plot_info_2=num2str(Invariants(1:end,:));

info_str=sprintf(['INFO: \n DA window/period: %d/%d (min) \n Iterations: %d \n Iguess:[',strAll(1:end-1),']\n I_{DA}:[',strAll(1:end-1),']'], num_t_obs,1,ii, Invariants(1,:), Invariants(end,:));
info_str_n=sprintf(['INFO: DA window/period: %d/%d (min) // Iterations: %d // Iguess:[',strAll(1:end-1),']// I_{DA}:[',strAll(1:end-1),']'], num_t_obs,1,ii, Invariants(1,:), Invariants(end,:));
%annotation('textbox', [0.05,0.05,0.1,0.1],'String', info_str);
title(info_str_n)
%% CONVERGENCE PLOT
set(0,'defaultlinelinewidth',2)        
figure('Name', 'Convergence')
subplot(1,2,1)
    plot(Cost_total,'-X')
    xlabel('Iteration')
    ylabel('averaged cost sum')
    set(gca,'xTick',[2:1:ii])
    title('Cost Value reduction')
% Plot invariants individual convergence
subplot(1,2,2)
    hold on
    for i=1:1:length(Invariants(1,:))
        hpp1(i)=plot((Invariants(1:end-1,i)-Invariants(end,i))/Invariants(end,i)*100, '-x', 'color',cc(i,:),'linewidth',2');
    end
    title('Invariants absolut individual convergence' ) 
    set(gca,'XTick',[1:1:5])
    char1={'True Invariant Value', '1st guess', ' 1',' 2',' 3', ' 4', ' 5', ' 6', ' 7', ' 8',' 9', ' 10', ' 11', ' 12'};
    set(gca,'xTick',[2:1:length(convergence)])
    ylabel('Invariant Value [%]')
    xlabel('Iteration')
    legend (hpp1, inv_char(1:i))
    suplabel(info_str_n ,'x'); %plot info
%annotation('textbox', [0.25,0.01,0.1,0.1],'String', info_str_n);
figure('Name','Forecasted vs Observed')
hold on

[xy_forecast_xiyi]=expansion_f(Invariants(ii,1),Invariants(ii,2),Invariants(ii,3),xy_real{1,1},fuel_depth, 1, forecast_time+num_t_obs);
[xy_forecast_xfyf]=expansion_f(Invariants(ii,1),Invariants(ii,2),Invariants(ii,3),xy_real{end,1},fuel_depth, 1, forecast_time);
for i=1:size(xy_real_forecast,1) %number of converging loops
        hp_forecast(1)=plot (xy_real_forecast{i,1}(:,1), xy_real_forecast{i,1}(:,2), '-k', 'linewidth',2);
        hp_forecast(2)=plot (xy_forecast_xiyi{num_t_obs+i,1}(:,1), xy_forecast_xiyi{num_t_obs+i,1}(:,2), '--g', 'linewidth',2);
        hp_forecast(3)=plot (xy_forecast_xfyf{i,1}(:,1), xy_forecast_xfyf{i,1}(:,2), '--m', 'linewidth',2);
end
        hp_forecast(4)=plot(xy_real{end,1}(:,1),xy_real{end,1}(:,2),'-r');
legend(hp_forecast,'Observed','Forecasted xiyi','Forecasted xfyf','xfyf front')
title('Forecasted vs Observed')
  
%% EXTRA PLOTTING  
% % % % %   char={'observed','1st guess','iteration 1','iteration 2','iteration 3', 'iteration 4', 'iteration 5', 'Iteration 6', 'Iteration 7', 'Iteration 8', 'Iteration 9', 'Iteration 10', 'Iteration 11', 'Iteration 12'};
% % % % %   
% % % % %   inv_char={'Iw1 [s/m]','Iw2 [-]', 'Imf [m/min]', 'I_{\theta} [ras]'};
% % % % %   %legend(hplot, char(1:(ii+2)))
% % % % %   %legend(hplot, leg_info)
% % % % %   if flag_plot==1; 
% % % % %       legend(hplot, char(1:(ii+2))); 
% % % % %   else
% % % % %       leg_info=['observed','1st guess', char(ii+2)];
% % % % %       legend(hplot, leg_info); 
% % % % %   end
% % % % %   % title('ad_optimization')
% % % % %   xlabel('xdistance [m]')
% % % % %   ylabel('ydistance [m]')
% % % % %             info_str=sprintf('INFO: Assimilation time/period: %d/%d (min) // Itrue:[%0.2f %0.2f %0.2f %0.2f] // Iguess:[%0.2f %0.2f %0.2f %0.2f] ', Ad_win,Dt, Itrue, Invariants(2,:));
% % % % %   suplabel(info_str ,'x'); %plot info
% % % % % %% plot parameters convergenceplot(Itrue) 
% % % % % 
% % % % % set(0,'defaultlinelinewidth',2)
% % % % % figure
% % % % % subplot(2,2,[1 3])
% % % % % hpp1(1)=plot (Itrue, '-*k');
% % % % %     hold on
% % % % %     for i=2:1:length(Invariants(:,1))
% % % % %         hpp1(i)=plot(Invariants(i,:), '-s', 'color',cc(i-1,:));
% % % % %     end
% % % % %     title('Invariants absolut convergence' ) 
% % % % %     set(gca,'XTick',[1:1:5])
% % % % %     set(gca,'XTickLabel', inv_char)
% % % % %     ylabel('Invariant Value')
% % % % %     xlabel('Invariant')
% % % % %     char1={'True Invariant Value', '1st guess', ' 1',' 2',' 3', ' 4', ' 5', ' 6', ' 7', ' 8',' 9', ' 10', ' 11', ' 12'};
% % % % %     legend (hpp1, char1(1:1:length(hpp1)))
% % % % %     grid on
% % % % %     
% % % % % subplot(2,2,2)
% % % % %     plot(convergence, '-x');
% % % % %     grid on
% % % % %     title('Invariants partial Convergence: (I(i)-I(i-1))/I(i-1)')
% % % % %     set(gca,'XTick',[1:1:length(convergence)])  
% % % % %     set(gca,'XTickLabel',char(3:1:(length(convergence))+3))
% % % % %     xlabel('# iteration')
% % % % %     ylabel('sum of % difference')
% % % % % 
% % % % % %% Plot JJcost fucntion
% % % % % subplot(2,2,4)
% % % % % %figure
% % % % % plot(JJcost ,'-k*')
% % % % %     grid on
% % % % %     title('Cost funtion value J^2')
% % % % %     ylabel('Cost Function value [m^2]')
% % % % %     set(gca,'XTick',[1:1:length(JJcost)])  
% % % % %     set(gca,'XTickLabel',char(2:1:(length(JJcost))+2))
% % % % %     xlabel('# iteration')
% % % % % 
% % % % % % to mautomatix mazimize the subplot graph 
% % % % % maximize % es una funci√≥ que m'he guardat
% % % % % suplabel(info_str ,'x'); %plot info
% % % % % 
% % % % % figure
% % % % % subplot (2,2,[1 3])
% % % % %     hold on
% % % % %     for kk=2:1:(length(Invariants(:,1)))
% % % % %         % % 100 difference
% % % % %         IvsTrue(kk-1,:)=(Invariants(kk,:)-Invariants(1,:))./Invariants(1,:)*100; % podries dividir pel valor de cada I i aix√≠ tindries la convergencia relativa!!
% % % % %         h_con(kk-1)=plot(IvsTrue(kk-1,:)', '-x', 'color',cc(kk-1,:));
% % % % %     end
% % % % %     %the bar plot will be---->  bar(IvsTrue', 'grouped')
% % % % %         legend(h_con, char(2:(kk)))
% % % % %         title('Individual invariants convergence to true vector')
% % % % %         set(gca,'XTick', [1:1:5])
% % % % %         set(gca,'XTickLabel', inv_char)
% % % % %         ylabel('Difference I(iter)-Itrue')
% % % % %         xlabel('Invariant')
% % % % %         grid on
% % % % % 
% % % % % subplot(2,2,2)
% % % % % 
% % % % %   abs_err=sum(abs(IvsTrue),2)';Invariants(:,1)
% % % % %     plot(abs_err,'-x')
% % % % %     title('Total convergence to True Vector')
% % % % %     set(gca,'XTick',[1:1:length(abs_err)])
% % % % %     set(gca,'XTickLabel',char(2:1:(length(abs_err))+2))
% % % % %     xlabel('# iteration')
% % % % %     ylabel('sum of absulute difference [%]')
% % % % %     grid on    
% % % % %     
% % % % %   maximize %maximize funciton 
% % % % %   suplabel(info_str ,'x'); %plot info
% % % % % 
% % % % % subplot(2,2,4)
% % % % %     xvec=[1:1:(ii+1)];
% % % % %     plot(xvec, IvsTrue(:,1)','-x',xvec, IvsTrue(:,2)','-x',xvec, IvsTrue(:,3)','-x',xvec, IvsTrue(:,4)','-x')
% % % % %     %plot(xvec, 100*IvsTrue(:,1)'/Itrue(1),'-x',xvec, 100*IvsTrue(:,2)'/Itrue(2),'-x',xvec, 100*IvsTrue(:,3)'/Itrue(3),'-x',xvec, 100*IvsTrue(:,4)'/Itrue(4),'-x')
% % % % %     grid on
% % % % %     title('Individual Convergence to true value. Normalized with True Value')
% % % % %     legend(inv_char, 'Orientation', 'horizontal')
% % % % %     set(gca,'XTick',[1:1:ii+1])  
% % % % %     set(gca,'XTickLabel',char(2:1:(ii+3)))
% % % % %     xlabel('# iteration')
% % % % %     ylabel('off-set. (I-I_{true})/I_{true} [%]')
% % % % % 
% % % % % %% PLOT TO THESIS
% % % % % figure         
% % % % % subplot(1,2,1)
% % % % % plot(JJcost ,'-k*')
% % % % %     grid on
% % % % %     title('Cost funtion value J^2')
% % % % %     ylabel('Cost Function value [m^2]')
% % % % %     set(gca,'XTick',[1:1:length(JJcost)])  
% % % % %     set(gca,'XTickLabel',char1(2:1:(length(JJcost))+2))
% % % % %     xlabel('# iteration')
% % % % % 
% % % % % subplot(1,2,2) 
% % % % %     xvec=[1:1:(ii+1)];
% % % % %     plot(xvec, IvsTrue(:,1)','-x',xvec, IvsTrue(:,2)','-x',xvec, IvsTrue(:,3)','-x',xvec, IvsTrue(:,4)','-x')
% % % % %     %plot(xvec, 100*IvsTrue(:,1)'/Itrue(1),'-x',xvec, 100*IvsTrue(:,2)'/Itrue(2),'-x',xvec, 100*IvsTrue(:,3)'/Itrue(3),'-x',xvec, 100*IvsTrue(:,4)'/Itrue(4),'-x')
% % % % %     grid on
% % % % %     title('Individual Convergence to true value. Normalized with True Value')
% % % % %     legend(inv_char, 'Orientation', 'horizontal')
% % % % %     set(gca,'XTick',[1:1:ii+1])  
% % % % %     set(gca,'XTickLabel',char1(2:1:(ii+3)))
% % % % %     xlabel('# iteration')
% % % % %     ylabel('Difference [%]')
% % % % %         
% % % % %   maximize %maximize funciton 
% % % % %   suplabel(info_str ,'x'); %plot info
% % % % %   
% % % % % set(0,'defaultlinelinewidth',1)
