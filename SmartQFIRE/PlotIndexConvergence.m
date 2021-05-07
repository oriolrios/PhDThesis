function PlotIndexConvergence(filename,axH)
%
%
% Example:
%  PlotIndexConvergence('cost2optDadesSDI.csv')
%  PlotIndexConvergence('cost2optDadesSDI.csv',axH)

if nargin>1
    if isempty(axH)
        newfigure=1;
    else
    newfigure=0;
    end
else
    newfigure=1;
end
OptIndexStrng={'CostArea','SDI','Sorensen','Jaccard','SDI_a','Sorensen_a','Jaccard_a'};

Data=csvread(filename,1,0);
OptIndex  =Data(:,1);
CostArea  =Data(:,2);
SDI       =Data(:,3);
Sorensen   =Data(:,4);
Jaccard   =Data(:,5);
SDI_a     =Data(:,6);
Sorensen_a =Data(:,7);
Jaccard_a =Data(:,8);


%% PLOT Sorensen & JACCARD & SDI

if newfigure==1
    hF_S=figure('Name', 'Similarity Index'); 
    axH=axes;
    title(axH,'Similarity indices')
end
hold(axH,'on')
plot(axH,0:1:length(SDI)-1,SDI','g-');
plot(axH,0:1:length(Sorensen)-1,Sorensen','r-')
plot(axH,0:1:length(Jaccard)-1,Jaccard','b-')

plot(axH,0:1:length(SDI_a)-1,SDI_a','g--')
plot(axH,0:1:length(Sorensen_a)-1,Sorensen_a','r--');
plot(axH,0:1:length(Jaccard_a)-1,Jaccard_a','b--');
plot(axH,0:1:length(OptIndex)-1,OptIndex','k:');
%yyaxis right %R2016
%plot(0:1:length(CostArea)-1,CostArea','k--');
%plotyy(hax,0:1:length(CostArea)-1,CostArea','k--',0:1:length(OptIndex)-1,OptIndex','k--');
legend(axH,'SDI','Sorensen','Jaccard','SDI_a','Sorensen_a','Jaccard_a','OptIndex')
set(axH,'Ylim',[0 2])
ylabel(axH,'Mean Similarity Index Value')
xlabel(axH,'Front')
grid(axH,'on')

end