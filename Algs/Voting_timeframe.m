function [reward, regret, asympregret, d, timer] = Voting_timeframe(Env1, Env2, Time, alg, frame)


    Env = Env1'.*Env2;
    K1 = length(Env1);    K2 = length(Env2);
    
    %Li = zeros(Time,1);  %L(1) = randi(K);
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
    
    b_voted = zeros(K1,1); 
    
    i = [];
    k = [];
    
    timer = [];         % timer
    
    %% Initialization
    tic;

    % Exploration time
    m = 1;
    t=0;
    for k1= 1:K2
        for k2=1:K1
            for tt=1:m
                
            i = [i; k1];
            k = [k; k2];
            t=t+1;

            % Observe outome
            X = rand() < Env1(k(t));
            Y = rand() < Env2(k(t),i(t));
            Z = X*Y;

            reward = [reward Z];

            % Update records
            T(k(t),i(t)) = T(k(t),i(t)) + 1;
            
            S(k(t),i(t)) = S(k(t),i(t)) + Z;
            F(k(t),i(t)) = F(k(t),i(t)) + ~Z;
            mu(k(t),i(t)) = (S(k(t),i(t)))./T(k(t),i(t));

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
    explr_t = K1*K2*m;      % Exploration time
    
    % Compute weight from initialization (for the first voting)
    switch alg
        case "KLUCB"
            [~,wv] = F_KLUCB(mu(:),T(:),t);
        case "UCB"
            [~,wv] = F_UCB(mu(:),T(:),1/(t)^2);
        case "TS"
            [~,wv] = F_TS(S(:),F(:));
    end
    w = reshape(wv,[K1,K2]);
    
    
    for t = explr_t+1:Time
        
        %% Start frame (vote and fix beam)
        % If current time (subtracted exploration time) is a multiple
        % of frame size, start voting
        if(rem(t-explr_t,frame)==1)
            % Each portion size votes for one beam
            for k2= 1:K1
                [~,b_voted(k2)] = max(w(k2,:));
            end
            
            % Check if (t+frame size) exceeeds horizon
            if (t+frame)>Time
                frame = Time-t;
            end

            % Fix the most voted beam (mode)
            [i(t:t+frame), ~, uniqmod] = mode(b_voted,1);
            % If the mode is not unique, select randomly instead
            if (~iscell(uniqmod))
                i(t:t+frame) = b_voted(randi([1 length(b_voted)]));
            end
        end
        

        %% Algorithm on rate selection

        switch alg
            case "KLUCB"
                [k(t),wv] = F_KLUCB(mu(:,i(t)),T(:,i(t)),t);
            case "UCB"
                [k(t),wv] = F_UCB(mu(:,i(t)),T(:,i(t)),1/(t)^2);
            case "TS"
                [k(t),wv] = F_TS(S(:,i(t)),F(:,i(t)));
        end
        %}
        
        % Update weight 
        w(:,i(t)) = wv;
        
        % Observe outome
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
        
        regret(t) = sum((max(Env,[],'all') - Env).*T, 'all');
        
    end
    
    d = [k i];
   
end