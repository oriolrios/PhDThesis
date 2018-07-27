% Script to run SmartQFIRE_func optimizing all the invariants
%
%
%% COMPARATIVE SmartQFIRE RUN 
% This program runs a constrained optimization on 7 different index (that
% define 7 different objective functions) and compare their performance
clear
% ----------%
oneFigure=0 ; %NO ESTA FET! To plot all in 1 figure or 0 to plot multiple figures
% ----------%
OptWeightStrng='lin';  %{'idty','lin','linN','expN'};
inv_char={'Imwf[s/m]','I_Wo[]','U [m/s]','I_{\theta}[deg]'};
OptIndexStrng={'CostArea','SDI','Sorensen','Jaccard','SDI_a','Sorensen_a','Jaccard_a'};

Invariants  = nan(length(OptIndexStrng),length(inv_char));
filename    = cell(1,length(OptIndexStrng));
CellI       = cell(1,length(OptIndexStrng));
xy_model    = cell(1,length(OptIndexStrng));
costVal     = nan(1,length(OptIndexStrng));
runTime     = nan(1,length(OptIndexStrng)); 
% figure('Name','Index Exploration') % FALLA MATLAB amb els Axes Handles
h=waitbar(0,'Running Muliple Index Optimization');

for i=1:length(OptIndexStrng)
    waitbar(i/(length(OptIndexStrng)+1),h)
%     ax1(i)=subplot(2,4,i);
%     [I,filename{i}]=SmartQFIRE_func(OptIndexStrng{i},ax1(i));
    tic
    [I,filename{i},xy_model{i},xy_real,xy_ini_guess,costVal(i),info_str]=SmartQFIRE_func(OptIndexStrng{i},OptWeightStrng); % TO avoid ploting index exploration
    runTime(i)=toc;
    CellI{i}=I;
    Invariants(i,:)=I(end,:);
    
end
close(h)
% PlotInvariantsBar(Invariants,inv_char,OptIndexStrng)


switch oneFigure
    case 1
     
    case 0
        %% Invariants Value at each optimization
        figure('Name','BARPLOT')
        for i=1:length(inv_char)
            ax(i)=subplot(2,2,i);
                bar(ax(i),Invariants(:,i))
                title(sprintf('%s',inv_char{i}))
                xlabel('Optimized Index')
                ylabel(sprintf('Value %s',inv_char{i}))
        %         ax(i).XTickLabel =inv_char;
                ax(i).XTickLabel =OptIndexStrng;
                ax(i).XTickLabelRotation = 45;
                grid on
        end
        %% Comparative Performance
        figure('Name','Iterations')
            %aIt=axes;
            aIt1=subplot(1,3,1);
                iter=cellfun('length',CellI);
                bar(iter);
                ylabel('Iteration to converge')
                aIt1.XTickLabel =OptIndexStrng;
                aIt1.XTickLabelRotation = 45;
                grid on
                title('Iterations')
            aIt2=subplot(1,3,2);
                bar(runTime)
                ylabel('Running time [s]')
                aIt2.XTickLabel =OptIndexStrng;
                aIt2.XTickLabelRotation = 45;
                grid on
                title('Running Time')

            aIt3=subplot(1,3,3);
                bar(costVal(2:end)) % we don't plot AreaCost
                ylabel('Optimized Index weighted-sum Value [-]')
                aIt3.XTickLabel =OptIndexStrng(2:end);
                aIt3.XTickLabelRotation = 45;
                grid on
                title('Objective function value')

        %% Optimazed fronts comparison
        figure('Name','All Index Optimized Fronts')   
            Hax=[];
            Hax(1)=plot_fronts_cell(xy_ini_guess.xy,'hold','--g');
            Cmap=parula(length(OptIndexStrng));
            %Cmap=hsv(length(OptIndexStrng));
            %Cmap=lines();
            for i=1:length(OptIndexStrng)
                Hax(i+1)=plot_fronts_cell(xy_model{i}.xy,'hold',Cmap(i,:)); %color?
            end
            Hax(end+1)=plot_fronts_cell(xy_real,'hold','-k');
            %legend(Hax,['Obs','Ini Guess', OptIndexStrng])
            legend(Hax,{'Ini Guess', OptIndexStrng{:},'Obs'})
            title(sprintf('Best assimilated front VS Opt Index. Weight %s',OptWeightStrng))
            annotation('textbox', [0.05,0.05,0.1,0.1],'String', info_str{1});
end
