%% Shadding PLOT
function [F_Mag,F_Dir]=ShaddedMultiPlotSpeed2(ind2cmp,Dir,Mag,Ub,Db,vegetation,save_str,folder)
% This functions...
% 1) calculates the F calibrating factor, 
% 2) displays de ShaddedPlot
% 3) Regresion coefficient Plot
% History:
% $08/07 no struct for Dir & Mag variable (only cell)

original_path=pwd;
if nargin>6
    switch save_str
        case 'save'
            save_flag=1;
            plot_flag=0;
        case 'plot'
            save_flag=0;
            plot_flag=1;
        case 'save&plot'
            save_flag=1;
            plot_flag=1;
        otherwise
            error('MyErr: Invalid Save string')
    end
else %by default plot and DO NOT save
    save_flag=0;
    plot_flag=1;
end

%% Calc downscaling factor
F_Dir=struct;
F_Dir.Ub=Ub;
F_Dir.U2cmp=Ub(ind2cmp);
F_Dir.D2cmp=Db.*ones(1,length(ind2cmp));

F_Mag=struct;
F_Mag.Ub=Ub;
F_Mag.U2cmp=Ub(ind2cmp);
F_Mag.D2cmp=Db.*ones(1,length(ind2cmp));

set(0,'defaultlinelinewidth',0.5)
for i_c=1:length(ind2cmp) %correct
%    for i=1:length(Dir)
    for i=1:length(Mag)
%         KK=Dir{i}./(Dir{ind2cmp(i_c)}.*Ub(ind2cmp(i_c)));
        KK=Dir{i}./(Dir{ind2cmp(i_c)});
        KK(KK==Inf)=NaN; %convert Inf to Nan
        F_Dir.mat{i,i_c}=KK;
        F_Dir.F{i_c}(:,i)=KK(:);
        %F_Dir.mean(i,i_c)=nanmean(KK(:))';
        F_Dir.mean(i,i_c)=nanmedian(KK(:))';
        F_Dir.std(i,i_c)=nanstd(KK(:));
        
%         KK=Mag{i}./(Mag{ind2cmp(i_c)}.*Ub(ind2cmp(i_c)));
        KK=Mag{i}./(Mag{ind2cmp(i_c)});
        KK(KK==Inf)=NaN; %convert Inf to Nan
        F_Mag.mat{i,i_c}=KK;
        F_Mag.F{i_c}(:,i)=KK(:);
        %F_Mag.mean(i,i_c)=nanmean(KK(:));
        F_Mag.mean(i,i_c)=nanmedian(KK(:));
        F_Mag.std(i,i_c)=nanstd(KK(:));
        
    end
end

%% Plotting
if plot_flag==0
    f = figure('visible','off');
else
    f = figure('visible','on');
end

f.Name=sprintf('Downscaling Factor. Dir=%d, fuel=%s',Db,vegetation);

haM=subplot(1,2,1);
    %just for the legend
    plot(repmat(Ub',1,i_c),F_Mag.mean,'LineWidth',2')
    h=legend(arrayfun(@(x) sprintf('U_b=%g [m/s]',x),Ub(ind2cmp),'un',0));
    %PlotShadedError
    PlotShadedError(Ub,F_Mag.mean,F_Mag.std,haM)
    xlabel(haM,'Meso Wind Speed [m/s]');
    ylabel(haM,'Mean Downscaling Factor [-]');
    title('F_U')
    %legend(arrayfun(@(x) sprintf('U_b=%g [m/s]',x),U,'un',0))
    grid(haM,'on')

haD=subplot(1,2,2);
    %just for the legend
    plot(repmat(Ub',1,i_c),F_Dir.mean,'LineWidth',2')
    legend(arrayfun(@(x) sprintf('U_b=%g [m/s]',x),Ub(ind2cmp),'un',0),'Location','northwest')
    %PlotShadedError
    PlotShadedError(Ub,F_Dir.mean,F_Dir.std,haD)
    xlabel(haD,'Meso Wind Speed [m/s]');
    ylabel(haD,'Mean Downscaling Factor [-]');
    title('F_D')
    grid(haD,'on')

    
if save_flag==1
    cd(folder)
    saveas(f,sprintf('Mag_s%d_f%s_median',Db,vegetation),'png')
    saveas(f,sprintf('Mag_s%d_f%s_median',Db,vegetation),'fig')
    %savefig(f,sprintf('Dir-s%d-f%s.fig',U,vegetation))
    cd(original_path)
end
    
set(0,'defaultlinelinewidth',0.5)