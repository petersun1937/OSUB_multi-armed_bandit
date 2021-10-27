function [k] = F_KLUCB(p,s,n)

    f = log(1 + n*log(log(n)))./s;
    %f = (log(t) + c*log(log(t+1)))./s;
    
    b_k = KLBinSearch(f,p);
    
    b_k(p==1) = 1; 
    b_k(s==0) = 1; 
    
    %ArmToPlay = PickingMaxIndexArm(ucb);
    m = max(b_k);
    if ( ~isnan(m))
        mI = find(b_k == m);
        k = mI(randi(length(mI)));         % Randomly pick one of the max
    else
        k = randi(K);
    end

end