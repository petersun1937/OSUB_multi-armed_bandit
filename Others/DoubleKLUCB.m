function [reward, SelectedArm, timer] = DoubleKLUCB(Env1, Env2, R, Time)
% HF: horizon free
K = length(Env1);

%[ExpectedMeans, NbrPlayArm, gainKLUCB, ArmsPlayed]= UCB1_Initialize(K); % Initialization
SelectedArm = [];
reward = [];
timer = [];

mu1 = zeros(1,K);   mu2 = zeros(1,K);
% number of times the rates are selected
T = zeros(1,K);
% number of times the user successfully sees the desired content when rates are selected
S1 = zeros(1,K);	S2 = zeros(1,K);


for t = 1:Time
    %ArmToPlay = KLUCB_RecommendArm(ExpectedMeans, NbrPlayArm, t, Horizon, HF,c); % Arm recommended by KLUCB
    tic;
    %ucb = SearchingKLUCBIndex(ExpectedMeans, NbrPlayArm, t, Horizon, HF,c);
    
    if t < K+1
        Is = t;
    else
        %ucb = klIC(p, d);
        %d = (log(t) + c*log(log(t+1)))./T;
        d = log(1 + t*log(log(t)))./T;
        
        %ucb = R.*DoubleKLBinSearch(d,mu1,mu2);
        ucb = DoubleKLBinSearch(d,mu1,mu2);
        
        %ArmToPlay = PickingMaxIndexArm(ucb);
        m = max(ucb);
        if ( ~isnan(m))
            mI = find(ucb == m);
            Is = mI(randi(length(mI)));         % Randomly pick one of the max
        else
            Is = randi(K);
        end
    end
    
    % Observe the random outcome
    X = rand() < Env1(Is);
    Y = rand() < Env2(Is);
    Z = X*Y;

    %[ExpectedMeans, NbrPlayArm, gainKLUCB, ArmsPlayed]= UCB1_ReceiveReward(ExpectedMeans, NbrPlayArm, reward, ArmToPlay, gainKLUCB, ArmsPlayed); % Update UCB parameters using the reward received at time t.
    reward = [reward Z];
    T(Is) = T(Is) + 1;
    SelectedArm = [SelectedArm Is];
    
    S1(Is) = S1(Is) + X;
    S2(Is) = S2(Is) + Y;
   % ExpectedMeans(Is) = (ExpectedMeans(Is)*T(Is) + reward)./(T(Is)+1);
    mu1(Is) = (S1(Is))./(T(Is));
    mu2(Is) = (S2(Is))./(T(Is));
    
    
    tend = toc;
    timer = [timer tend];
end


end