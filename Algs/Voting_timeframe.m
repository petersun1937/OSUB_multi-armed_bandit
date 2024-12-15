function [reward, regret, T_path, T_path2, d, timer, fixedbeams] = Voting_timeframe(Env1, Env2, Time, alg, frame)


    Env = Env1'.*Env2;
    K1 = size(Env,1);    K2 = size(Env,2);
    
    %Li = zeros(Time,1);  %L(1) = randi(K);
    mu = zeros(K1,K2); mu1 = zeros(K1,K2);
    mu2 = zeros(K1,K2);
    l = zeros(K1,K2);
    T = zeros(K1,K2);  
    S = zeros(K1,K2);    F = zeros(K1,K2);
    S1 = zeros(K1,K2);    F1 = zeros(K1,K2);
    S2 = zeros(K1,K2);  F2 = zeros(K1,K2);
    reward = [];    %SelectedArm = [];
    T_path = []; T_path2 = [];
    
    t_i = ones(1,K2);
    regret = zeros(1,Time);
    
    b_voted = zeros(K1,1); 
    fixedbeams = [];
    
    i = [];
    k = [];
    
    timer = [];         % timer
    
    %% Initialization
    tic;

    % Exploration time
    m = 1;
    t=0;
    for k2= 1:K2
        for j=1:K1
            for tt=1:m
                
            i = [i; k2];
            k = [k; j];
            t=t+1;

            % Observe outome
            X = rand() < Env1(k(t));
            Y = rand() < Env2(k(t),i(t));
            Z = X*Y;

            reward = [reward Z];

            % Update records
            
            T(k(t),i(t)) = T(k(t),i(t)) + 1;
            
            t_i(i(t)) =  t_i(i(t))+1;
            
            %%%%%%%%%%%%%%%%%%%%    
            T_path = [T_path T(1,4)];
            T_path2 = [T_path2 T(2,4)];
            
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
            [~,w] = F_KLUCB(mu(:),T(:),t);
        case "UCB"
            [~,w] = F_UCB(mu(:),T(:),1/(t));
        case "TS"
            [~,w] = F_TS(S(:),F(:));
    end
    w = reshape(w,[K1,K2]);
    
    
    for t = explr_t+1:Time
        
        %% Start frame (vote and fix beam)
        % If current time (subtracted exploration time) is a multiple
        % of frame size, start voting
        if(rem(t-explr_t,frame)==1)
            
            S_i = sum(S);
            mu_i = S_i./t_i;
            
            
            for ii=1:K2
                switch alg
                    case "KLUCB"
                        [~,wv] = F_KLUCB(mu(:,ii),T(:,ii),t);
                        %[~,wv] = F_KLUCB(mu(:,ii),T(:,ii),t_i(ii));    %*
                    case "UCB"
                        [~,wv] = F_UCB(mu(:,ii),T(:,ii),1/(t));
                        %[~,wv] = F_UCB(mu(:,ii),T(:,ii),1/(t_i(ii)) ); %*
                    case "TS"
                        [~,wv] = F_TS(S(:,ii),F(:,ii));
                end
                w_i(:,ii) = wv;
            end

            % Max sum weight %%%%%%%%%%%%
            
            sumw = zeros(1,K2);
            for k2= 1:K2 
                sumw(k2) = sum(w_i(:,k2), 'all');
                mw = max(sumw,[],'all');
                mI = find(sumw == mw);
                b_voted = mI(randi(length(mI)));
            end
            %}
            
            
            % Majority Voting: Each portion size votes for one beam %%%%
            %{
            for j= 1:K1 
                [~,b_voted(j)] = max(w(j,:));
                    mw = max(w(j,:));
                    mI = find(w(j,:) == mw);
                    b_voted(j) = mI(randi(length(mI)));
            end
            %}
            
            
            % Modified beam weight %%%%%%%%
            %{
            switch alg
                case "KLUCB"
                    [b_voted, ~] = F_KLUCBi(mu,T,t);
                case "UCB"
                    [b_voted, ~, ~, nu] = F_UCBi(mu,T,1/(t));
            end
            %}
            
            % Check if (t+frame size) exceeeds horizon
            if (t+frame+1)>Time
                frame = Time-t;
            end

            % Fix the most voted beam (mode)
            [fixedbeam, ~, uniqmod] = mode(b_voted,1);
            % If the mode is not unique (same votes), select randomly instead
            if (~iscell(uniqmod))
                fixedbeam = b_voted(randi([1 length(b_voted)]));
            end
            
            fixedbeams = [fixedbeams; fixedbeam];
            i(t:t+frame) = fixedbeam;
        end
        
        

        %% Algorithm on rate selection
        
        switch alg
            case "KLUCB"
                [k(t),wv] = F_KLUCB(mu(:,i(t)),T(:,i(t)),t);
                %[k(t),wv] = F_KLUCB(mu(:,i(t)),T(:,i(t)),t_i(i(t)));
            case "UCB"
                [k(t),wv] = F_UCB(mu(:,i(t)),T(:,i(t)),1/(t));
                %[k(t),wv] = F_UCB(mu(:,i(t)),T(:,i(t)),1/(t_i(i(t))) );
            case "TS"
                [k(t),wv] = F_TS(S(:,i(t)),F(:,i(t)));
        end
        %}
        
        %% Two-Level
        %{
        switch alg
            case "KLUCB"
                [~,wv] = F_KLUCB(mu2(:,i(t)),T(:,i(t)),t);
            case "UCB"
                [~,wv] = F_UCB(mu2(:,i(t)),T(:,i(t)),1/(t));
            case "TS"
                [~,wv] = F_TS(S2(:,i(t)),F2(:,i(t)));
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
        
        t_i(i(t)) =  t_i(i(t))+1;
        
        %%%%%%%%%%%%%%%%%%%%
        %T_path = [T_path T(1,11)];
        %T_path2 = [T_path2 T(3,11)];
        
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