function InvertRLsubplots(FH)
%this functions INVERTS LR all available subplots in a figure

axesObjs = get(FH, 'Children');  %axes handles
%dataObjs = get(axesObjs, 'Children'); %handles to low-level graphics objects in axes
%objTypes = get(dataObjs, 'Type');  %type of low-level graphics object

% xdata=cell(length(objTypes),1);
% ydata=cell(length(objTypes),1);
% zdata=cell(length(objTypes),1);


for i=length(axesObjs):-1:1
    if i==length(axesObjs)
       XLIM=axesObjs(i).XLim;
       YLIM=axesObjs(i).YLim;
    end
    TickStrg=axesObjs(i).XTickLabel;
    axesObjs(i).XDir='reverse';
    axesObjs(i).XTickLabel=TickStrg;
    axesObjs(i).XLim=XLIM;
    axesObjs(i).YLim=YLIM;
end

end