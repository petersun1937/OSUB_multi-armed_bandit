clear
addpath('Algs')
addpath('Classic')
addpath('Funcs')

%% Sim Setup

% Choose one environment(ground truth) setup
setup = "sim7";

n = 30e3;               % Time horizon
Num_Trials = 10;        % # trials to run
frame = 0.5e3;        % Frame size

switch setup
    case 'anl1'
        PredProb = [0.01 0.5 0.8 ];
        TranProbr = [0.99 0.85 0.8];
        
        TranProbb = [0.1:0.4:0.9 0.5:-0.4:0.1];
        
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


%% Initialization
KL_SelectedArms       = cell(Num_Trials,1);   UCB_SelectedArms       = cell(Num_Trials,1);
TS_SelectedArms       = cell(Num_Trials,1);

KL_reward       = [];   UCB_reward       = [];
TS_reward       = [];

KL_timer = [];        TS_timer = [];   
UCB_timer = [];  

KL_regret = [];        TS_regret = [];   
UCB_regret = [];  


%% Run Num_Trials times
for trial = 1:Num_Trials
    disp(trial)

    %% OSUB
    %[TS_X, TS_reg, ~, TS_Arm, timer1] = OSUB_2dim_alt(PredProb, TransProb, 2, T, "TS");
    %[KL_X, KL_reg, ~, KL_Arm, timer2] = OSUB_2dim_alt(PredProb, TransProb, 2, T, "KLUCB");  
    %[UCB_X, UCB_reg, ~, UCB_Arm, timer3] = OSUB_2dim_alt(PredProb, TransProb, 2, T, "UCB");

    %% OSUB-two-level
    %[TS_X, TS_reg, ~, TS_Arm, timer1] = OSUB_2dim_2lv(PredProb, TranProbr, TranProbb, 4, T, "TS");
    %[KL_X, KL_reg, ~, KL_Arm, timer2] = OSUB_2dim_2lv(PredProb, TranProbr, TranProbb, 4, T, "KLUCB");  
    %[UCB_X, UCB_reg, ~, UCB_Arm, timer3] = OSUB_2dim_2lv(PredProb, TranProbr, TranProbb, 4, T, "UCB");
    
    
    %% Timeframe
    
    %[TS_X, TS_reg, ~, TS_Arm, timer1] = OSUB_multiphase_timeframe(PredProb, TransProb, 2, T, "TS", frame, 100);
    %[KL_X, KL_reg, ~, KL_Arm, timer2] = OSUB_multiphase_timeframe(PredProb, TransProb, 2, T, "KLUCB", frame, 100);  
    %[UCB_X, UCB_reg, ~, UCB_Arm, timer3] = OSUB_multiphase_timeframe(PredProb, TransProb, 2, T, "UCB", frame, 100);
    
    %[TS_X, TS_reg, ~, TS_Arm, timer1] = Voting_timeframe(PredProb, TransProb, n, "TS", frame);
    [KL_X, KL_reg, ~, KL_Arm, timer2] = Voting_timeframe(PredProb, TransProb, n, "KLUCB", frame);  
    [UCB_X, UCB_reg, ~, UCB_Arm, timer3] = Voting_timeframe(PredProb, TransProb, n, "UCB", frame);
    
    %% Classic
    %[TS_X, TS_reg, ~, TS_Arm, timer1] = Classic_2dim_alt(PredProb, TransProb, T, "TS");
    %[KL_X, KL_reg, ~, KL_Arm, timer2] = Classic_2dim_alt(PredProb, TransProb, T, "KLUCB");  
    %[UCB_X, UCB_reg, ~, UCB_Arm, timer3] = Classic_2dim_alt(PredProb, TransProb, T, "UCB");
   
    %% Update records
    KL_SelectedArms{trial}       = [KL_Arm];
    UCB_SelectedArms{trial}      = [UCB_Arm];
    %TS_SelectedArms{trial}       = [TS_Arm];
    
    KL_reward       = [KL_reward; KL_X];
    UCB_reward       = [UCB_reward; UCB_X];
    %TS_reward       = [TS_reward; TS_X];
    
    % Cumulative regret
    KL_regret       = [KL_regret; KL_reg];
    UCB_regret       = [UCB_regret; UCB_reg];
    %TS_regret       = [TS_regret; TS_reg];
    
    
    %TS_timer = [TS_timer; timer1];
    %KL_timer = [KL_timer; timer2];
    %UCB_timer = [UCB_timer; timer3];
    
      

end


%% Compute and plot regret and statistics
%[cumreg_TS, std_TS, CI95_TS] = RegretAnalysis([], TS_regret, Num_Trials);
[cumreg_UCB, std_UCB, CI95_UCB] = RegretAnalysis([], UCB_regret, Num_Trials);
[cumreg_KL, std_KL, CI95_KL] = RegretAnalysis([], KL_regret, Num_Trials);

%save("result.mat")

%PlotRegret(cumreg_UCB,std_UCB,CI95_UCB,...
%    "UCB")

PlotRegret2(cumreg_UCB,cumreg_KL,std_UCB,std_KL,CI95_UCB,CI95_KL,...
     "UCB", "KL-UCB")

%PlotRegret3(cumreg_UCB,cumreg_KL,cumreg_TS,std_UCB,std_KL,std_TS,...
%    CI95_UCB,CI95_KL,CI95_TS,"UCB","KL-UCB","Thompson Sampling")


% Plot the processing time in one time slot
%{
figure
plot(mean(TS_timer,1),'k', 'LineWidth',1.5);
hold on
plot(mean(DTS_timer,1),'r', 'LineWidth',1.5);
grid on
xlabel('Time slot')
ylabel('Mean process time per time slot')
legend('Single Feedback Thompson Sampling','Two-level Feedback TS')
%}
