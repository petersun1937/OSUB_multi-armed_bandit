function [reward, regret, asympregret, i, timer] = OSUB_iter(Env1_1, Env1_2, Env2, gamma, Time, alg)
    
    Env = (Env1_1.*Env1_2)'.*Env2;

    K1 = length(Env1_1);    K2 = length(Env2);
    Li = zeros(Time,1);  %L(1) = randi(K);
    mu = zeros(K1,K2); mu1 = zeros(K1,K2);
    mu2 = zeros(K1,K2);
    l = zeros(1,K2);
    T = zeros(K1,K2);  
    S = zeros(K1,K2);    F = zeros(K1,K2);
    S1 = zeros(K1,K2);    F1 = zeros(K1,K2);
    S2 = zeros(K1,K2);  F2 = zeros(K1,K2);
    reward = [];    %SelectedArm = [];
    asympregret = zeros(1,Time);
    regret = zeros(1,Time);
    
    i = [];
    k = [];
    
    %regret = [];
    timer = [];         % timer
    
    %% initialization
    tic;
    t=0;
    init_k = ceil(K1/2);
    
    %for tt=1:round(log(Time))
    for j=1:K2
            
            t=t+1;
            
            % Pick every i with fixed k
            i = [i; j];
            k = [k; init_k];
            
            
            X = rand() < Env1_1(k(t));
            Y = rand() < Env1_2(k(t))*Env2(i(t));
            Z = X*Y;

            reward = [reward Z];

            T(k(t),i(t)) = T(k(t),i(t)) + 1;

            S(k(t),i(t)) = S(k(t),i(t)) + Z;
            F(k(t),i(t)) = F(k(t),i(t)) + ~Z;
           % mu_h = S./T;
           % ExpectedMeans(Is) = (ExpectedMeans(Is)*T(Is) + reward)./(T(Is)+1);
           % Empirical reward
            mu(k(t),i(t)) = (S(k(t),i(t)))./T(k(t),i(t));


            % For two-level feedback
            S1(k(t),i(t)) = S1(k(t),i(t)) + X;
            S2(k(t),i(t)) = S2(k(t),i(t)) + Y;
            F1(k(t),i(t)) = F1(k(t),i(t)) + ~X;
            F2(k(t),i(t)) = F2(k(t),i(t)) + ~Y;

            mu1(k(t),i(t)) = S1(k(t),i(t))./T(k(t),i(t));
            mu2(k(t),i(t)) = S2(k(t),i(t))./T(k(t),i(t));
            
            %% Compute regret
            delta_k = max(Env1_1.*Env1_2)*max(Env2) - (Env1_1.*Env1_2)'.*Env2;
            regret(t) = sum((delta_k).*T, 'all');
            %regret(t) = (t*max(Env1_1.*Env1_2)*max(Env2)) - sum(reward);
    end
    %end
    mI = find(mu(init_k,:) == max(mu(init_k,:)));
    init_i = mI(randi(length(mI)));         % Randomly pick one of the max
    %[~,init_i] = max(mu(init_k,:));
    
    %for tt=1:round(log(Time))
    for j=1:K1
            
            t=t+1;
            
            % Pick every k with fixed i
            i = [i; init_i];
            k = [k; j];
            
            
            X = rand() < Env1_1(k(t));
            Y = rand() < Env1_2(k(t))*Env2(i(t));
            Z = X*Y;

            reward = [reward Z];

            T(k(t),i(t)) = T(k(t),i(t)) + 1;

            S(k(t),i(t)) = S(k(t),i(t)) + Z;
            F(k(t),i(t)) = F(k(t),i(t)) + ~Z;
           % mu_h = S./T;
           % ExpectedMeans(Is) = (ExpectedMeans(Is)*T(Is) + reward)./(T(Is)+1);
           % Empirical reward
            mu(k(t),i(t)) = (S(k(t),i(t)))./T(k(t),i(t));

            % For two-level feedback
            S1(k(t),i(t)) = S1(k(t),i(t)) + X;
            S2(k(t),i(t)) = S2(k(t),i(t)) + Y;
            F1(k(t),i(t)) = F1(k(t),i(t)) + ~X;
            F2(k(t),i(t)) = F2(k(t),i(t)) + ~Y;

            mu1(k(t),i(t)) = S1(k(t),i(t))./T(k(t),i(t));
            mu2(k(t),i(t)) = S2(k(t),i(t))./T(k(t),i(t));
        
            %% Compute regret
            delta_k = max(Env1_1.*Env1_2)*max(Env2) - (Env1_1.*Env1_2)'.*Env2;
            regret(t) = sum((delta_k).*T, 'all');
            %regret(t) = (t*max(Env1_1.*Env1_2)*max(Env2)) - sum(reward);
    end
    %end
    
   % [~,opt_b] = max(mu(init_k,:));
    
    for t = K1+K2+1:Time
    
        
        %if t > 1
        [~,Li_temp] = max(mu, [], 'all', 'linear');
        [~,Li(t)] = ind2sub([K1,K2],Li_temp);
        % end
        l(Li(t)) = l(Li(t)) + 1;
        
        if Li(t)>1 && Li(t)<K2
            N = [(Li(t)-1):(Li(t)+1)];
        elseif Li(t,1)==K2
            N = [Li(t)-1:Li(t)];
        else
            N = [Li(t):Li(t)+1];
        end
 
        % Threshold for determining to choose current leader or not
        sl = (l(Li(t))-1)/(gamma+1);
        %sl = (l(L(t)))/(gamma+1);
        
        %% OSUB on beam selection
        if sl>=1 && floor(sl)==sl
            i(t) = Li(t);
        else
            
            switch alg
            case "KLUCB"
                i(t) = N(1)-1+F_KLUCB(mu(k(t-1),N),T(k(t-1),N),l(Li(t)));
            case "UCB"
                i(t) = N(1)-1+F_UCB(mu(k(t-1),N),T(k(t-1),N),1/(t));
            case "TS"
                i(t) = N(1)-1+F_TS(S(k(t-1),N),F(k(t-1),N));
            end

        end
        
        %% 2-lvl feedback algorithm on rate selection
        switch alg
            case "KLUCB"
                k(t) = F_KLUCB_2lv(mu1(:,i(t)),mu2(:,i(t)),T(:,i(t)),t);
            case "UCB"
                k(t) = F_UCB_2lv(mu1(:,i(t)),mu2(:,i(t)),T(:,i(t)),1/(t));
            case "TS"
                k(t) = F_TS_2lv(S1(:,i(t)),S2(:,i(t)),F1(:,i(t)),F2(:,i(t)));
        end

        
        X = rand() < Env1_1(k(t));
        Y = rand() < Env1_2(k(t))*Env2(i(t));
        Z = X*Y;

        reward = [reward Z];


        T(k(t),i(t)) = T(k(t),i(t)) + 1;

        % Single feedback
        S(k(t),i(t)) = S(k(t),i(t)) + Z;
        F(k(t),i(t)) = F(k(t),i(t)) + ~Z;

        mu(k(t),i(t)) = S(k(t),i(t))./T(k(t),i(t));
        
        
        % For two-level feedback
        S1(k(t),i(t)) = S1(k(t),i(t)) + X;
        S2(k(t),i(t)) = S2(k(t),i(t)) + Y;
        F1(k(t),i(t)) = F1(k(t),i(t)) + ~X;
        F2(k(t),i(t)) = F2(k(t),i(t)) + ~Y;

        mu1(k(t),i(t)) = S1(k(t),i(t))./T(k(t),i(t));
        mu2(k(t),i(t)) = S2(k(t),i(t))./T(k(t),i(t));
        
        
        
        tend = toc;
        timer = [timer tend];
        
        
        
        
        %% Compute Regret
        asympregret(t) = max(Env1_1.*Env1_2)*max(Env2) - Env1_1(k(t))*Env1_2(k(t))*Env2(i(t));
        
        regret(t) = sum((max(Env1_1.*Env1_2)*max(Env2) - (Env1_1.*Env1_2)'.*Env2).*T, 'all');
        %regret(t) = (t*max(Env1_1.*Env1_2)*max(Env2)) - sum(reward);

        %regret(t) = regret(t-1) + (max(Env1_1.*Env1_2)*max(Env2) - Env1_1(k(t,1))*Env1_2(k(t,1))*Env2(k(t,2)));
        %regret(t) = regret(t-1) + sum((max(Env1_1.*Env1_2)*max(Env2) - Env).*T , 'all')/t;
        %regret(t) = regret(t-1) + (max(Env1_1.*Env1_2)*max(Env2) - mean(reward,2));
        
    end
    d = [k i];
end