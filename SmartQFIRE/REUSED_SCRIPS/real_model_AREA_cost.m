function [cost_area,SDI,Sorensen,Jaccard,SDI_a,Sorensen_a,Jaccard_a]=real_model_AREA_cost(xy_real,xy_model,plot_in,title_str_in, varargin)
% Calculates error by AREA and creates multiplot if "plot" is input
%   INPUTS
%   xy_real             real fronts cell array [N,1] (n, 2 X N matrix
%   xy_model            model fronts cell array
%   'plot' (opt)        activates multiplotting
%   title_str_in (opt)  string with the title of the plot!
%   varargin            Isochrons times for the plots

%
%   OUTPUTS
%   cost_area           area difference for each front [1x num fronts]
%   er100_fronts (opt)  activates percentual error count
%
% History:
% $06/06/16: Wierd logic  pilotted by PLOT??
% $06/06/16: Com està definit pot ser que peti al calcular els index _a
%
% ************ %
index_new_figure=0;    % 1= PLOT, 0= NO plot (si vols una fig independent amb els index)
% ************ %
if nargin>4
    iso_dt=varargin{1};
    iso_time=1;
else
    iso_time=0;
end

if nargin>3
    title_str=title_str_in;
else
    title_str='Fronts Area Error';
end

if nargin>2
    if strcmp(plot_in,'plot')
        plotting=1;
    else
        plotting=0;
    end
else
    plotting=0;
end


if nargout>1 %Això és per quan s'utilitza per assimilar o després!
    calc_per_error=1;
    SDI       = NaN(length(xy_model),1);
    Sorensen   = NaN(length(xy_model),1);
    Jaccard   = NaN(length(xy_model),1);
    SDI_a     = NaN(length(xy_model),1);
    Sorensen_a = NaN(length(xy_model),1);
    Jaccard_a = NaN(length(xy_model),1);
else
    calc_per_error=0;
end

cost_area=NaN(length(xy_model),1);
%initial_area=polyarea(xy_model{1,1}(:,1),xy_model{1,1}(:,2))
initial_area=polyarea(xy_real{1,1}(:,1),xy_real{1,1}(:,2));

if plotting==1
    subplot_c=ceil(sqrt(length(xy_real)));
    subplot_r=ceil(length(xy_real)/subplot_c)+1;
    hF=figure('Name',title_str);
    set(hF,'units','normalized','outerposition',[0 0 1 1])
    hold on
    hAX=nan(1,length(xy_model));
    for i=length(xy_model):-1:1 %comencem des del final per prendre els xtics
        hAX(i)=subplot(subplot_c,subplot_r,i);
        set(hAX(i),'DataAspectRatio',[1 1 1]);
        hold(hAX(i),'on')
        box on
        %ylabel('Distance [m]');
        %xlabel('Distance [m]');
        ylabel('[m]');
        xlabel('[m]');
        if iso_time==1 % Forecast titles
            title(sprintf('+%d (sec)',iso_dt(i)))
            %title('Initial')
        elseif i~=1 % Assimilation Titles
            %title(sprintf('Isochrone=%d/%d',i-1,length(xy_model)))
            title(sprintf('Isochrone=%d/%d',i-1,length(xy_model)-1))
        else %Initial assimilation titles
            %title(sprintf('Isochrone=%d/%d (xfyf)',i-1,length(xy_model)))
            title('Initial')
        end
        %
        [cost_area(i,1),SDI(i,1), Sorensen(i,1), Jaccard(i,1),SDI_a(i,1), Sorensen_a(i,1), Jaccard_a(i,1)]=area_between_curves(xy_real{i,1},xy_model{i,1},hAX(i),initial_area);
        
        % corregir el cas inicial (dóna 0/0)-> i és 0! (redefined)
        if i==1
            SDI(1,1) =0;
            SDI_a(1,1)=0;
            Sorensen(1,1)=0;
            Sorensen_a(1,1)=0;
            Jaccard(1,1)=0;
            Jaccard_a(1,1)=0;            
            
        end
        
        % plot initial FRONT (changes for assimilation and forecast)
        plot(xy_real{1,1}(:,1),xy_real{1,1}(:,2),'--g')
        
        %         if calc_per_error==1 % caclulates percentual error
        %             real_area=polyarea(xy_real{i,1}(:,1),xy_real{i,1}(:,2));
        %            % My_SDI(i,1)=cost_area(i,1)/real_area*100; rejected paper
        %             SDI(i,1)=cost_area(i,1)/real_area*100;
        %         end
        
        if i==length(xy_model) %get axis dimensions
            xlim=get(hAX(i),'Xlim');
            ylim=get(hAX(i),'Ylim');
        else                   %apply axis dimension
            axis([xlim ylim])
            %set(ah,'Xlim')
        end
    end
    %figure('Name', 'Area error evolution')
    subplot(subplot_c,subplot_r,subplot_c*subplot_r-subplot_c+1:subplot_c*subplot_r);
    if calc_per_error==1 % PENSAR BÉ PERO POTSER NO CAL. NO??
        x_data=1:length(cost_area(:,1));
        % NEW SUBPLOT
        hold on
        plot(x_data,SDI','g-')
        plot(x_data,Sorensen','r-')
        plot(x_data,Jaccard','b-')
        
        % substracting area
        plot(x_data,SDI_a','g--')
        plot(x_data,Sorensen_a','r--')
        plot(x_data,Jaccard_a','b--')
        
        legend('SDI'' (1-SDI)','Sorensen','Jaccard')
        %set(gca,'Ylim',[0 1])
        ylabel('Similarity Index Value')
        xlabel('Front')
        grid on
        set(gca,'XLim',[1 x_data(end)])
        set(gca,'XTick',[1:1:x_data(end)])
        set(gca,'XTickLabel',sprintf('%.0f\n',0:(x_data(end)-1)))
        
        %% new figure
        if index_new_figure==1
            % NEW SUBPLOT
            figure
            hold on
            plot(x_data,SDI','g-')
            plot(x_data,Sorensen','r-')
            plot(x_data,Jaccard','b-')
            
            % substracting area
            plot(x_data,SDI_a','g--')
            plot(x_data,Sorensen_a','r--')
            plot(x_data,Jaccard_a','b--')
            
            legend('SDI'' (1-SDI)','Sorensen','Jaccard')
            set(gca,'Ylim',[0 1])
            ylabel('Similarity Index Value')
            xlabel('Front')
            grid on
            set(gca,'XTick',[1:1:x_data(end)])
            set(gca,'XTickLabel',sprintf('%.0f\n',0:(x_data(end)-1)))
        end
        
    else
        bar(cost_area(:,1))
        xlabel('Isochrone')
        ylabel('m^2')
    end
    title('Similarity Indices')
    %suplabel(title_str  ,'t'); % doesn't work. Eliminates 2n Y axis!!
    % %     % és un WORK AROUND
    % %     uicontrol('Style', 'text', 'String', title_str, ...
    % % 'HorizontalAlignment', 'center', 'Units', 'normalized', ...
    % % 'Position', [0 .9 1 .05], 'BackgroundColor', [.8 .8 .8]);
else % if no need to plot! PER l'ASSIMILACIÓ NO PLOTEM RES
    %calculate 1st real front area
    P.x=xy_real{1,1}(:,1);
    P.y=xy_real{1,1}(:,2);
    initial_area=polyarea(P.x,P.y);
    
    for t=1:length(xy_model)
        [cost_area(t,1),SDI(t,1),Sorensen(t,1), Jaccard(t,1),SDI_a(t,1),Sorensen_a(t,1), Jaccard_a(t,1)]=area_between_curves(xy_real{t,1},xy_model{t,1},'NoPlot',initial_area);
        %         if calc_per_error==1 % caclulates percentual error
        %             %real_area=polyarea(xy_real{t,1}(:,1),xy_real{t,1}(:,2));
        %             %SDI(t,1)=cost_area(t,1)/real_area*100;
        %             SDI=area_XOR/real_area;
        %         end
    end
end
end



