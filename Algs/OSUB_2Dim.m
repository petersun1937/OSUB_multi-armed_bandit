function [reward, regret, asympregret, k, timer] = OSUB_2dim(Env1_1, Env1_2, Env2, gamma, Time, alg)
    
    Env = (Env1_1.*Env1_2)'.*Env2;

    K1 = length(Env1_1);    K2 = length(Env2);
    L = zeros(Time,2);  %L(1) = randi(K);
    mu = zeros(K1,K2);
    l = zeros(K1,K2);
    T = zeros(K1,K2);  S = zeros(K1,K2);    F = zeros(K1,K2);
    reward = [];    %SelectedArm = [];
    asympregret = zeros(1,Time);
    regret = zeros(1,Time);
    
    k = [];
    
    %regret = [];
    timer = [];         % timer
    
    
    tic;
    t=0;
    for i= 1:K1
        for j=1:K2
            
        k = [k; i j];
        t=t+1;

        X = rand() < Env1_1(k(t,1));
        Y = rand() < Env1_2(k(t,1))*Env2(k(t,2));
        Z = X*Y;
        
        reward = [reward Z];

        T(k(t,1),k(t,2)) = T(k(t,1),k(t,2)) + 1;

        S(k(t,1),k(t,2)) = S(k(t,1),k(t,2)) + Z;
        F(k(t,1),k(t,2)) = F(k(t,1),k(t,2)) + ~Z;
       % mu_h = S./T;
       % ExpectedMeans(Is) = (ExpectedMeans(Is)*T(Is) + reward)./(T(Is)+1);
        mu(k(t,1),k(t,2)) = (S(k(t,1),k(t,2)))./T(k(t,1),k(t,2));
        
        T_exp = T/t;
        
        
        %% Compute regret
        regret(t) = sum((max(Env1_1.*Env1_2)*max(Env2) - (Env1_1.*Env1_2)'.*Env2).*T, 'all');
        %regret(t) = (t*max(Env1_1.*Env1_2)*max(Env2)) - sum(reward);
        %{
        if t>1
            regret(t) = regret(t-1) + (max(Env1_1)*max(Env1_2)*max(Env2) - Env1_1(k(t,1))*Env1_2(k(t,1))*Env2(k(t,2)));
            %regret(t) = regret(t-1) + sum((max(Env1_1.*Env1_2)*max(Env2) - Env).*T, 'all')/t;
            %regret(t) = regret(t-1) + (max(Env1_1.*Env1_2)*max(Env2) - mean(reward,2));
            %regret(t) = (t*max(Env1_1.*Env1_2)*max(Env2)) - sum(reward);
        else
            regret(1) = (max(Env1_1)*max(Env1_2)*max(Env2) - Env1_1(k(t,1))*Env1_2(k(t,1))*Env2(k(t,2)));
            %regret(1) = sum((max(Env1_1.*Env1_2)*max(Env2) - Env).*T, 'all')/t;
            %regret(1) = max(Env1_1.*Env1_2)*max(Env2) - mean(reward,2);
            %regret(t) = t*max(Env1_1.*Env1_2)*max(Env2) - sum(reward);
        end
        %}
        end
    end
    
    for t = K1*K2+1:Time
        
        
        %if t > 1
        [~,L_temp] = max(mu, [], 'all', 'linear');
        [L(t,1),L(t,2)] = ind2sub([K1,K2],L_temp);
        % end

        l(L(t,1),L(t,2)) = l(L(t,1),L(t,2)) + 1;

        if L(t,1)>1 && L(t,1)<K1
            N1 = [(L(t,1)-1):(L(t,1)+1)];
        elseif L(t,1)==K1
            N1 = [L(t,1)-1 L(t,1)];
        else
            N1 = [L(t,1) L(t,1)+1];
        end
        
        if L(t,2)>1 && L(t,2)<K2
            N2 = [(L(t,2)-1):(L(t,2)+1)];
        elseif L(t,2)==K2
            N2 = [L(t,2)-1 L(t,2)];
        else
            N2 = [L(t,2) L(t,2)+1];
        end

        % Threshold for determining to choose current leader or not
        sl = (l(L(t,1),L(t,2))-1)/(gamma+1);
        %sl = (l(L(t)))/(gamma+1);
        
        %if sl>=1 && floor(sl)==sl
        %    k(t,:) = L(t,:);
        %else
            S_N = S(N1,N2);  F_N = F(N1,N2);
            T_N = T(N1,N2);  mu_N = mu(N1,N2);
            
            switch alg
                case "KLUCB"
                    k_temp = F_KLUCB(mu_N(:),T_N(:),l(L(t,1),L(t,2)));
                case "UCB"
                    k_temp = F_UCB(mu_N(:),T_N(:),1/(Time)^2);
                case "TS"
                    k_temp = F_TS(S_N(:),F_N(:));
                case "AdaUCB"
                    k_temp = F_AdaUCB(mu_N(:),T_N(:),Time);
            end
            
            [k1,k2] = ind2sub([length(N1),length(N2)],k_temp);
            k(t,1) = N1(1)-1+k1;
            k(t,2) = N2(1)-1+k2;
            
            %k(t) = F_DTS(S1,S2,F1,F2);
            %k(t) = N(1)-1+F_DTS(S1(N),S2(N),F1(N),F2(N));
        %end
        
        X = rand() < Env1_1(k(t,1));
        Y = rand() < Env1_2(k(t,1))*Env2(k(t,2));
        Z = X*Y;

        reward = [reward Z];


        T(k(t,1),k(t,2)) = T(k(t,1),k(t,2)) + 1;


        S(k(t,1),k(t,2)) = S(k(t,1),k(t,2)) + Z;
        F(k(t,1),k(t,2)) = F(k(t,1),k(t,2)) + ~Z;

        mu(k(t,1),k(t,2)) = S(k(t,1),k(t,2))./T(k(t,1),k(t,2));
        
        tend = toc;
        timer = [timer tend];
        
        
        %% Compute Regret
        asympregret(t) = max(Env1_1.*Env1_2)*max(Env2) - Env1_1(k(t,1))*Env1_2(k(t,1))*Env2(k(t,2));
        
        regret(t) = sum((max(Env1_1.*Env1_2)*max(Env2) - (Env1_1.*Env1_2)'.*Env2).*T, 'all');
        %regret(t) = (t*max(Env1_1.*Env1_2)*max(Env2)) - sum(reward);

        %regret(t) = regret(t-1) + (max(Env1_1.*Env1_2)*max(Env2) - Env1_1(k(t,1))*Env1_2(k(t,1))*Env2(k(t,2)));
        %regret(t) = regret(t-1) + sum((max(Env1_1.*Env1_2)*max(Env2) - Env).*T , 'all')/t;
        %regret(t) = regret(t-1) + (max(Env1_1.*Env1_2)*max(Env2) - mean(reward,2));
        
    end
end