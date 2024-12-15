[mu_s,ind_s] = max(Env(:));
[jss,is] = ind2sub(size(Env), ind_s); % optimal beam
for i=1:K2
    [mu_js,js] = max(Env(:,i));
    Delta=(mu_s-mu_js);
    delt = (mu_s-Env(:,is));
    delt(delt==0)=1;
    delt_m = min(delt,[],'all');
    C(i) = (mu_js+Delta/2)/mu_s;
    r(i) = (K1-1)*16/((1-C(i))*delt_m^2);
    t_i(i) = r(i)*log(r(i));
end