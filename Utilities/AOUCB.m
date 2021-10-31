function [reward, SelectedArm, timer] = AOUCB(Env, R, Time)

K = length(R); % Number of Arms

%% Initialization

reward = [];
SelectedArm = [];
timer = [];

S1 = zeros(1,K);   % Sn
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
        f = mu1+sqrt((2*log(1+t*log(log(t)))./T));
        %% Apply the arm (selected rate) and observe 
        m = max(f);
        % Randomly pick one of the max-valued arm
        if ( ~isnan(m))
        mI = find(f == m);
        Is = mI(randi(length(mI)));
        else
        Is = randi(length(Alpha));
        end
    end
    % Observe the random outcome
    X = rand() < Env(Is);
    %Y = rand() < Env2(Is);
    %X = rand() < Env1(I);
    %Y = rand() < Env2(I);
    
    % Combine two counters as the reward
    Z = X;
    
    %% Update Thompson Sampling parameters
    reward = [reward Z];
    T(Is) = T(Is) + 1;
    SelectedArm = [SelectedArm Is];

    if Z==1
        S1(Is) = S1(Is) + 1;
    end 
    
    mu1(Is) = (S1(Is))./(T(Is));
    
    tend = toc;
    timer = [timer tend];
end


end