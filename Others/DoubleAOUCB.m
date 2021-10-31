function [reward, SelectedArm, timer] = DoubleAOUCB(Env1, Env2, R, Time)

K = length(R); % Number of Arms

%% Initialization

reward = [];
SelectedArm = [];
timer = [];

S1 = zeros(1,K); S2 = zeros(1,K);   % Sn
%F1 = zeros(1,K); F2 = zeros(1,K);   % Fn
T = zeros(1,K);
mu1 = zeros(1,K);   mu2 = zeros(1,K);

for t = 1:Time
    tic;
    %% Recommend arms
    if t < K+1
        Is = t;
    else
    
        %rAB = Alpha.*Beta;
        f = mu1.*mu2+sqrt((2*log(1+t*log(log(t)))./T));
        %% Apply the arm (selected rate) and observe 
        m = max(f);
        % Randomly pick one of the max-valued arm
        if ( ~isnan(m))
        mI = find(f == m);
        Is = mI(randi(length(mI)));
        else
        Is = randi(length(R));
        end
    end
    % Observe the random outcome
    X = rand() < Env1(Is);
    Y = rand() < Env2(Is);
    
    % Combine two counters as the reward
    Z = X*Y;
    
    %% Update Thompson Sampling parameters
    reward = [reward Z];
    T(Is) = T(Is) + 1;
    SelectedArm = [SelectedArm Is];

    S1(Is) = S1(Is) + X;
    S2(Is) = S2(Is) + Y;
    
    mu1(Is) = (S1(Is))./(T(Is));
    mu2(Is) = (S2(Is))./(T(Is));
    
    tend = toc;
    timer = [timer tend];
end


end