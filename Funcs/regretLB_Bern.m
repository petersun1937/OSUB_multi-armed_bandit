function [lb] = regretLB_Bern(mu)
    mus = ones(size(mu))*max(mu);
    K = length(mu);
    %for k=1:K
        %I = mu(k)*log(mu(k)/mus)+(1-mu(k))*log((1-mu(k))/(mus));
        I = KLDiv(mu,mus);
        lb = nansum((mus-mu)./I,'all');
    %end
end
