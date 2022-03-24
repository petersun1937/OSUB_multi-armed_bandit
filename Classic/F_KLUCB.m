function [k,q] = F_KLUCB(p,s,n)
    f = log(1 + n*log(log(n)))./s;
    %f = (log(t) + c*log(log(t+1)))./s;
    
    %b_k = NaN(size(p));
    %b_k(~isnan(p)) = KLBinSearch(f(~isnan(p)),p(~isnan(p)));
    
    q = KLBinSearch(f,p);
    
    %q(p==1) = 1; 
    % Force select any arm that's not explored yet
    q(s==0) = 1; 

    m = max(q);
    % Randomly pick one of the max
    mI = find(q == m);
    k = mI(randi(length(mI)));

end