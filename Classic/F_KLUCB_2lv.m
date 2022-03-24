function [k,b_k] = F_KLUCB_2lv(p1,p2,s,n)

    f = log(1 + n*log(log(n)))./s;
    %f = (log(t) + c*log(log(t+1)))./s;
    
    b_k = KLBinSearch_2lv(f,p1,p2);
    
    %b_k(p1.*p2==1) = 1; 
    % Force select any arm that's not explored yet
    b_k(s==0) = 1; 
    
    m = max(b_k);
    % Randomly pick one of the max
    mI = find(b_k == m);
    k = mI(randi(length(mI)));

end