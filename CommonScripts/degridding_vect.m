function [newxy]=degridding_vect(x,y,resolution_min)
% New version! 

% Close perimeter 
    if x(1)~=x(end) && y(1)~=y(end);
        x(end+1)= x(1);
        y(end+1)= y(1);
    end
    
deg_end=0;
while deg_end==0
    AX=diff(x);
    AY=diff(y);
    
    norm=(AX.^2+AY.^2).^0.5;
    deg_ind=norm<resolution_min;
    
    %id1=3*deg_ind+[0; deg_ind(1:end-1)];
    id1=3*deg_ind+[0; deg_ind(1:end-1)]+2*[deg_ind(2:end); 0];
    del_in=id1==5;
    del_in_logic=logical([0; del_in(1:end-1)]);
   
    if sum(del_in)>0
        x(del_in_logic)=[];
        y(del_in_logic)=[];
        deg_end=0;
    else
        deg_end=1;
    end
end
newxy=[x,y];

end

% % Invented algorithm to substract every two
% id1=3*deg_ind+[0; deg_ind(1:end-1)];
% deg_ind(id1==3)=0;
% deg_sum=2*deg_ind+[0; deg_ind(1:end-1)]+[deg_ind(2:end) ; 0];
% %ind_del=deg_ind= [0 1 1 0 0 1 0 1 1 1]';
% 
% %deg_ind(1:2:end)=1; % don't delete consecutives. BARROÉ. poc llest
% 
% %newxy=[x(deg_ind),y(deg_ind)];
% 
% 
% %newxy(~deg_ind,:)=[];