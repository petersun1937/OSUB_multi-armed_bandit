function [k,w] = F_UCB_2lv(mu1,mu2,T,delta)
    
    w = mu1.*mu2+sqrt((2./T).*log(1/delta));
    m = max(w);
    
    % Randomly pick one of the max-valued arm
    mI = find(w == m);
    k = mI(randi(length(mI)));
        
        
end