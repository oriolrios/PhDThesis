function [xdata,ydata,zdata]=getPlotData
%% getPlotData - get data from gca plot
% Stores LINES data from a plot
% OUTPUT
% xdata,ydata,zdata= Cell array with the data axis
% Usage: 
% [xdata,ydata,zdata]=getPlotData
%
% Orios 2016

h = gcf; %current figure handle
axesObjs = get(h, 'Children');  %axes handles
dataObjs = get(axesObjs, 'Children'); %handles to low-level graphics objects in axes
objTypes = get(dataObjs, 'Type');  %type of low-level graphics object

xdata=cell(length(objTypes),1);
ydata=cell(length(objTypes),1);
zdata=cell(length(objTypes),1);


for i=1:length(objTypes)
    xdata{i} = get(dataObjs(i), 'XData');  %data from low-level grahics objects
    ydata{i} = get(dataObjs(i), 'YData');
    zdata{i} = get(dataObjs(i), 'ZData');
end