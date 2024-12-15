function [reward, regret, asympregret, d, timer] = OSUB_multi_phase(Env1, Env2, gamma, Time, alg, n1, n2)


    Env = Env1'.*Env2;
    K1 = length(Env1);    K2 = length(Env2);
    
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
    %m = round(log(Time)); % exploration time: ceil(log(log(Time))) or round(log(Time)))
    m = 1;
    
    for ii= 1:K2
        for j=1:K1
            for tt=1:m
            i = [i;ii];
            k = [k; j];
            t=t+1;

            X = rand() < Env1(k(t));
            Y = rand() < Env2(k(t),i(t));
            Z = X*Y;

            reward = [reward Z];

            T(k(t),i(t)) = T(k(t),i(t)) + 1;

            S(k(t),i(t)) = S(k(t),i(t)) + Z;
            F(k(t),i(t)) = F(k(t),i(t)) + ~Z;
           % mu_h = S./T;
           % ExpectedMeans(Is) = (ExpectedMeans(Is)*T(Is) + reward)./(T(Is)+1);
            mu(k(t),i(t)) = (S(k(t),i(t)))./T(k(t),i(t));

            % For two-level feedback
            S1(k(t),i(t)) = S1(k(t),i(t)) + X;
            S2(k(t),i(t)) = S2(k(t),i(t)) + Y;
            F1(k(t),i(t)) = F1(k(t),i(t)) + ~X;
            F2(k(t),i(t)) = F2(k(t),i(t)) + ~Y;

            mu1(k(t),i(t)) = S1(k(t),i(t))./T(k(t),i(t));
            mu2(k(t),i(t)) = S2(k(t),i(t))./T(k(t),i(t));
            
            
            %% Compute regret
            regret(t) = sum((max(Env,[],'all') - Env).*T, 'all');
            end
        end
    end
    explr_t = K1*K2*m;
    n1 = n1+explr_t;
    n2 = n2+explr_t;
    
    [Lmax,L_temp] = max(mu, [], 'all', 'linear');
    %mI = find(mu == Lmax);
    %L_temp = mI(randi(length(mI)));
    [k(explr_t+1),i(explr_t+1)] = ind2sub([K1,K2],L_temp);
   % [~,opt_b] = max(mu(init_k,:));
    
    phase1 = true;
   
    for t = explr_t+1:Time
    
        if(ismember(t,n2) && ~phase1)
            phase1 = true;
            %[~,k(t)] = max(mu(:,i(length(i))), [], 'all', 'linear');
            [~,L_temp] =  max((mu), [], 'all', 'linear');
            %[k(t),~] = ind2sub([K1,K2],L_temp);
            k(t) = k(length(k));    % Fix rate (assigned earlier after exploration) 
            [k(t),~] = max(T(:,i(t-1)));   % Fix the rate selected the most
            
        elseif(ismember(t,n1) && phase1)
            phase1 = false;
            %[~,i(t)] = max(mu(k(length(k)),:), [], 'all', 'linear');
            [~,L_temp] = max((mu), [], 'all', 'linear');
            %[~,i(t)] = ind2sub([K1,K2],L_temp);
            
            [~,i(t)] = max(T(k(t-1),:));   % Fix the beam selected the most
            %i(t) = i(length(i));
        end
        

            
        if(phase1)      % Check if it should enter phase 1 or not
            %% Phase 1 (OSUB on beam selection)
            
            %if t > 1
            [Lmax,~] = max(mu(k(length(i)),:), [], 'all', 'linear');
            mI = find(mu(k(length(i)),:) == Lmax);
            L(t,2) = mI(randi(length(mI)));
            %[~,L(t,2)] = ind2sub([K1,K2],L_temp);
            % end
            
            % fix k 
            k(t) = k(length(k));        % Keep selecting the fixed rate
            
            l(k(t),L(t,2)) = l(k(t),L(t,2)) + 1;
            
            % Condition for choosing current leader or not
            sl = (l(k(t),L(t,2))-1)/(gamma+1);
            %sl = (l(L(t)))/(gamma+1);
            
            %% OSUB on beam selection
            
            if sl>=1 && floor(sl)==sl
                i(t) = L(t,2);
            else
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

                S_N = S(k(t),N2);  F_N = F(k(t),N2);
                T_N = T(k(t),N2);  mu_N = mu(k(t),N2);


                switch alg
                case "KLUCB"
                    i(t) = N2(1)-1+F_KLUCB(mu(k(t),N2),T(k(t),N2),l(k(t),L(t,2)));
                case "UCB"
                    i(t) = N2(1)-1+F_UCB(mu(k(t),N2),T(k(t),N2),1/(t)^2);
                case "TS"
                    i(t) = N2(1)-1+F_TS(S(k(t),N2),F(k(t),N2));
                end

            end
        else
            %% Phase 2 (algorithm on rate selection)
            
            i(t) = i(length(i));        % Keep selecting the fixed beam
            
            switch alg
                case "KLUCB"
                    k(t) = F_KLUCB(mu(:,i(t)),T(:,i(t)),t);
                case "UCB"
                    k(t) = F_UCB(mu(:,i(t)),T(:,i(t)),1/(t)^2);
                case "TS"
                    k(t) = F_TS(S(:,i(t)),F(:,i(t)));
            end
            %}
            %{
            switch alg
                case "KLUCB"
                    k(t) = F_KLUCB_2lv(mu1(:,i(t)),mu2(:,i(t)),T(:,i(t)),t);
                case "UCB"
                    k(t) = F_UCB_2lv(mu1(:,i(t)),mu2(:,i(t)),T(:,i(t)),1/(Time)^2);
                case "TS"
                    k(t) = F_TS_2lv(S1(:,i(t)),S2(:,i(t)),F1(:,i(t)),F2(:,i(t)));
            end
            %}
            %L(t,2) or i(t)?
 

        end
        
        
        X = rand() < Env1(k(t));
        Y = rand() < Env2(k(t),i(t));
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
        
        
        %% Compute Regret
        %asympregret(t) = max(Env1_1.*Env1_2)*max(Env2) - Env1_1(k(t))*Env1_2(k(t))*Env2(i(t));
        
        regret(t) = sum((max(Env,[],'all') - Env).*T, 'all');
        %regret(t) = (t*max(Env1_1.*Env1_2)*max(Env2)) - sum(reward);

        %regret(t) = regret(t-1) + (max(Env1_1.*Env1_2)*max(Env2) - Env1_1(k(t,1))*Env1_2(k(t,1))*Env2(k(t,2)));
        %regret(t) = regret(t-1) + sum((max(Env1_1.*Env1_2)*max(Env2) - Env).*T , 'all')/t;
        %regret(t) = regret(t-1) + (max(Env1_1.*Env1_2)*max(Env2) - mean(reward,2));
        
    end

    d = [k i];
   
end