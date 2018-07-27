% **************************************************************************
%                        LOOP CLIPPING SCHEME
% **************************************************************************
% Algorithm:
% -Check for segment intersections within the same front
% -Convert intersaction into a point an place it correctly
% -Remove loop points
% WARNING: combnk(v,k) might be costly!
%
% INPUTS
% x,y           curve x,y colum vectors (CAN BE OPEN PERIMETER. NO NEED TO
% CLOSE
%
% OUTPUTS
%
% xy_no_loop     coordinates without loops
%
% Orios 2015
% History:
% $ 10.06.16 Fix problem when initial-end point are within a double loop!(line 105)
%
function [xy_no_loop]=loop_clipping(x,y)
% create all pairs combinations to check intersection
%adjacent segments cannot cross
% NO ho sé fer sense loop!!
% DEBUG
% if x(end)/451170.198449126==1 || y(end)==4619381.46825803
%     stop
% end
if length(x)<3
    error('MyError in "loop_clipping.m", less than three nodes isochrone')
end

% % % Close perimeter if its open. Does not make any change!! ?¿ TREURE¿¿¿
% if x(1)~=x(end) && y(1)~=y(end);
%     x(end+1)= x(1);
%     y(end+1)= y(1);
% end

N_xy=0;
flag=0;
while N_xy < length(x)/4 % To set a threashold to avoid close loops in initial points
    
    xy_inter=[];
    int_adj =[];
    intersected_edges=[];
    
    edge_xy=[x y [x(2:end) y(2:end);x(1) y(1)]];
    xy_no_loop=[x y];
    
    % ALGORITHM to check for intersections utilitzant C = combnk(v,k) !!
    %c = combnk(1:size(x,1),2);% Too Slow!
    %c = combinator(size(x,1),2,'c');
    % combinations without repetitions
    c = combs_no_rep(size(x,1),2);
    
    
    %c = flipud(combnk(1:length(x),2)); %creates de combinatorial adjacent matrix! ATENCIÓ!! PILLA TEMPS!
    
    % THIS IS SUPER SLOW
%     comb_xy=[edge_xy(c(:,1),:) edge_xy(c(:,2),:)];
%     [xy_inter,int_adj]= intersect2segments(comb_xy(:,1:4), comb_xy(:,5:8));
    % LETS TRY THIS INSTEAD. IS FASTER CHECKED!!!
     [xy_inter,int_adj]= intersect2segments(edge_xy(c(:,1),:), edge_xy(c(:,2),:));
    
    %% MEX
    %[xy_inter,int_adj]=intersect2segments_mex(comb_xy(:,1:4), comb_xy(:,5:8));
    
    intersected_edges=c(int_adj,:);
    %
    %%hold on; plot(xy_inter(:,1),xy_inter(:,2),'r*') % TEMPORAL PLOT
    %%
    xy_no_loop(intersected_edges(:,1)+1,:)=xy_inter; % Add intersection points (substitute first point in the loop)
    del_ind=[];
    % number of intersections
    % ACCOUNT FOR LOOPS THAN INCLUDE FIRST NODES AND CLOSE REVERSLY (3->97) via (97-98-99-100-1-2-3)
    nodes_end=length(x);
    if sum(sum(xy_inter))>0 % if loops

        intersected_edges_2_1=diff(intersected_edges,1,2);
        intersected_edges_1_end_2=nodes_end*ones(size(intersected_edges,1),1)-intersected_edges(:,2)+intersected_edges(:,1);
        
        if (intersected_edges_1_end_2(1,:)-intersected_edges_2_1(1,:))<0 %only possible in the first intersections!
            first_edge_intersected=intersected_edges(1,:);
            intersected_edges(1,:)=[];
        end
    end
    
    if size(intersected_edges,1)>0 %què fa això??
        for i=1:size(intersected_edges,1)
            del_ind=[del_ind (intersected_edges(i,1)+2):intersected_edges(i,2)];
        end
    else
        del_ind=[];
    end
    
    if exist('first_edge_intersected','var') %if first node into a loop
        del_ind=[1:first_edge_intersected(1), del_ind, (first_edge_intersected(2)+1):nodes_end];
    end
    
% Delete loops. Redoundant. AND GENERATE NAN if NumericalInconvergies
if length(del_ind)>=length(xy_no_loop)
 %  error('MyErr:loop_clipping. Numerical Inconvergence Of clipping Algorithm') 
   disp('MyErr:loop_clipping. Numerical Inconvergence Of clipping Algorithm->NaN') 
   xy_no_loop=NaN(size(xy_no_loop));
else
    xy_no_loop(del_ind,:)=[];
end
    
%     x_no_loop=xy_no_loop(:,1);
%     y_no_loop=xy_no_loop(:,2);
    %    plot(xy_no_loop(:,1),xy_no_loop(:,2),'--g+')
%% Alternative changing cols
%    comb_xy=[x(c) y(c)];
%    comb_xy(:,[2,4])=comb_xy(:,[4,2]);    
    N_xy=length(xy_no_loop);

% Eliminate last point to overcome the initial loop
    x=x(1:end-1);
    y=y(1:end-1);
    
end
%%
% xy_no_loop=[x_no_loop, y_no_loop];
end
