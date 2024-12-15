clear
addpath('Algs')
addpath('Classic')
addpath('Funcs')

%% Sim Setup

% Choose one environment(ground truth) setup and parameters
setup = "anl1";

n = 10e3;               % Time horizon
Num_Trials = 50;        % # trials to run

% Choose the classic algorithms (UCB, KLUCB, TS)
Algs = ["UCB"];
%Algs = ["UCB" "KLUCB" "TS"];

Num_Algs = numel(Algs);

switch setup
    case 'anl1'
        PredProb = [0.9 0.8];
        TranProbr = [1 0.5];
        
        TranProbb = [1 0.5];
        
        TransProb = TranProbr'.*TranProbb;
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
        
    case 'anl2'
        PredProb = [0.9 0.8];
        TranProbr = [1 0.5];
        
        TranProbb = [1 0.8 0.5];
        
        TransProb = TranProbr'.*TranProbb;
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
        
    case 'sim1'
        % 1st setup
        Rate = [2 3 5 6 9];
        PredProb = [0.01 0.08 0.8 0.88 0.95];
        TranProbr = [0.99 0.9 0.85 0.15 0.05];
        AvgThruput = [0.198 0.54 1 0.78 0.405];
        TranProbb = 0.9;
    case 'sim2'
       % 2nd setup
        Beam = [1 2 3 4 5 6 7 8 9]; 
        TranProbb = [0.1:0.2:0.9 0.7:-0.2:0.1];
        AvgThruput = [0.0198 0.216 5.44 1.32 0.5225];
        PredProb = 1;
        TranProbr = 1;  
    case 'sim3'
       % 3rd setup (w/ beam selection)
        Rate = [2 3 5 6 9]; 
        
        PredProb = [0.01 0.08 0.8 0.88 0.95];
        TranProbr = [0.99 0.9 0.85 0.15 0.05];
        
        Beam = [1 2 3 4 5 6 7 8 9];
        TranProbb = [0.1:0.2:0.9 0.7:-0.2:0.1];
        
        TransProb = TranProbr'.*TranProbb;
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
    case 'sim4'
       % 4th setup (vertically not unimodal)
        Rate = [2 3 5 6 8]; 
        
        PredProb = [0.15 0.3 0.45 0.6 0.75];
        TranProbr = [0.99 0.8 0.5 0.38 0.2];
        
        Beam = [1 2 3 4 5 6 7 8 9];
        TranProbb = [0.1:0.2:0.9 0.7:-0.2:0.1];
        
        TransProb = TranProbr'.*TranProbb;
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
        
    case 'sim5'
       % 5th setup (vertically not unimodal)
        Rate = [2 3 5 6 8]; 
        
        PredProb = [0.15 0.3 0.45 0.6 0.75];
        TranProbr = [0.99 0.8 0.4 0.35 0.2];
        
        Beam = [1 2 3 4 5 6 7 8 9];
        TranProbb = [0.1:0.2:0.9 0.7:-0.2:0.1];
        
        TransProb = TranProbr'.*TranProbb;
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
        
    case 'sim6'
       % 6th setup (trans prob peaks at opt beam)
        Rate = [2 3 5 6 8]; 
        
        PredProb = [0.01 0.08 0.8 0.88 0.95];
        TranProbr = [0.99 0.9 0.85 0.15 0.05];
        
        Beam = [1 2 3 4 5 6 7 8 9];
        TranProbb = [0.01 0.05 0.15 0.3 0.9 0.3 0.15 0.05 0.01];
        
        TransProb = TranProbr'.*TranProbb;
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
        
    case 'sim7'
       % 7th setup
        Rate = [2 3 5 6 8]; 
        
        PredProb = [0.01 0.08 0.8 0.88 0.95];
        TranProbr = [0.99 0.9 0.85 0.15 0.05];
        
        TranProbb = [0.01:0.01:0.05 0.15 0.3 0.9 0.3 0.15 0.05:-0.01:0.01];
        
        TransProb = TranProbr'.*TranProbb;
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
        
    case 'sim7-2'
       % 7th setup (7 rates)
        Rate = [1 2 3 5 6 8 9]; 
        
        PredProb = [0.01 0.05 0.08 0.8 0.88 0.95 0.99];
        TranProbr = [0.99 0.92 0.9 0.85 0.15 0.05 0.01];
        
        TranProbb = [0.01:0.01:0.05 0.15 0.3 0.9 0.3 0.15 0.05:-0.01:0.01];
        
        TransProb = TranProbr'.*TranProbb;
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
        
    case 'sim8'
       % 8th setup (realistic?)
        Rate = [2 3 5 8 10]; 
        
        PredProb = [0.01 0.08 0.8 0.88 0.95];
        
        
        Capacity = [ones(1,7) 2 3 8 10 8 3 2 ones(1,7)];
        TProb = [1 0.99 0.95 0.92 0.9]'*[ones(1,7)*0.5 0.7 0.8 0.9 0.99 0.9 0.8 0.7 ones(1,7)*0.5];
        
        TransProb = Rate'*ones(1,length(Capacity));
        
        TransProb = double(TransProb<=Capacity);
        TransProb(TransProb==0) = 0.01;
        
        TransProb = TransProb.*TProb;
        AvgThruput = PredProb'.*TransProb;
        
        %figure
        %surf(1:length(Capacity), 1:length(Rate), TransProb)
        %figure
        %surf(1:length(Capacity), 1:length(Rate), AvgThruput)
end


AvgThruput = AvgThruput(:,2);

%% Initialization
SelectedArms       = cell(Num_Trials,Num_Algs);

reward  = cell(1,Num_Algs);

regret = cell(1,Num_Algs);
T_paths = cell(1,Num_Algs); T_paths2 = cell(1,Num_Algs);
fixedbeams = cell(1,Num_Algs);

%% Run Num_Trials times
for trial = 1:Num_Trials
    disp(trial)
    for alg = 1:Num_Algs        % Run each algorithm
        
    disp(Algs(alg))

    %% OSUB
    %[X, reg, ~, Arm, timer] = OSUB_2dim_alt(PredProb, TransProb, 2, n, Algs(alg));

    %% OSUB-two-level
    %[X, reg, ~, Arm, timer] = OSUB_2dim_2lv(PredProb, TranProbr, TranProbb, 4, n, Algs(alg));
    
    %% Timeframe
    %[X, reg, ~, Arm, timer] = OSUB_multiphase_timeframe(PredProb, TransProb, 2, n, Algs(alg), frame, 100);
    
    %[X, reg, T_path, T_path2, Arm, timer, fixedb] = Voting_timeframe(PredProb, TransProb, n, Algs(alg), frame);
    
    %% Classic
    %[X, reg, T_path, Arm, timer] = Classic(PredProb, TransProb, n, Algs(alg));
    [X, reg, T_path, Arm, timer] = Classic(AvgThruput, n, Algs(alg));
    %% Update records
    SelectedArms{trial,alg} = Arm;
    
    reward{alg}       = [reward{alg}; X];
    
    % Cumulative regret
    regret{alg}       = [regret{alg}; reg];  
    
    T_paths{alg}       = [T_paths{alg}; T_path]; 
    
    end

end


%% Compute and plot regret and statistics
CI95 = cell(alg,1);
for alg = 1:Num_Algs
    [cumreg(alg,:), std(alg,:), CI95{alg}] = RegretAnalysis([], regret{alg}, Num_Trials);
    
    figure
    plot(mean(T_paths{alg},1),'k', 'LineWidth',1.5);
    %plot(T_paths{alg}(1,:),'k', 'LineWidth',1.5);
    grid on
    
    xlabel('Time slot')
    ylabel('T paths')
end
%save("result.mat")

switch Num_Algs
    case 1
        PlotRegret(cumreg(1,:),std(1,:),CI95{1},...
            Algs(1))
    case 2
        PlotRegret2(cumreg(1,:),cumreg(2,:),std(1,:),std(2,:),CI95{1},CI95{2},...
             Algs(1), Algs(2))
    case 3
        PlotRegret3(cumreg(1,:),cumreg(2,:),cumreg(3,:),std(1,:),std(2,:),std(3,:),...
           CI95{1},CI95{2},CI95{3},Algs(1), Algs(2), Algs(3))
end


