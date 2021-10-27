function [reward, asympregret, SelectedArm, timer] = UCB(Env, Time)
% HF: horizon free
K = length(Env);

%[ExpectedMeans, NbrPlayArm, gainKLUCB, ArmsPlayed]= UCB1_Initialize(K); % Initialization
SelectedArm = [];
reward = [];

mu = zeros(1,K);
T = zeros(1,K);      % number of times that rate ri is selected, until time slot t
S = zeros(1,K);     % number of times that the user successfully sees the desired content when rate ri is selected until time slot t,
timer = [];         % timer
regret = zeros(1,Time);
asympregret = zeros(1,Time);

for t = 1:Time
    tic;
    %ArmToPlay = KLUCB_RecommendArm(ExpectedMeans, NbrPlayArm, t, Horizon, HF,c); % Arm recommended by KLUCB

    %ucb = SearchingKLUCBIndex(ExpectedMeans, NbrPlayArm, t, Horizon, HF,c);
    
    if t < K+1
        Is = t;
    else
        Is = F_UCB(mu,T,1/Time);
    end
    
    % Observe the random outcome
    %Z = R(Is)*rand() < Env(Is);
    Z = rand() < Env(Is);
    
    %[ExpectedMeans, NbrPlayArm, gainKLUCB, ArmsPlayed]= UCB1_ReceiveReward(ExpectedMeans, NbrPlayArm, reward, ArmToPlay, gainKLUCB, ArmsPlayed); % Update UCB parameters using the reward received at time t.
    reward = [reward Z];
    T(Is) = T(Is) + 1;
    SelectedArm = [SelectedArm Is];
    
    S(Is) = S(Is) + Z;
   % ExpectedMeans(Is) = (ExpectedMeans(Is)*T(Is) + reward)./(T(Is)+1);
    mu(Is) = (S(Is))./(T(Is));
    
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