function [x,y]=do_expansion(x,y,a,b,c,theta_w_s,aspect_i,slope_i,dt,resolution)
% UNITS! Sist. Internacional!
    
    %%   % AS  Old Euler integration (don't really know how to add slope) NO TÉ SLOPE
    %          [xiyi,inverted_flag]=check_sense_xiyi([x,y]);  % xiyi inverts sense if needed
    %         if inverted_flag==1
    %             a=flipud(a);
    %             b=flipud(b);
    %             c=flipud(c);
    %         end
    %         x=xiyi(:,1);
    %         y=xiyi(:,2);
    %         [x,y]=predictcorrect(x,y,a,b,c,theta,t(k));
    %         if inverted_flag==1
    %             x=flipud(x);
    %             y=flipud(y);
    %         end
    
    %%   % AS FARSITE
%     if plot_ellipses_flag==1
%         plot_ellipses(x,y,a*dt,b*dt,c*dt,theta_w_s)
%     end
    [x,y]=direct_richards_int(x,y,a,b,c,theta_w_s,aspect_i,slope_i,dt);
    
    %%
    % regridding & loop clipping! NO SÉ QUÈ FER ABANS!!!
    % looks nicer 1st REGRID +CLIPP (lasts litle longer) CHECK!!! -> TRUE
    
%     %Smooth data!
%     x=smooth(x,'rloess');
%     y=smooth(y,'rloess');
%   plot(x,y,'-*k');
    %hold on
    
    [xy]=loop_clipping(x,y);
%   plot(x,y,'--+b');
    
    [xy]=degridding_vect(xy(:,1),xy(:,2),resolution);
%   plot(xy(:,1),xy(:,2),'--*g');
    
% Only for debugging
if length(xy)<3
    stop %Numerical inconvergence!
end
    [xy]=regridding(xy(:,1),xy(:,2));
%   plot(xy(:,1),xy(:,2),'--*r')
    
    
    
    % RECLOSE PERIMETER IF DEGRIDING (or loop  clipping) HAS OPEN IT
    % Close perimeter
    x=xy(:,1);
    y=xy(:,2);
    if x(1)~=x(end) && y(1)~=y(end);
        x(end+1)= x(1);
        y(end+1)= y(1);
    end