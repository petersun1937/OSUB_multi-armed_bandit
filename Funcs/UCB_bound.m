function [bound, u] = UCB_bound(Env,n1,n2,delta) 

for k=1:numel(Env)
    Del(k)=(max(Env,[],'all')-Env(k));
    u(k) = ceil(16*log(n1)/Del(k));
    bound(k) = u(k)+n2*(n2*delta+exp(-(u(k)*0.5^2*Del(k)^2)/2));
end