function paxlabel(ax,hfig)
% Función utilizada para mostrar los ejes con números enteros en las
% imágenes
% Con soporte para zoom
% Miguel (c) 2008
setlabels(ax);
hz=zoom(hfig);
% set(hz,'ActionPreCallback',@precallback);
set(hz,'ActionPostCallback',@postcallback);
set(hfig,'resizefcn',{@resize ax});


function setlabels(ax)
set(ax,'DataAspectRatio',[1 1 1])


xlim=get(ax,'xlim');
ylim=get(ax,'ylim');


if any(xlim>1e4)
    xt=get(ax,'XTick');
    nx=numel(xt);
    tt=cell(1,nx);
    for i=1:numel(xt)
        tt{i}=sprintf('%d',int32(xt(i)));
    end
    set(ax,'xticklabel',tt)
end

if any(ylim>1e4)
    xt=get(ax,'yTick');
    nx=numel(xt);
    tt=cell(1,nx);
    for i=1:numel(xt)
        tt{i}=sprintf('%d',int32(xt(i)));
    end
    set(ax,'yticklabel',tt)
end
set(ax,'FontSize',9,'YTickLabelMode','manual',...
    'XTickLabelMode','manual');

% function precallback(obj,evt)
% set(evt.Axes,'FontSize',9,'YTickLabelMode','auto',...
%     'xTickLabelMode','auto');
% disp('A zoom is about to occur.');

function postcallback(obj,evt)
set(evt.Axes,'FontSize',9,'YTickLabelMode','auto',...
    'xTickLabelMode','auto');
setlabels(evt.Axes);
% disp('A zoom has occur.');

function resize(obj,evd,ax)
set(ax,'FontSize',9,'YTickLabelMode','auto',...
    'xTickLabelMode','auto');
setlabels(ax);

