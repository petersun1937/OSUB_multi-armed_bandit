function [k, ub, lb, nu] = F_UCBi(mu,T,delta)
    
    [s1, s2] = size(mu);
    
    for i=1:s2
        %%
        nu(i) = sum(mu(:,i).*T(:,i),'all')/sum(T(:,i),'all');
        
        
        % test
        %nu(i) = sum(mu(:,i),'all');
        
        
        [mus,js] = max(mu(:,i));
        %nu(i) = (T(js,i)*mus)/sum(T(:,i),'all');
        %nu(i) = mus;
        
        %eps(i) = sqrt((2./sum(T(:,i),'all')).*log(1/delta));
        %eps(i) = sqrt((2./(sum(T(:,i),'all')))^2.*log(1/delta));

        %% alpha = (K+2)/2
        eps(i) = sqrt( ( ((s1+2)/2)./sum(T(:,i),'all')).*log(1/delta));
        
        % test
        %eps(i) = s1*sqrt( ( 2./sum(T(:,i),'all')).*log(1/delta));
        
        ub(i) = nu(i) + eps(i);
        lb(i) = nu(i) - eps(i);
    end
    m = max(ub);
    % Randomly pick one of the max-valued arm
    if ( ~isnan(m))
    mI = find(ub == m);
    k = mI(randi(length(mI)));
    else
    k = randi(length(mu));
    end
        
        
end
    
