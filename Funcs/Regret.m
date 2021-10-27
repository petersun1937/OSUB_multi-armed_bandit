function [regret] = Regret(T,t)
regret = zeros(1,Time);

    T_exp = T/t;

    if t>1
        regret(t) = regret(t-1) + sum((max(env) - env(k(t))).*T_exp);
    else
        regret(1) = sum(max(env) - env(k(t)).*T_exp);
    end
        
end