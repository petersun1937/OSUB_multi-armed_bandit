function [A,Sl,l] = Median_Elim(epin,deltain,env)
ep(1) = epin/4;  delta(1) = deltain/2;
l = 1;
Sl = cell(1,1);  mu = cell(1,1);
Sl{1} = 1:length(env(:));

T = cell(1,1);  S = cell(1,1);

K1 = size(env,1);   K2 = size(env,2);

while length(Sl{l}(:)) ~= 1
    T{l}=zeros(size(Sl{l}));
    S{l}=zeros(size(Sl{l}));
    
    for a=1:length(Sl{l}(:))
        for t=1:round(1/((ep(l)/2))^2*log(3/delta(l)))

            X = rand() < env(Sl{l}(a));

            T{l}(a) = T{l}(a) + 1;
            S{l}(a) = S{l}(a) + X;
            
            mu{l} = S{l}./T{l};
            
        end
      
    end
    
    m(l) = median(mu{l}, 'all');
    
    %EnvS = env(Sl{l});
    Sl{l+1} = Sl{l}(mu{l}>=m(l));

    ep(l+1) = (3/4)*ep(l);
    delta(l+1) = delta(l)/2;
    l=l+1;
end
    
    [A1,A2] = ind2sub([K1,K2],Sl{l});
    A = [A1 A2];
end