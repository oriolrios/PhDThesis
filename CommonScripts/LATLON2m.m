function LATLON2m()
% changes LAT LON axes of CURRENT FIGURE TO meters
%
% ORios 2016
a=gca;
xtick_num=a.XTick;
ytick_num=a.YTick;

xtick_numNWM=xtick_num-xtick_num(1);
ytick_numNWM=ytick_num-ytick_num(1);
% 
xlim([xtick_num(1)-(xtick_num(2)-xtick_num(1)) xtick_num(end)+(xtick_num(2)-xtick_num(1))])
ylim([ytick_num(1)-(ytick_num(2)-ytick_num(1)) ytick_num(end)+(ytick_num(2)-ytick_num(1))])

% xlim([xtick_num(1)-(xtick_num(2)-xtick_num(1)) xtick_num(end)])
% ylim([ytick_num(1)-(ytick_num(2)-ytick_num(1)) ytick_num(end)])

%ReCALC
xtick_num=a.XTick;
ytick_num=a.YTick;
xtick_numNWM=xtick_num-xtick_num(1);
ytick_numNWM=ytick_num-ytick_num(1);

a.XTickLabel=sprintfc('%d',xtick_numNWM);
a.YTickLabel=sprintfc('%d',ytick_numNWM);

xlabel('[m]')
ylabel('[m]')

% a.XTickLabel=sprintfc('%d',0:30:300)'
% xtick_num
% 
% xtick_lab_num=nan(length(xtick_lab),1);
% ytick_lab_num=nan(length(ytick_lab),1);
% for i=1:length(xtick_lab)
%     xtick_lab_num(i)=str2double(xtick_lab(i));
% end
% 
% for i=1:length(ytick_lab)
%     ytick_lab_num(i)=str2double(ytick_lab(i));
% end

