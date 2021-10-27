function [k] = F_UCB(mu,T,delta)
    
    f = mu+sqrt((2./T).*log(1/delta));
    m = max(f);
    % Randomly pick one of the max-valued arm
    if ( ~isnan(m))
    mI = find(f == m);
    k = mI(randi(length(mI)));
    else
    k = randi(length(mu));
    end
        
        
end
    
