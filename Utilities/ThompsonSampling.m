function [reward, asympregret, SelectedArm, timer] = ThompsonSampling(Env, Time)

K = length(Env); % Number of Arms
%% Initialization
S = zeros(1,K);     % Sn
F = zeros(1,K);     % Fn
T = zeros(1,K);     
reward = [];
SelectedArm = [];
timer = [];
regret = zeros(1,Time);
asympregret = zeros(1,Time);

for t = 1:Time
    tic;
    %% Recommend arms
    Gamma = [];
    for n = 1:K
        % Generate probabilities with Beta distribution
        Gamma = [Gamma betarnd(S(n)+1,F(n)+1)];
    end
    
    %rY = R.*Gamma;
    rY = Gamma;
    %% Apply the arm (selected rate) and observe
    m = max(rY);
    % Randomly pick one of the max-valued arm
    if ( ~isnan(m))
        mI = find(rY == m);
        Is = mI(randi(length(mI)));         
    else
        Is = randi(length(Gamma));
    end
    
    % Observe the random outcome
    Z = rand() < Env(Is);
    %Z = rand()*R(I) < Env(I);
    
    %% Update Thompson Sampling parameters
    reward = [reward Z];
    SelectedArm = [SelectedArm Is];
    
    T(Is) = T(Is) + 1;
    
    if Z==1
        S(Is) = S(Is) + 1;
    else
        F(Is) = F(Is) + 1;
    end
    
    tend = toc;
    timer = [timer tend];
    
    
    emp_mu = S/t;
    T_exp = T/t;
    %regret(trial,t) = regret(trial,t-1) + sum((max(Env)- mu)*(T_exp));

    %% Compute Cumulative Regret
    regret(t) = sum((max(Env) - Env).*T);
    %regret(t) = t*max(Env) - sum(reward);

    asympregret(t) =(max(Env) - Env(Is));
    

end


end