clear

addpath('Algs')
addpath('Funcs')
addpath('Utilities')

%% Inputs and parameters

AvgThruput = [0.1:0.2:0.9 0.7:-0.2:0.1];    %K=9
%AvgThruput = [0.1:0.1:0.9 0.8:-0.1:0.1];    %K=17
%AvgThruput = [0.1:0.04:0.9 0.8:-0.04:0.1];    %K=39
%AvgThruput = [0.1:0.02:0.9 0.8:-0.02:0.1];    %K=77
%AvgThruput = [0.1:0.016:0.9 0.8:-0.016:0.1];    %K=95
%AvgThruput = [0.1:0.0125:0.9 0.8875:-0.0125:0.1];  %K=129

%AvgThruput = normpdf(-2:0.05:4, 1, 1)*2;     %K=121, normal dist.

T = 10e3;               % Time horizon
Num_Trials = 500; 

%fixed_arm = length(AvgThruput)/2 + 1;


%% Initialization
U_KL_SelectedArms       = [];   U_UCB_SelectedArms       = [];
U_TS_SelectedArms       = [];

U_KL_reward       = [];   U_UCB_reward       = [];
U_TS_reward       = [];

U_KL_timer = [];        U_TS_timer = [];   
U_UCB_timer = [];  

U_KL_regret = [];        U_TS_regret = [];   
U_UCB_regret = [];  

%U_KL_mu_exp = 0;    U_UCB_mu_exp = 0;
%U_TS_mu_exp = 0;

%% Run Algorithms for Num_Trials Times
for trial = 1:Num_Trials
    disp(trial)

    %% OSUB
    [U_KL_X, U_KL_reg, ~, U_KL_Arm, timer1] = OSUB(AvgThruput, 2, T, "KLUCB");  
    [U_UCB_X, U_UCB_reg, ~, U_UCB_Arm, timer2] = OSUB(AvgThruput, 2, T, "UCB");
    [U_TS_X, U_TS_reg, ~, U_TS_Arm, timer3] = OSUB(AvgThruput, 2, T, "TS");
    
    %% Classic algs
    
    %[~, U_KL_reg, ~, U_KL_Arm, timer1] = KLUCB(AvgThruput, T, "KLUCB");  
    %[~, U_UCB_reg, ~, U_UCB_Arm, timer2] = UCB(AvgThruput, T, "UCB");
    %[~, U_TS_reg, ~, U_TS_Arm, timer3] = Classic(AvgThruput, T, "TS");
    
    
    %% Update records
    U_KL_SelectedArms       = [U_KL_SelectedArms; U_KL_Arm];
    U_UCB_SelectedArms       = [U_UCB_SelectedArms; U_UCB_Arm];
    U_TS_SelectedArms       = [U_TS_SelectedArms; U_TS_Arm];
    
    %U_KL_reward       = [U_KL_reward; U_KL_X];
    %U_UCB_reward       = [U_UCB_reward; U_UCB_X];
    %U_TS_reward       = [U_TS_reward; U_TS_X];
    
    U_KL_regret       = [U_KL_regret; U_KL_reg];
    U_UCB_regret       = [U_UCB_regret; U_UCB_reg];
    U_TS_regret       = [U_TS_regret; U_TS_reg];
    
    %U_KL_mu_exp = (U_KL_mu + U_KL_mu_exp*(trial-1))/trial;
    %U_UCB_mu_exp = (U_UCB_mu + U_UCB_mu_exp*(trial-1))/trial;
    %U_TS_mu_exp = (U_TS_mu + U_TS_mu_exp*(trial-1))/trial;
    
    
    U_KL_timer = [U_KL_timer; timer1];
    U_UCB_timer = [U_UCB_timer; timer2];
    U_TS_timer = [U_TS_timer; timer3];
    
      
end

%U_KL_regret = (1:T)*max(AvgThruput)-cumsum(mean(U_KL_reward,1));
%U_UCB_regret = (1:T)*max(AvgThruput)-cumsum(mean(U_UCB_reward,1));
%U_TS_regret = (1:T)*max(AvgThruput)-cumsum(mean(U_TS_reward,1));

%% Compute and plot regret and statistics
[cumreg_U_UCB, std_U_UCB, CI95_U_UCB] = RegretAnalysis(AvgThruput, U_UCB_regret, Num_Trials);
[cumreg_U_KL, std_U_KL, CI95_U_KL] = RegretAnalysis(AvgThruput, U_KL_regret, Num_Trials);
[cumreg_U_TS, std_U_TS, CI95_U_TS] = RegretAnalysis(AvgThruput, U_TS_regret, Num_Trials);

%[regret_U_UCB, std_U_UCB, CI95_U_UCB] = CumRegret_woreward(AvgThruput, U_UCB_SelectedArms, Num_Trials);
%[regret_U_KL, std_U_KL, CI95_U_KL] = CumRegret_woreward(AvgThruput, U_KL_SelectedArms, Num_Trials);
%[regret_U_TS, std_U_TS, CI95_U_TS] = CumRegret_woreward(AvgThruput, U_TS_SelectedArms, Num_Trials);

%save("UCB_result.mat")

%PlotRegret(regret_U_KL,std_U_KL,CI95_U_KL,"Single Feedback OSUB-KLUCB")
%PlotRegret(regret_U_TS,std_U_TS,CI95_U_TS,"Single Feedback OSUB-TS")

PlotRegret3(cumreg_U_UCB,cumreg_U_KL,cumreg_U_TS,std_U_UCB,std_U_KL,std_U_TS,...
    CI95_U_UCB,CI95_U_KL,CI95_U_TS,"UCB","KL-UCB","Thompson Sampling")

%{
% Plot processing time in a time slot
figure
plot(mean(U_UCB_timer,1),'k', 'LineWidth',1.5);
hold on
plot(mean(U_KL_timer,1),'r', 'LineWidth',1.5);
plot(mean(U_TS_timer,1),'b', 'LineWidth',1.5);
grid on
xlabel('Time slot')
ylabel('Mean process time per time slot')
legend('UCB','KLUCB','Thompson Sampling')
    %}
