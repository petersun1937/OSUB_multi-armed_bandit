function [nu] = Calculate_nu(mu,n)
    [s1, s2] = size(mu);
    %mu_s = mu(j,i)-mu(j,i);
    for i=1:s2
        for j=1:s1
        	T(j,i)=(8*log(n))/(max(mu(:,i),[],'all')-mu(j,i));
        end
        T(isinf(T))=n;
        nu(i)=(sum(T(:,i).*mu(:,i),'all'))/sum(T(:,i),'all');
    end

end