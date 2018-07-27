function MyExportFigPngStyle(fH,file_name, style, MyPath)
%% MtExportFigPngStyle() exports figures in *png and *fig mode for a given style
% if Path is not input Current path is used. 
%
% INPUT
% fH        = figure Handle
% file_name = file name
% style     = (default=MyDefault)export style defined in export canfiguration
% path      = (optional) path to save
%
% Example:
% MyExportFigPngStyle(gcf,'test','contourf','y:\A_DOCS ORIOL')
% MyExportFigPngStyle(hF,'test','contourf')

% 
PathChangeFlag=0;
if nargin>3
    O_path=pwd;
    cd(MyPath)
    PathChangeFlag=1;
end
if nargin<3 % default style
    style='MyDefault';
end

% get style sheet info
s=hgexport('readstyle',style);

%Export PNG
s.Format = 'png'; %I needed this to make it work but maybe you wont.
hgexport(fH,file_name,s);

%Export FIG
s.Format = 'fig'; %I needed this to make it work but maybe you wont.
hgexport(fH,file_name,s);

if PathChangeFlag==1
    cd(O_path)
end
end
