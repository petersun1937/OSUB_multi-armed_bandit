function [reward, regret, asympregret, i, timer] = OSUB_two_phase(Env1_1, Env1_2, Env2, gamma, Time, alg)
    
    Env = (Env1_1.*Env1_2)'.*Env2;

    K1 = length(Env1_1);    K2 = length(Env2);
    Li = zeros(Time,1);  %L(1) = randi(K);
    mu = zeros(K1,K2); mu1 = zeros(K1,K2);
    mu2 = zeros(K1,K2);
    l = zeros(K1,K2);
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
    logn = round(log(Time));
    
    for ii= 1:K2
        for j=1:K1
            for tt=1:3
        i = [i;ii];
        k = [k; j];
        t=t+1;

        X = rand() < Env1_1(k(t));
        Y = rand() < Env1_2(k(t))*Env2(i(t));
        Z = X*Y;
        
        reward = [reward Z];

        T(k(t),i(t)) = T(k(t),i(t)) + 1;

        S(k(t),i(t)) = S(k(t),i(t)) + Z;
        F(k(t),i(t)) = F(k(t),i(t)) + ~Z;
       % mu_h = S./T;
       % ExpectedMeans(Is) = (ExpectedMeans(Is)*T(Is) + reward)./(T(Is)+1);
        mu(k(t),i(t)) = (S(k(t),i(t)))./T(k(t),i(t));
        
        
        
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
    end
    
   % [~,opt_b] = max(mu(init_k,:));
    
    for t = K1*K2+1:Time/2
    
        %if t > 1
        [~,L_temp] = max(mu, [], 'all', 'linear');
        [L(t,1),L(t,2)] = ind2sub([K1,K2],L_temp);
        % end

        l(L(t,1),L(t,2)) = l(L(t,1),L(t,2)) + 1;
        % Condition for choosing current leader or not
        sl = (l(L(t,1),L(t,2))-1)/(gamma+1);
        %sl = (l(L(t)))/(gamma+1);
        k(t) = L(t,1);
        
        if sl>=1 && floor(sl)==sl
            i(t) = L(t,2);
        else
        %{
            if L(t,1)>1 && L(t,1)<K1
                N1 = [(L(t,1)-1):(L(t,1)+1)];
                %corner1 = [1 3];
            elseif L(t,1)==K1
                N1 = [L(t,1)-1:L(t,1)];
                %corner1 = [1];
            else
                N1 = [L(t,1):L(t,1)+1];
                %corner1 = [2];
            end
        %}
            if L(t,2)>1 && L(t,2)<K2
                N2 = [(L(t,2)-1):(L(t,2)+1)];
                %corner2 = [1 3];
            elseif L(t,2)==K2 && K2~=1
                N2 = [L(t,2)-1 L(t,2)];
                %corner2 = [1];
            elseif K2==1
                N2 = 1;
            else
                N2 = [L(t,2) L(t,2)+1];
                %corner2 = [2];
                
            end
        
            S_N = S(L(t,1),N2);  F_N = F(L(t,1),N2);
            T_N = T(L(t,1),N2);  mu_N = mu(L(t,1),N2);
        
        
        %% OSUB on beam selection
  
            switch alg
            case "KLUCB"
                i(t) = N2(1)-1+F_KLUCB(mu(L(t,1),N2),T(L(t,1),N2),l(L(t,1),L(t,2)));
            case "UCB"
                i(t) = N2(1)-1+F_UCB(mu(L(t,1),N2),T(L(t,1),N2),1/(Time)^2);
            case "TS"
                i(t) = N2(1)-1+F_TS(S(L(t,1),N2),F(L(t,1),N2));
            end

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
    
    
    for t = Time/2+1:Time
        i(t) = i(Time/2);
        %% 2-lvl feedback algorithm on rate selection
        switch alg
            case "KLUCB"
                k(t) = F_KLUCB_2lv(mu1(:,i(t)),mu2(:,i(t)),T(:,i(t)),t);
            case "UCB"
                k(t) = F_UCB_2lv(mu1(:,i(t)),mu2(:,i(t)),T(:,i(t)),1/(Time)^2);
            case "TS"
                k(t) = F_TS_2lv(S1(:,i(t)),S2(:,i(t)),F1(:,i(t)),F2(:,i(t)));
        end
        %L(t,2) or i(t)?
        
        %% Compute Regret
        asympregret(t) = max(Env1_1.*Env1_2)*max(Env2) - Env1_1(k(t))*Env1_2(k(t))*Env2(i(t));
        
        regret(t) = sum((max(Env1_1.*Env1_2)*max(Env2) - (Env1_1.*Env1_2)'.*Env2).*T, 'all');
        
        
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
        
    end
end