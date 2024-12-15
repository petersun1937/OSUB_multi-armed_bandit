function [reward, regret, T_path, T_path2, d, timer, fixedbeams] = Explr2_timeframe(Env1, Env2, Time, alg, n0, n1)


    Env = Env1'.*Env2;
    K1 = size(Env,1);    K2 = size(Env,2);
    
    %Li = zeros(Time,1);  %L(1) = randi(K);
    mu = zeros(K1,K2); mu1 = zeros(K1,K2);
    mu2 = zeros(K1,K2);
    mu_1 = zeros(K1,K2);
    T = zeros(K1,K2);  T_1 = zeros(K1,K2); 
    S_1 = zeros(K1,K2);
    S = zeros(K1,K2);    F = zeros(K1,K2);
    S1 = zeros(K1,K2);    F1 = zeros(K1,K2);
    S2 = zeros(K1,K2);  F2 = zeros(K1,K2);
    reward = [];    %SelectedArm = [];
    T_path = []; T_path2 = [];
    
    T_i = ones(1,K2);
    regret = zeros(1,Time);
    
    b_voted = zeros(K1,1); 
    fixedbeams = [];
    
    i = [];
    k = [];
    
    timer = [];         % timer
    
    %% Initialization
    tic;

    % Exploration time
    ex = 1;
    t=0;
    for k2= 1:K2
        for j1=1:K1
            for t1=1:ex
                
            i = [i; k2];
            k = [k; j1];
            t=t+1;

            % Observe outome
            X = rand() < Env1(k(t));
            Y = rand() < Env2(k(t),i(t));
            Z = X*Y;

            reward = [reward Z];

            % Update records
            
            T(k(t),i(t)) = T(k(t),i(t)) + 1;
            
            T_i(i(t)) =  T_i(i(t))+1;
            
            %%%%%%%%%%%%%%%%%%%%    
            T_path = [T_path T(1,4)];
            T_path2 = [T_path2 T(2,4)];
            
            S(k(t),i(t)) = S(k(t),i(t)) + Z;
            F(k(t),i(t)) = F(k(t),i(t)) + ~Z;
            mu(k(t),i(t)) = (S(k(t),i(t)))./T(k(t),i(t));

            T_1(k(t),i(t)) =  T_1(k(t),i(t))+1;
            S_1(k(t),i(t)) = S_1(k(t),i(t)) + Z;
            mu_1(k(t),i(t)) = S_1(k(t),i(t))./T_1(k(t),i(t));
            
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
    
    m1=0; % Frame counter for phase 1
    j1=1;
    for t = K1*K2*ex+1:Time
        
        %% Start frame (vote and fix beam)
        % If current time (subtracted exploration time) is a multiple
        % of frame size, start voting
        if(rem(t-K1*K2*ex,n0)==1)
            
            
            if (m1<=n1)
                phase1 = true;
                m1=m1+1;
            else
                phase1 = false;
            end
            
            % Check if (t+frame size) exceeeds horizon
            if (t+n0+1)>Time
                n0 = Time-t;
            end
            
            if (phase1)
                % Modified max sum weight
                for k2= 1:K2 
                    [b_voted, ~] = F_UCBi(mu_1,T_1,1/(t));
                end
                %}

                % Fix the most voted beam (mode)
                [fixedbeam, ~, uniqmod] = mode(b_voted,1);
                % If the mode is not unique (same votes), select randomly instead
                if (~iscell(uniqmod))
                    fixedbeam = b_voted(randi([1 length(b_voted)]));
                end

                fixedbeams = [fixedbeams; fixedbeam];
                i(t:t+n0) = fixedbeam;
                if (m1==n1)
                    fixedbeam_p2 = fixedbeam;
                end
            else
                i(t:t+n0)=fixedbeam_p2;
                fixedbeams = [fixedbeams; fixedbeam_p2];
            end
        end
        
        
        %% Exploration phase
        if (phase1)
            if (j1<K1)
                k(t)=j1;
                j1=j1+1;
            else
                k(t)=j1;
                j1=1;
            end
        %% UCB phase
        else
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
        end
        % Update weight 
        %w(:,i(t)) = wv;
        
        % Observe outome
        X = rand() < Env1(k(t));
        Y = rand() < Env2(k(t),i(t));
        Z = X*Y;

        reward = [reward Z];
        
        T(k(t),i(t)) = T(k(t),i(t)) + 1;
        
        T_i(i(t)) =  T_i(i(t))+1;
        
        if (phase1)
            % Phase 1 update
            T_1(k(t),i(t)) =  T_1(k(t),i(t))+1;
            S_1(k(t),i(t)) = S_1(k(t),i(t)) + Z;
            mu_1(k(t),i(t)) = S_1(k(t),i(t))./T_1(k(t),i(t));
        end
        %%%%%%%%%%%%%%%%%%%%
        %T_path = [T_path T(1,11)];
        %T_path2 = [T_path2 T(3,11)];
        
        % Single feedback
        S(k(t),i(t)) = S(k(t),i(t)) + Z;
        F(k(t),i(t)) = F(k(t),i(t)) + ~Z;

        mu(k(t),i(t)) = S(k(t),i(t))./T(k(t),i(t));

        % For two-level feedback
        %{
        S1(k(t),i(t)) = S1(k(t),i(t)) + X;
        S2(k(t),i(t)) = S2(k(t),i(t)) + Y;
        F1(k(t),i(t)) = F1(k(t),i(t)) + ~X;
        F2(k(t),i(t)) = F2(k(t),i(t)) + ~Y;

        mu1(k(t),i(t)) = S1(k(t),i(t))./T(k(t),i(t));
        mu2(k(t),i(t)) = S2(k(t),i(t))./T(k(t),i(t));
        %}
        
        %% Compute Regret
        
        regret(t) = sum((max(Env,[],'all') - Env).*T, 'all');
        
    end
    
    d = [k i];
   
end