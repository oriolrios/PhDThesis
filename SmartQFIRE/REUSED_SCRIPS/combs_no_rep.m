function CN = combs_no_rep(N,K)
% Funció refeta a mida per a integrar amb adimat. M'he carregat el MEX
% (substituïr després??)
% Subfunction choose:  combinations w/o replacement.
% cn = @(N,K) prod(N-K+1:N)/(prod(1:K));  Number of rows.
% Same output as the MATLAB function nchoosek(1:N,K), but often faster for
% larger N.
% For example: 
%
%      tic,Tn = nchoosek(1:17,8);toc
%      %Elapsed time is 0.430216 seconds.  Allow Ctrl+T+C+R on block
%      tic,Tc = combinator(17,8,'c');toc  
%      %Elapsed time is 0.024438 seconds.
%      isequal(Tc,Tn)  % Yes
% Taken from:
% Author:   Matt Fig
% Contact:  popkenai@yahoo.com
% Date:     5/30/2009
%
% Reference:  http://mathworld.wolfram.com/BallPicking.html
% IMPORTANT:
% The combinations without repetition algorithm for the special case of K=2.
% Unfortunately, MATLAB does not allow cumsum to work with integer classes.
% Thus a subfunction has been placed at the end for the case when these
% classes are passed.  The subfunction will automatically pass the
% necessary matrix to the built-in cumsum when a single or double is used.
% When an integer class is used, the subfunction first looks to see if the
% accompanying MEX-File (cumsumall.cpp) has been compiled.  If not, 
% then a MATLAB For loop is used to perform the cumsumming.  This is 
% VERY slow!  Therefore it is recommended to compile the MEX-File when 
% using integer classes. 


if K>N
    error(['When no repetitions are allowed, '...
           'K must be less than or equal to N'])
end

M = double(N);  % Single will give us trouble on indexing.

if K == 1
   CN =(1:N).';  % These are simple cases.
   return
elseif K == N
    CN = (1:N);
    return
elseif K==2 && N>2  % This is an easy case to do quickly.
    BC = (M-1)*M / 2;
    id1 = cumsum2((M-1):-1:2)+1;
    CN = zeros(BC,2,class(N));
    CN(:,2) = 1;
    CN(1,:) = [1 2];
    CN(id1,1) = 1;
    CN(id1,2) = -((N-3):-1:0);
    CN = cumsum2(CN);
    return
end

WV = 1:K;  % Working vector.
lim = K;   % Sets the limit for working index.
inc = 1;   % Controls which element of WV is being worked on.
BC = prod(M-K+1:M) / (prod(1:K));  % Pre-allocation.
CN = zeros(round(BC),K,class(N));
CN(1,:) = WV;  % The first row.

for ii = 2:(BC - 1);   
    if logical((inc+lim)-N) % The logical is nec. for class single(?)
        stp = inc;  % This is where the for loop below stops.
        flg = 0;  % Used for resetting inc.
    else
        stp = 1;
        flg = 1;
    end
    
    for jj = 1:stp
        WV(K  + jj - inc) = lim + jj;  % Faster than a vector assignment.
    end
    
    CN(ii,:) = WV;  % Make assignment.
    inc = inc*flg + 1;  % Increment the counter.
    lim = WV(K - inc + 1 );  % lim for next run. 
end
  
CN(ii+1,:) = (N-K+1):N;

function A = cumsum2(A)
%CUMSUM2, works with integer classes. 
% Duplicates the action of cumsum, but for integer classes.
% If Matlab ever allows cumsum to work for integer classes, we can remove 
% this.
 A = cumsum(A);  % For single and double, use built-in.
% if isfloat(A)
%     A = cumsum(A);  % For single and double, use built-in.
%     return
% else
%     %try
%         A = cumsumall(A);  % User has the MEX-File ready?
%     %catch
%     %    warning('Cumsumming by loop.  MEX cumsumall.cpp for speed.') %#ok
%         for ii = 2:size(A,1)
%             A(ii,:) = A(ii,:) + A(ii-1,:); % User likes it slow.
%         end
%     %end
% end