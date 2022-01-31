clear
addpath('Algs')
addpath('Funcs')
addpath('Utilities')

%% Sim Setup

setup = "sim6";

switch setup
    case 'sim1'
        % 1st setup
        Rate = [2 3 5 6 9];
        PredProb = [0.1 0.3 0.5 0.65 0.9];
        TranProbr = [0.99 0.6 0.4 0.2 0.05];  
        % Avgthruput = [0.198 0.54 1 0.78 0.405]
        TranProbb = 1;
    case 'sim2'
       % 2nd setup
        Beam = [1 2 3 4 5 6 7 8 9]; 
        TranProbb = [0.1:0.2:0.9 0.7:-0.2:0.1];
        % Avgthruput = [0.0198 0.216 5.44 1.32 0.5225]
        PredProb = 1;
        TranProbr = 1;  
    case 'sim3'
       % 3rd setup (w/ beam selection)
        Rate = [2 3 5 6 9]; 
        
        PredProb = [0.01 0.08 0.8 0.88 0.95];
        TranProbr = [0.99 0.9 0.85 0.15 0.05];
        
        Beam = [1 2 3 4 5 6 7 8 9];
        TranProbb = [0.1:0.2:0.9 0.7:-0.2:0.1];
        
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
    case 'sim4'
       % 4th setup (vertically not unimodal)
        Rate = [2 3 5 6 8]; 
        
        PredProb = [0.15 0.3 0.45 0.6 0.75];
        TranProbr = [0.99 0.8 0.5 0.38 0.2];
        
        Beam = [1 2 3 4 5 6 7 8 9];
        TranProbb = [0.1:0.2:0.9 0.7:-0.2:0.1];
        
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
        
    case 'sim5'
       % 5th setup (vertically not unimodal)
        Rate = [2 3 5 6 8]; 
        
        PredProb = [0.15 0.3 0.45 0.6 0.75];
        TranProbr = [0.99 0.8 0.4 0.35 0.2];
        
        Beam = [1 2 3 4 5 6 7 8 9];
        TranProbb = [0.1:0.2:0.9 0.7:-0.2:0.1];
        
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
        
    case 'sim6'
       % 6th setup (trans prob peaks at opt beam)
        Rate = [2 3 5 6 8]; 
        
        PredProb = [0.01 0.08 0.8 0.88 0.95];
        TranProbr = [0.99 0.9 0.85 0.15 0.05];
        
        Beam = [1 2 3 4 5 6 7 8 9];
        TranProbb = [0.01 0.05 0.15 0.3 0.9 0.3 0.15 0.05 0.01];
        
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
        
    case 'anl'
        % simple ex for analysis
        PredProb = [0.1 0.4 0.8 0.9];
        TranProbr = [0.9 0.7 0.5 0.3];
        
        Beam = [1 2 3 4 5];
        TranProbb = [0.15 0.3 0.9 0.3 0.15];
        
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
end

%AvgThruput = Rate.*PredProb.*TranProb;  
AvgThruputr = PredProb.*TranProbr; 
AvgThruputb = TranProbb; 

T = 15e3;               % Time horizon
Num_Trials = 50;

%% Initialization
KL_SelectedArms       = [];   UCB_SelectedArms       = [];
TS_SelectedArms       = [];

KL_reward       = [];   UCB_reward       = [];
TS_reward       = [];

KL_timer = [];        TS_timer = [];   
UCB_timer = [];  

KL_regret = [];        TS_regret = [];   
UCB_regret = [];  

%U_KL_mu_exp = 0;    U_UCB_mu_exp = 0;
%U_TS_mu_exp = 0;

%% Run Algorithms for Num_Trials Times
for trial = 1:Num_Trials
    disp(trial)

    %% OSUB
    %[TS_X, TS_reg, TS_areg, TS_Arm, timer1] = OSUB_2dim(PredProb, TranProbr, TranProbb, 2, T, "TS");
    %[KL_X, KL_reg, KL_areg, KL_Arm, timer2] = OSUB_2dim(PredProb, TranProbr, TranProbb, 2, T, "KLUCB");  
    %[UCB_X, UCB_reg, UCB_areg, UCB_Arm, timer3] = OSUB_2dim(PredProb, TranProbr, TranProbb, 2, T, "UCB");

    %% OSUB-two-level
    %[TS_X, TS_reg, TS_areg, TS_Arm, timer1] = OSUB_2dim_2lv(PredProb, TranProbr, TranProbb, 4, T, "TS");
    %[KL_X, KL_reg, KL_areg, KL_Arm, timer2] = OSUB_2dim_2lv(PredProb, TranProbr, TranProbb, 4, T, "KLUCB");  
    %[UCB_X, UCB_reg, UCB_areg, UCB_Arm, timer3] = OSUB_2dim_2lv(PredProb, TranProbr, TranProbb, 4, T, "UCB");
    
    
    %% OSUB alt
    [TS_X, TS_reg, TS_areg, TS_Arm, timer1] = OSUB_two_phase(PredProb, TranProbr, TranProbb, 2, T, "TS");
    [KL_X, KL_reg, KL_areg, KL_Arm, timer2] = OSUB_two_phase(PredProb, TranProbr, TranProbb, 2, T, "KLUCB");  
    [UCB_X, UCB_reg, UCB_areg, UCB_Arm, timer3] = OSUB_two_phase(PredProb, TranProbr, TranProbb, 2, T, "UCB");
    
    
    %% Classic
    %[TS_X, TS_reg, TS_areg, TS_Arm, timer1] = Classic_2dim(PredProb, TranProbr, TranProbb, T, "TS");
    %[KL_X, KL_reg, KL_areg, KL_Arm, timer2] = Classic_2dim(PredProb, TranProbr, TranProbb, T, "KLUCB");  
    %[UCB_X, UCB_reg, UCB_areg, UCB_Arm, timer3] = Classic_2dim(PredProb, TranProbr, TranProbb, T, "UCB");
   
    %% Update records
    KL_SelectedArms       = [KL_SelectedArms; KL_Arm];
    UCB_SelectedArms       = [UCB_SelectedArms; UCB_Arm];
    TS_SelectedArms       = [TS_SelectedArms; TS_Arm];
    
    KL_reward       = [KL_reward; KL_X];
    UCB_reward       = [UCB_reward; UCB_X];
    TS_reward       = [TS_reward; TS_X];
    
    KL_regret       = [KL_regret; KL_reg];
    UCB_regret       = [UCB_regret; UCB_reg];
    TS_regret       = [TS_regret; TS_reg];
    
    %U_KL_mu_exp = (U_KL_mu + U_KL_mu_exp*(trial-1))/trial;
    %U_UCB_mu_exp = (U_UCB_mu + U_UCB_mu_exp*(trial-1))/trial;
    %U_TS_mu_exp = (U_TS_mu + U_TS_mu_exp*(trial-1))/trial;
    
    TS_timer = [TS_timer; timer1];
    KL_timer = [KL_timer; timer2];
    UCB_timer = [UCB_timer; timer3];
    
      

end


%% Compute and plot regret and statistics
%[regret_TS, std_TS, CI95_TS] = CumRegret_woreward(AvgThruput, TS_SelectedArms, Num_Trials);
%[regret_DTS, std_DTS, CI95_DTS] = CumRegret_woreward(AvgThruput, DTS_SelectedArms, Num_Trials);
%% Compute and plot regret and statistics
[cumreg_TS, std_TS, CI95_TS] = RegretAnalysis([], TS_regret, Num_Trials);
[cumreg_UCB, std_UCB, CI95_UCB] = RegretAnalysis([], UCB_regret, Num_Trials);
[cumreg_KL, std_KL, CI95_KL] = RegretAnalysis([], KL_regret, Num_Trials);

%save("TS_result.mat")

%PlotRegret(cumreg_KL,std_KL,CI95_KL,...
%    "KL-UCB")

%lotRegret2(cumreg_TS,cumreg_KL,std_TS,std_KL,CI95_TS,CI95_KL,...
%     "Thompson Sampling", "KL-UCB")

PlotRegret3(cumreg_UCB,cumreg_KL,cumreg_TS,std_UCB,std_KL,std_TS,...
    CI95_UCB,CI95_KL,CI95_TS,"UCB","KL-UCB","Thompson Sampling")

% Plot processing time in a time slot
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
