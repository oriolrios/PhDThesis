function PlotInvariantsBar(Invariants,inv_char,OptIndexStrng)
%
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

end
       
        

end