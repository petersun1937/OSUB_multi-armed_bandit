function [reward, regret, T_path, T_path2, d, timer, fixedbeams] = Explr_ArmElim_timeframe(Env1, Env2, Time, alg, n0)


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
    
    b_tofix = zeros(K1,1); 
    fixedbeams = [];
    
    i = [];
    k = [];
    
    timer = [];         % timer
    
    %% Initialization
    tic;

    % Exploration time
    ex = 1;
    t=0;
    for i1= 1:K2
        for j1=1:K1
            for t1=1:ex
                
            i = [i; i1];
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
            %mu_1(k(t),i(t)) = S_1(k(t),i(t))./T_1(k(t),i(t));
            
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
    
    %m1=0; % Frame counter for phase 1
    phase1 = true;
    activeb = true(1,K2);
    activer = cell(1,K2);
    for k2=1:K2
        activer{k2} = true(K1,1);
    end
    
    
    %fixedbeam = 1;
    ubi = zeros(1,K2);
    lbi = zeros(1,K2);
    
    ubr = zeros(K1,1);
    lbr = zeros(K1,1);
    i1=1; 
    elimrate = false;
    for t = K1*K2*ex+1:Time
        
        %% Start frame (vote and fix beam)
        % If current time (subtracted exploration time) is a multiple
        % of frame size, start voting
        
        if(rem(t-K1*K2*ex,n0)==1)

            j1=1;
            % Check if (t+frame size) exceeeds horizon
            if (t+n0+1)>Time
                n0 = Time-t;
            end
            
            %% Arm Elimination for beams
            for i1= 1:K2 
                mu_temp = mu(activer{i1},activeb');
                T_temp = T(activer{i1},activeb');
                [b_tofix, ubii, lbii] = F_UCBi(mu_temp,T_temp,1/(t));
                active_ind = find(activeb==true);
                b_tofix = active_ind(b_tofix);
                ubi(activeb) = ubii;
                lbi(activeb) = lbii;
            end
            %}
            b_to_elim = false(1,K2);
            
            
            for k2= 1:K2
               b_to_elim = (b_to_elim)|(ubi < lbi(k2));
            end

            activeb(b_to_elim) = false;
            %mu(~activer{b_tofix},b_tofix)= nan;
        
            activer_ind = find(activer{b_tofix}==true);
            %end
         end
            
            
            % Fix the selected beam (mode)
            %[fixedbeam, ~, uniqmod] = mode(b_tofix,1);

            % If the mode is not unique (same votes), select randomly instead
            %if (~iscell(uniqmod))
            %    fixedbeam = b_tofix(randi([1 length(b_tofix)]));
           % end

            fixedbeams = [fixedbeams; b_tofix];
            %i(t:t+n0) = fixedbeam;


            %if (fixedbeam < K2)
            %    fixedbeam = fixedbeam+1;
            %else
            %    fixedbeam = 1;
            %end


        if (j1<length(activer_ind))
            k(t)=activer_ind(j1);
            j1=j1+1;
        else
            k(t)=activer_ind(j1);
            j1=1;
            elimrate = true;
        end
        

        k(t)=activer_ind(j1);
        
        i(t) = b_tofix;
        %k(t) = r_toplay;
        
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
        %w(:,i(t)) = wv;
        
        % Observe outome
        X = rand() < Env1(k(t));
        Y = rand() < Env2(k(t),i(t));
        Z = X*Y;

        reward = [reward Z];
        
        T(k(t),i(t)) = T(k(t),i(t)) + 1;
        
        T_i(i(t)) =  T_i(i(t))+1;
        
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
        
        
        %% Arm Elimination for rates
        if(rem(t-K1*K2*ex,n0)==0)
            %for k2= 1:K2 
            %{
            if activeb(i1)
                %mu_temp = mu(activer{b_tofix},b_tofix);
                %T_temp = T(activer{b_tofix},b_tofix);
                mu_temp = mu(activer{i1},i1);
                T_temp = T(activer{i1},i1);
                activer_ind = find(activer{i1}==true);
                if i1==b_tofix
                    [r_toplay, ubrr, lbrr] = F_UCB(mu_temp,T_temp,1/(t));
                    r_toplay = activer_ind(r_toplay);
                else
                    [~, ubrr, lbrr] = F_UCB(mu_temp,T_temp,1/(t));
                end

                ubr(activer{i1}) = ubrr;
                lbr(activer{i1}) = lbrr;
            end
            r_to_elim = false(K1,1);
            for k1=1:K1
                r_to_elim = (r_to_elim)|(ubr < lbr(k1));
            end
            activer{i1}(r_to_elim)=false;
            
            i1=i1+1;
            %}
            if elimrate
                if activeb(b_tofix)
                    mu_temp = mu(activer{b_tofix},b_tofix);
                    T_temp = T(activer{b_tofix},b_tofix);
                    activer_ind = find(activer{b_tofix}==true);
                    [r_toplay, ubrr, lbrr] = F_UCB(mu_temp,T_temp,1/(t));
                    r_toplay = activer_ind(r_toplay);
                    ubr(activer{b_tofix}) = ubrr;
                    lbr(activer{b_tofix}) = lbrr;
                end
                r_to_elim = false(K1,1);
                for k1=1:K1
                    r_to_elim = (r_to_elim)|(ubr < lbr(k1));
                end
                activer{b_tofix}(r_to_elim)=false;
                elimrate=false;
            end
        
        end
        %% Compute Regret
        
        regret(t) = sum((max(Env,[],'all') - Env).*T, 'all');
        
    end
    
    d = [k i];
   
end