function [reward, regret, asympregret, k, timer] = OSUB(Env, gamma, Time, alg)

    K = length(Env);
    L = zeros(Time,1);  %L(1) = randi(K);
    mu = zeros(1,K);
    l = zeros(1,K);
    T = zeros(1,K);  S = zeros(1,K);    F = zeros(1,K);
    reward = [];    %SelectedArm = [];
    regret = zeros(1,Time);
    asympregret = zeros(1,Time);

    timer = [];         % timer
    
    
    for t = 1:Time
        tic;
        
        
        if t < K+1
            k(t) = t;  % Or arms within the neighborhood of initial L(t)
        else

        
        %if t > 1
            [~,L(t)] = max(mu);
       % end
        
            l(L(t)) = l(L(t)) + 1;

            if L(t)>1 && L(t)<K
                N = [(L(t)-1):(L(t)+1)];
            elseif L(t)==K
                N = [L(t)-1 L(t)];
            else
                N = [L(t) L(t)+1];
            end
            
            % Threshold for determining to choose current leader or not
            sl = (l(L(t))-1)/(gamma+1);
            %sl = (l(L(t)))/(gamma+1);
            %if sl>=1 && floor(sl)==sl
            %    k(t) = L(t);
            %else
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
            %end
        end
        
    
        Z = rand() < Env(k(t));

        %[ExpectedMeans, NbrPlayArm, gainKLUCB, ArmsPlayed]= UCB1_ReceiveReward(ExpectedMeans, NbrPlayArm, reward, ArmToPlay, gainKLUCB, ArmsPlayed); % Update UCB parameters using the reward received at time t.
        reward = [reward Z];


        T(k(t)) = T(k(t)) + 1;


        %SelectedArm = [SelectedArm k(t)];


        S(k(t)) = S(k(t)) + Z;
        F(k(t)) = F(k(t)) + ~Z;
       % mu_h = S./T;
       % ExpectedMeans(Is) = (ExpectedMeans(Is)*T(Is) + reward)./(T(Is)+1);
        mu(k(t)) = (S(k(t)))./(T(k(t)));
        
        tend = toc;
        timer = [timer tend];
        
        %% Compute Cumulative Regret
        regret(t) = sum((max(Env) - Env).*T);
        %regret(t) = t*max(Env) - sum(reward);
        
        asympregret(t) =(max(Env) - Env(k(t)));
        
        %{
        if t>1
            %regret(t) = regret(t-1) + (max(Env) - Env(k(t))); 
            %regret(t) = (regret(t-1) + (max(Env) - mean(reward,2)));
            
        else
            %regret(1) = max(Env) - Env(k(t));
            %regret(t) = max(Env) - mean(reward,2);
            
        end
        %}
        

        
        %{
        Z_opt = rand() < Env(k_opt);
        S_opt = S_opt + Z_opt;
        
        mu_opt = S_opt/t;
        %mu_emp = S/t;
        if t>1
            %regret(t) = regret(t-1) + sum((mu_opt - mu_emp).*T_exp);
            regret(t) = regret(t-1) + (mu_opt - mean(reward,2));
        else
            %regret(1) = sum((mu_opt - mu_emp).*T_exp);
            regret(t) = mu_opt - mean(reward,2);
        end
        %}
        
    end
    
end