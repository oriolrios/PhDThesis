% Calculates distance from a model front to a real one. 

%   INPUTS
% xy_front_real    = xy observed (real) CELL {N(nx2), 1} front coordinates
% xy_front_model   = xy model front coordinates CELL ({N(nx2), 1}
% varargin         = coloring options

%   OUTPUTS
% median_x1_front      = median difference 
% mode2real_x1_front = node-node difference ( 
% point_inter        = intersection point at real fronts
% xy_model_midle     = 

function [median_x1_front,mode2real_x1_front,xy_real_diff,xy_model_midle]=front_distance(xy_front_real,xy_front_model,varargin)

% ************ %
plotting=0;    % 1= PLOT, 0= NO plot
% ************ %


if isempty(varargin) % to color lines in every isochrone pair
    t = 10;
else
    t=cell2mat(varargin);
end
% pendent
%xy_model=[xy_front_model(1:end-1,1) xy_front_model(1:end-1,2)];
Vx=diff(xy_front_model(:,1));
Vy=diff(xy_front_model(:,2));
%xy_model_midle=[xy_front_model(1:end-1,1)+Vx./2; (xy_front_model(end,1)+(xy_front_model(1,1)-xy_front_model(end,1))/2),xy_front_model(1:end-1,2)+Vy./2];
xy_model_midle=[xy_front_model(1:end-1,1)+Vx./2 ,xy_front_model(1:end-1,2)+Vy./2];

% EDGE =[xi yi xf yf]
edge=[xy_front_real(1:end-1,1),xy_front_real(1:end-1,2),xy_front_real(2:end,1),xy_front_real(2:end,2)]; 
m=Vy./Vx;


% Ho fem a SAC (tots amb tots) i agafem el mínim (primera intersecció)
line=createNormalLine(xy_model_midle(:,1),xy_model_midle(:,2),m); % last point (same as first) substracted. CREATE line in the midle point

% Prepare line and edge in form of matrices
        numlines=size(line,1);
        numedges=size(edge,1);
        line_mat=reshape(repmat(line',numedges,1),size(line,2),size(line,1)*numedges)';
        edge_mat=repmat(edge,numlines,1);
        
        % Find intersection between lines and edges and calculate distance
        [point]=intersectLineEdge_DA(line_mat, edge_mat);
        % Euclidian distance betwin line starting point and intersection
        dist=hypot(point(:,1)-line_mat(:,1),point(:,2)-line_mat(:,2));
        %dist_line=reshape(dist,[],numedges);
        dist_line=reshape(dist',[],numlines)';
        %We only take the minimum distance
        [mode2real_x1_front,I]=min(dist_line,[],2); % min distance for each (unique) line intersection
        % AIXÖ ÉS PER PODER IDENTIFICAT EL PUNT D'INTERSECCIÖ QUE CORRESPON
        % AL MÏNIM----> ACABAR point_m(:,I) no va i point_m(1:end,I) TP
        all=[1:length(I)]';
        point_x=reshape(point(:,1),[],numlines)';
        point_y=reshape(point(:,2),[],numlines)';
        % USE LOGICAL????
        iix=sub2ind(size(point_x),all,I);
        iiy=sub2ind(size(point_y),all,I);
 
        xy_real_diff=[point_x(iix) point_y(iiy)];
        %% Delete NaNs interextions AND NODES (for jacobian %CO.)
% %         mode2real_x1_front=mode2real_x1_front(~isnan(mode2real_x1_front));
% %         xy_real_diff(isnan(mode2real_x1_front))=[];
% %         xy_model_midle(isnan(mode2real_x1_front))=[];
        
        %mean_x1_front=mean(mode2real_x1_front(~isnan(mode2real_x1_front))); % SUM without NAN
        median_x1_front=median(mode2real_x1_front(~isnan(mode2real_x1_front))); % SUM without NAN%
% PLOTTING!!!!
if plotting==1
hold on
color_map=colormap(lines);
   for i=1:length(xy_real_diff)
    %plot([xy_model_midle(i,1);point_inter(i,1)],[xy_model_midle(i,2);point_inter(i,2)],'--+', 'color', color_map(t,:))
    plot([xy_model_midle(i,1);xy_real_diff(i,1)],[xy_model_midle(i,2);xy_real_diff(i,2)],'--','color',color_map(2*t,:))
   end
end
   
end