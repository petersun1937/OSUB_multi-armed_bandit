function [reward, regret, T_path, k, timer] = Classic_2dim(Env1, Env2, Time, alg)
    Env = (Env1)'.*Env2;
    % HF: horizon free
        K1 = length(Env1);    K2 = length(Env2);
        %L = zeros(Time,2);  %L(1) = randi(K);
        mu = zeros(K1,K2);
        l = zeros(K1,K2);
        T = zeros(K1,K2);  S = zeros(K1,K2);    F = zeros(K1,K2);
        reward = [];    %SelectedArm = [];
        %asympregret = zeros(1,Time);
        T_path = [];
        regret = zeros(1,Time);

        k = [];

        %regret = [];
        timer = [];         % timer
        t=0;
    for i= 1:K1
        for j=1:K2

        k = [k; i j];
        t=t+1;

        X = rand() < Env1(k(t,1));
        Y = rand() < Env2(k(t,1),k(t,2));
        Z = X*Y;

        reward = [reward Z];

        T(k(t,1),k(t,2)) = T(k(t,1),k(t,2)) + 1;

        S(k(t,1),k(t,2)) = S(k(t,1),k(t,2)) + Z;

        
        T_path = [T_path T(1)];
        
       % mu_h = S./T;
       % ExpectedMeans(Is) = (ExpectedMeans(Is)*T(Is) + reward)./(T(Is)+1);
        mu(k(t,1),k(t,2)) = (S(k(t,1),k(t,2)))./T(k(t,1),k(t,2));

        %% Compute regret
        regret(t) = sum((max(Env1)*max(Env2) - (Env1)'.*Env2).*T, 'all');
        %regret(t) = (t*max(Env1_1.*Env1_2)*max(Env2)) - sum(reward);

        end
    end


    for t = K1*K2+1:Time
        tic;
        switch alg
            case "KLUCB"
                [k_temp] = F_KLUCB(mu(:),T(:),t);
            case "UCB"
                k_temp = F_UCB(mu(:),T(:),1/(t));
            case "TS"
                k_temp = F_TS(S(:),F(:));
        end

        [k(t,1),k(t,2)] = ind2sub([K1,K2],k_temp);

        % Observe the random outcome
        X = rand() < Env1(k(t,1));
        Y = rand() < Env2(k(t,1),k(t,2));
        Z = X*Y;

        %[ExpectedMeans, NbrPlayArm, gainKLUCB, ArmsPlayed]= UCB1_ReceiveReward(ExpectedMeans, NbrPlayArm, reward, ArmToPlay, gainKLUCB, ArmsPlayed); % Update UCB parameters using the reward received at time t.
        reward = [reward Z];
        T(k(t,1),k(t,2)) = T(k(t,1),k(t,2)) + 1;

        S(k(t,1),k(t,2)) = S(k(t,1),k(t,2)) + Z;
        F(k(t,1),k(t,2)) = F(k(t,1),k(t,2)) + ~Z;

        mu(k(t,1),k(t,2)) = S(k(t,1),k(t,2))./T(k(t,1),k(t,2));
        
        
        %regret(trial,t) = regret(trial,t-1) + sum((max(Env)- mu)*(T_exp));

        tend = toc;
        timer = [timer tend];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        T_path = [T_path T(1,11)];
        
        %% Compute Cumulative Regret
        %asympregret(t) = max(Env1)*max(Env2, [], 'all') - Env1(k(t,1))*Env2(k(t,1),k(t,2));
        
        regret(t) = sum((max(Env,[],'all') - Env).*T, 'all');
        %regret(t) = sum((max(Env1,[],'all')*max(Env2,[],'all') - (Env1)'.*Env2).*T, 'all');

    end

end