function [area_XOR,SDI,SORENSEN,JACCARD,SDI_a,SORENSEN_a,JACCARD_a]=area_between_curves(xy_front_real,xy_front_model,varargin)
%% [cost_area]=area_between_curves(xy_front_real,xy_front_model,varargin)
%
% Calculates distance from ONE model isochrone to ONE real isochrone:: xy_model(t)->xy_real(t)
% 
% EXAMPLE
% [cost_area]=area_between_curves(xy_front_real,xy_front_model)
% [cost_area]=area_between_curves(xy_front_real,xy_front_model,'plot',initial_area)
% [cost_area]=area_between_curves(xy_front_real,xy_front_model, hAx, initial_area)
% [cost_area]=area_between_curves(xy_front_real,xy_front_model, 'noplot', initial_area)
%
% INPUTS
% xy_front_real    = ONE xy observed (real) MATRIX (nx2)
% xy_front_model   = ONE xy model front coordinates MATRIX (nx2)
% varargin         = axis handle to plot (if nothing does not plot)
%
% OUTPUTS
% area_XOR        = area difference in m^2
% SDI
% SORENSEN
% JACCARD
% SDI_a           = adimmentional SDI Substracting Initial Part (revision1)
% SORENSEN_a      = adimmentional SDI Substracting Initial Part (revision1)
% JACCARD_a       = adimmentional SDI Substracting Initial Part (revision1)
%
% History:
% $02/06/16: Change all indicators to converge to 0 instead of 1(minimize)
% $02/06/16: For Indicators_a -> XOR i properly recalculated (XY_real_ini as a hole):NOT DONE (NOT NEEDED) ! (line 83)
%
% ************ %
%plotting=1;    % 1= PLOT, 0= NO plot (AUTOMÀTIC)
% ************ %
%% MODIFICACIÖ TEMPORAL index corregits

% check that are closed perimeters and close it
flag_calcul_indices=0;
if nargin>2
    if strcmp(varargin{1},'plot')
        plotting=1;
        figure('Name','Error Area')
        hold on
        axH=gca;
        
    elseif isnumeric(varargin{1})
        plotting=1;
        axH=varargin{1};
        axes(axH)
              
    else        
        plotting=0;
        
    end
    
    if length(varargin)>1 %SDI el calculem sempre!
        initial_area=varargin{2};
        flag_calcul_indices=1;
        
    else
        error('MyErr: Needs to INPUT initial area (to avoid computing it all time)')
    end
    
else
    plotting=0;
end

%         plotting=1;
%         axH=varargin{1};
%         axes(axH)
%         initial_area=varargin{2};
%%
% closing polygon
if xy_front_real(1,:)~=xy_front_real(end,:)
    xy_front_real(end+1,:)=xy_front_real(1,:);
end

if xy_front_model(1,:)~=xy_front_model(end,:)
    xy_front_model(end+1,:)=xy_front_model(1,:);
end

% USES MEX file from http://www.cs.man.ac.uk/~toby/gpc/ [BRUTAL!]
P1.x=xy_front_model(:,1); P1.y=xy_front_model(:,2); P1.hole=0;
P2.x=xy_front_real(:,1); P2.y=xy_front_real(:,2); P2.hole=0;

% we don't have initial front coordinated here, but is the correct way to
% do it. Computationally expensive?
% THIS IS UNNECESSARY since all fronts will always be larger than REAL_INITIAL
% else %no substraction needed
%     P2.x=xy_front_real(:,1); P2.y=xy_front_real(:,2); P2.hole=0;
%     P2(2).x=xy_front_real_ini(:,1); P2(2).y=xy_front_real_ini(:,2); P2.hole=1;
    


P_AND=PolygonClip(P1,P2,1); % type=1 -> AND
P_XoR=PolygonClip(P1,P2,2); % type=2 -> XOR
%%P_OR=PolygonClip(P1,P2,1);  % type=3 -> OR (UNION) NO CAL

area_XOR_i=zeros(length(P_XoR),1);
area_AND_i=zeros(length(P_AND),1);

ind_hole=[];
ind_no_hole=[];
%% A AND B - INTERSECTION
for kk=1:length(P_AND) %Jo cre q això sempre és 3.
    if P_AND(kk).hole==1
        is_hole=-1;
        ind_hole=[ind_hole kk];
    else
        is_hole=1;
        ind_no_hole=[ind_no_hole kk];
    end
    area_AND_i(kk)=is_hole*polyarea(P_AND(kk).x,P_AND(kk).y);
end
area_AND=sum(area_AND_i); %si discontinuïtats

%% A OR B = A + B = a U b. UNION
ind_hole=[];
ind_no_hole=[];

% % for kk=1:length(P_OR) %Jo cre q això sempre és 3.
% %     if P_OR(kk).hole==1
% %         is_hole=-1;
% %         ind_hole=[ind_hole kk];
% %     else
% %         is_hole=1;
% %         ind_no_hole=[ind_no_hole kk];
% %     end
% %     area_OR(kk)=is_hole*polyarea(P_OR(kk).x,P_OR(kk).y);
% % end

%% A XOR B = invers(A AND B) - Exclusive interection MEU ERROR SDI (shape deviation index)
ind_hole=[];
ind_no_hole=[];

for kk=1:length(P_XoR) %Jo cre q això sempre és 3.
    if P_XoR(kk).hole==1
        is_hole=-1;
        ind_hole=[ind_hole kk];
    else
        is_hole=1;
        ind_no_hole=[ind_no_hole kk];
    end
    area_XOR_i(kk)=is_hole*polyarea(P_XoR(kk).x,P_XoR(kk).y);
end
area_XOR=sum(area_XOR_i); %és la suma! Correcte!

A_model=polyarea(P1.x,P1.y);
A_real=polyarea(P2.x,P2.y);

%% SDI
%   My_SDI(i,1)=cost_area(i,1)/real_area*100; rejected paper
SDI=area_XOR/A_real;

if flag_calcul_indices==1
    
    %% MYSDI
%   My_SDI(i,1)=cost_area(i,1)/real_area*100; rejected paper
    %SDI=1-area_XOR/A_real;
    %SDI_a=1-area_XOR/(A_real-initial_area);
    
    % SORENSEN & JACCARD (min -> 0)
    SDI=area_XOR/A_real;
    %SORENSEN=(2*area_AND)/(A_model+A_real);
    SORENSEN=1-(2*area_AND)/(A_model+A_real);
    %JACCARD=(area_AND)/(A_model+A_real-area_AND); % és el mateix q AintB/AuB
    JACCARD=1-(area_AND)/(A_model+A_real-area_AND); % és el mateix q AintB/AuB
    
    if A_real==initial_area % fist front
        SDI = 0; % XOR fails and gives 1 in this case! (if identical!)
        SDI_a=0;
        SORENSEN_a=0;
        JACCARD_a=0;
    else
%         SDI_a=area_XOR/(A_real-initial_area);
%         SORENSEN_a=(2*(area_AND-initial_area))/(A_model+A_real-2*initial_area);
%         JACCARD_a=(area_AND-initial_area)/(A_model+A_real-area_AND-initial_area); % és el mateix q AintB/AuB
        SDI_a=area_XOR/(A_real-initial_area); %SDI ja va a 0!
        SORENSEN_a=-((2*(area_AND-initial_area))/(A_model+A_real-2*initial_area))+1;
        JACCARD_a=1-(area_AND-initial_area)/(A_model+A_real-area_AND-initial_area); % és el mateix q AintB/AuB
%         if SDI_a<0 %DEBUGG ONLY
%            hh=1; 
%         end
    end
end

% Plotting
if plotting==1
    for kk=ind_no_hole % first fill no holes
        patch(P_XoR(kk).x,P_XoR(kk).y,'b')
    end
    for kk=ind_hole % (un)fill holes
        patch(P_XoR(kk).x,P_XoR(kk).y,'w')
    end
    plot(axH,xy_front_model(:,1), xy_front_model(:,2),'-r','linewidth',2); plot(xy_front_real(:,1), xy_front_real(:,2),'-k','linewidth',2)
end

end
%% INTENT MEU
% % edge_real =[xy_front_real(1:end-1,1) ,xy_front_real(1:end-1,2) ,xy_front_real(2:end,1) ,xy_front_real(2:end,2)];
% % edge_model=[xy_front_model(1:end-1,1),xy_front_model(1:end-1,2),xy_front_model(2:end,1),xy_front_model(2:end,2)];
% %
% %         num_edge_real=size(edge_real,1);
% %         num_edge_model=size(edge_model,1);
% %
% %         edge_model_mat=reshape(repmat(edge_model',num_edge_real,1),size(edge_model,2),[])';
% %         edge_real_mat=repmat(edge_real,num_edge_model,1);
% %         [xy_inter, int_adj]= intersect2segments(edge_model_mat, edge_real_mat);
% %         int_adj_matrix=reshape(int_adj,num_edge_real,[]);
% %
% % %         edge_model_mat=reshape(repmat(edge_real',num_edge_model,1),size(edge_real,2),[])';
% % %         edge_real_mat=repmat(edge_model,num_edge_real,1);
% % %         [xy_inter, int_adj]= intersect2segments(edge_real_mat,edge_model_mat);
% % %         int_adj_matrix=reshape(int_adj,num_edge_model,[])';
% % %         xy_inter_sort=int_adj_matrix;
% %
% % inter_model_segment=sum(int_adj_matrix,2);
% % inter_model_segment(inter_model_segment==0)=[];
% %
% % if isempty(xy_inter) %no intersection
% %     A_poly_model=polyarea(xy_front_model(:,1),xy_front_model(:,2));
% %     A_poly_real=polyarea(xy_front_real(:,1),xy_front_real(:,2));
% %     cost_area=A_poly_model-A_poly_real;
% % elseif size(xy_inter,1)==1
% %     %no idea what to do
% % elseif size(xy_inter,1)>1   %more than one intersection
% %     [c,r]=find(int_adj_matrix'==1); % intercanviats a proposit pq quedin ordenats
% %     % sort intersected points
% %         itrsct_ind=find(int_adj_matrix>=1);
% %         cr2sub=sub2ind(size(int_adj_matrix),r,c);
% %         xy_inter_sort_ind(itrsct_ind,:)=xy_inter;
% %         xy_inter_sort=xy_inter_sort_ind(cr2sub,:);
% %         for k=1:length(inter_model_segment)
% %             if inter_model_segment(k)>1
% %             xy_inter_sort(k:k+inter_model_segment(k)-1,:)=flipud( xy_inter_sort(k:k+inter_model_segment(k)-1,:));
% %             end
% %         end
% %
% %
% %     polygons=cell(length(itrsct_ind),1);
% %
% %     for i=1:2:length(itrsct_ind)-1 % loop for odd polygon intersections (as many as intersections)
% %         %polygon_model{i,1}=[xy_inter(i,:);xy_front_real(itrsct_ind(i)+1:itrsct_ind(i+1),:); xy_inter(i+1,:)];
% %         polygon_real=[xy_inter_sort(i,:);xy_front_real(r(i)+1:r(i+1),:); xy_inter_sort(i+1,:)];
% %         polygon_model=flipud(xy_front_model(c(i)+1:c(i+1),:));
% %         polygons{i,1}=[polygon_real; polygon_model];
% %
% % %% plotting
% % plot(xy_front_model(:,1), xy_front_model(:,2),'-xg'); hold on; plot(xy_front_real(:,1), xy_front_real(:,2),'-xk')
% % fill(polygons{i,1}(:,1), polygons{i,1}(:,2),'r')
% %     end
% % end
% %
% % end








