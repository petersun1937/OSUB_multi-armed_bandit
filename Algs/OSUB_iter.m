function [reward, regret, asympregret, k, timer] = OSUB_iter(Env1_1, Env1_2, Env2, gamma, Time, alg)
    
    Env = (Env1_1.*Env1_2)'.*Env2;

    K1 = length(Env1_1);    K2 = length(Env2);
    L = zeros(Time,2);  %L(1) = randi(K);
    mu = zeros(K1,K2); mu1 = zeros(K1,K2);
    l = zeros(K1,K2);
    T = zeros(K1,K2);  
    S = zeros(K1,K2);    F = zeros(K1,K2);
    S1 = zeros(K1,K2);    F1 = zeros(K1,K2);
    S2 = zeros(K1,K2);  F2 = zeros(K1,K2);
    reward = [];    %SelectedArm = [];
    asympregret = zeros(1,Time);
    regret = zeros(1,Time);
    
    k = [];
    
    %regret = [];
    timer = [];         % timer
    
    
    tic;
    t=0;
    init_k = ceil(K1/2);
    for i=1:K2
            
            k = [k; init_k i];
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
           % Empirical reward
            mu(k(t,1),k(t,2)) = (S(k(t,1),k(t,2)))./T(k(t,1),k(t,2));



            %% Compute regret
            delta_k = max(Env1_1.*Env1_2)*max(Env2) - (Env1_1.*Env1_2)'.*Env2;
            regret(t) = sum((delta_k).*T, 'all');
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
    
   % [~,opt_b] = max(mu(init_k,:));
    
    for t = K2*round(log(Time))+1:Time
        
        
        %if t > 1
        [~,L_temp] = max(mu, [], 'all', 'linear');
        [L(t,1),L(t,2)] = ind2sub([K1,K2],L_temp);
        % end
        l(L(t,1),L(t,2)) = l(L(t,1),L(t,2)) + 1;
        
        if L(t,1)>1 && L(t,1)<K1
            N1 = [(L(t,1)-1):(L(t,1)+1)];
            corner1 = [1 3];
        elseif L(t,1)==K1
            N1 = [L(t,1)-1:L(t,1)];
            corner1 = [1];
        else
            N1 = [L(t,1):L(t,1)+1];
            corner1 = [2];
        end

        if L(t,2)>1 && L(t,2)<K2
            N2 = [(L(t,2)-1):(L(t,2)+1)];
            corner2 = [1 3];
        elseif L(t,2)==K2
            N2 = [L(t,2)-1 L(t,2)];
            corner2 = [1];
        else
            N2 = [L(t,2) L(t,2)+1];
            corner2 = [2];
        end
        
        

        % Threshold for determining to choose current leader or not
        sl = (l(L(t,1),L(t,2))-1)/(gamma+1);
        %sl = (l(L(t)))/(gamma+1);
        
        if sl>=1 && floor(sl)==sl
            k(t,:) = L(t,:);
        else

            
            
        switch alg
        case "KLUCB"
            k(t) = N(1)-1+F_KLUCB(mu(N),T(N),l(L(t)));
        case "UCB"
            k(t) = N(1)-1+F_UCB(mu(N),T(N),1/(Time)^2);
        case "TS"
            k(t) = N(1)-1+F_TS(S(N),F(N));
        case "AdaUCB"
            k(t) = N(1)-1+F_AdaUCB(mu(N),T(N),Time);
        end
            
            
            
        end
        
        X = rand() < Env1_1(k(t,1));
        Y = rand() < Env1_2(k(t,1))*Env2(k(t,2));
        Z = X*Y;

        reward = [reward Z];


        T(k(t,1),k(t,2)) = T(k(t,1),k(t,2)) + 1;


        S1(k(t,1),k(t,2)) = S1(k(t,1),k(t,2)) + Z;
        S2(k(t,1),k(t,2)) = S2(k(t,1),k(t,2)) + Y;
        F1(k(t,1),k(t,2)) = F1(k(t,1),k(t,2)) + ~X;
        F2(k(t,1),k(t,2)) = F2(k(t,1),k(t,2)) + ~Y;

        mu1(k(t,1),k(t,2)) = S1(k(t,1),k(t,2))./T(k(t,1),k(t,2));
        mu2(k(t,1),k(t,2)) = (S2(k(t,1),k(t,2)))./T(k(t,1),k(t,2));
        
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