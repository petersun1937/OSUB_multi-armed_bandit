function [reward, regret, SelectedArm, timer] = DoubleTS(Env1, Env2, R, Time)

K = length(R); % Number of Arms

%% Initialization

reward = [];
SelectedArm = [];
timer = [];

S1 = zeros(1,K); S2 = zeros(1,K);   % Sn
F1 = zeros(1,K); F2 = zeros(1,K);   % Fn

for t = 1:Time
    tic;
    %% Recommend arms
    Alpha = []; Beta = [];
    for n = 1:K
       % Generate probabilities with Beta distribution
       Alpha = [Alpha betarnd(S1(n)+1,F1(n)+1)]; 
       Beta = [Beta betarnd(S2(n)+1,F2(n)+1)];
    end
    
    %rAB = R.*Alpha.*Beta;
    rAB = Alpha.*Beta;
    %% Apply the arm (selected rate) and observe 
    m = max(rAB);
    % Randomly pick one of the max-valued arm
    if ( ~isnan(m))
        mI = find(rAB == m);
        Is = mI(randi(length(mI)));
    else
        Is = randi(length(Alpha));
    end
    
    % Observe the random outcome
    X = rand() < Env1(Is);
    Y = rand() < Env2(Is);
    
    % Combine two counters as the reward
    Z = X*Y;
    
    %% Update Thompson Sampling parameters
    reward = [reward Z];
    SelectedArm = [SelectedArm Is];

    if Z==1
        S1(Is) = S1(Is) + 1;
        S2(Is) = S2(Is) + 1;
    else
        F1(Is) = F1(Is) + 1;
        F2(Is) = F2(Is) + 1;
    end
    
    %S1(I) = S1(I) + (X == 1);
    %S2(I) = S2(I) + (Y == 1);
    %F1(I) = F1(I) + (X == 0);   
    %F2(I) = F2(I) + (Y == 0);   
    
    tend = toc;
    timer = [timer tend];
    
    if t>1
        %regret(t) = regret(t-1) + (max(Env1)*max(Env2) - Env1(Is)*Env2(Is));
        %regret(t) = regret(t-1) + sum(((max(Env1)*max(Env2)  - Env1.*Env2).*T_exp);
        %regret(t) = regret(t-1) + (max(Env1)*max(Env2) - mean(reward,2));
        regret(t) = (t*max(Env1)*max(Env2) - sum(reward));
    else
        %regret(1) = max(Env1)*max(Env2) - Env1(Is)*Env2(Is);
        %regret(1) = sum((max(Env1)*max(Env2) - Env1.*Env2).*T_exp);
        %regret(t) = max(Env1)*max(Env2) - mean(reward,2);
        regret(1) = t*max(Env1)*max(Env2) - sum(reward);
    end
    
    
end


end