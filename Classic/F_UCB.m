function [k, w] = F_UCB(mu,T,delta)
    
    w = mu+sqrt((2./T).*log(1/delta));
    m = max(w);
    
    % Randomly pick one of the max-weighted arm
    mI = find(w == m);
    k = mI(randi(length(mI)));
  
end
    
