function PlotAssimilationFigures(Invariants,CostVal,xy_real,xy_model,xy_model_ini_guess,inv_char,info_str)
%% Plotting
Invarians_norm=[Invariants(:,1)/Invariants(end,1),Invariants(:,2)/Invariants(end,2),Invariants(:,3)/Invariants(end,3),Invariants(:,4)/Invariants(end,4)];
% figure
% plot(Invarians_norm)
% 
% figure
% plot(CostVal)


figure('Name', 'Fronts')
aH0=axes;
plot_fronts_cell(xy_real,'hold','-k');
plot_fronts_cell(xy_model_ini_guess.xy,'hold','--g');
plot_fronts_cell(xy_model.xy,'hold','--r');
annotation('textbox', [0.05,0.05,0.1,0.1],'String', info_str{2});
%% CONVERGENCE PLOT
figure('Name', 'Convergence')
set(0,'defaultlinelinewidth',2)
Ha1=subplot(1,3,1);
%plot(Cost_total,'-X'); hold on;
%plot(cost_area, -rx')
plot(Ha1,CostVal);
title(Ha1,'Cost Value')
xlabel(Ha1(1),'Iteration')
ylabel(Ha1(1),'sum Area Error [m^2]')
legend('Cost Value'),
grid(Ha1,'on');

% Plot invariants individual convergence
Ha2=subplot(1,3,2);
title(Ha2,'Invariants relative individual convergence' )
hold(Ha2,'on')
hpp1=plot(Ha2,Invarians_norm*100);
% Coloring
set(hpp1(1),'MarkerFaceColor',[1 0 0],...
    'MarkerEdgeColor',[1 0 0],...
    'LineStyle','--',...
    'Color',[1 0 0]);
set(hpp1(2),...
    'MarkerFaceColor',[0.87058824300766 0.490196079015732 0],...
    'MarkerEdgeColor',[0.87058824300766 0.490196079015732 0],...
    'LineStyle','-.',...
    'Color',[1 0.5 0]);
set(hpp1(3),...
    'MarkerFaceColor',[0 0.498039215803146 0],...
    'MarkerEdgeColor',[0 0.498039215803146 0],...
    'LineStyle',':',...
    'Color',[0 0.498039215803146 0]);

set(hpp1(4),'Color',[0.5 0.18 0.55]);
box on
grid on

ylabel(Ha2,'Invariant Value [%]')
xlabel(Ha2,'Iteration')
legend (hpp1, inv_char(1:4))

% Absolute Value
subplot(1,3,3)
title('Invariants absolut individual convergence' )
hold on
hpp1=plot(Invariants);
% Coloring
set(hpp1(1),'MarkerFaceColor',[1 0 0],...
    'MarkerEdgeColor',[1 0 0],...
    'LineStyle','--',...
    'Color',[1 0 0]);
set(hpp1(2),...
    'MarkerFaceColor',[0.87058824300766 0.490196079015732 0],...
    'MarkerEdgeColor',[0.87058824300766 0.490196079015732 0],...
    'LineStyle','-.',...
    'Color',[1 0.5 0]);
set(hpp1(3),...
    'MarkerFaceColor',[0 0.498039215803146 0],...
    'MarkerEdgeColor',[0 0.498039215803146 0],...
    'LineStyle',':',...
    'Color',[0 0.498039215803146 0]);
set(hpp1(4),'Color',[0.5 0.18 0.55]);

box on
grid on

ylabel('Invariant aboslute Value')
xlabel('Iteration')
legend (hpp1, inv_char(1:4))

mtit('SmartQFIRE')