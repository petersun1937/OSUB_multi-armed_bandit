clear
addpath('Algs')
addpath('Funcs')

%% Sim Setup
setup = 'sim2';

switch setup
    case 'sim1'
        % 1st setup
        Rate = [2 3 5 6 9];
        PredProb = [0.1 0.3 0.5 0.65 0.9];
        TranProb = [0.99 0.6 0.4 0.2 0.05];  
        % Avgthruput = [0.198 0.54 1 0.78 0.405]
    case 'sim2'
       % 2nd setup
        Rate = [2 3 8 10 11]; 
        PredProb = [0.01 0.08 0.8 0.88 0.95];
        TranProb = [0.99 0.9 0.85 0.15 0.05];
        % Avgthruput = [0.0198 0.216 5.44 1.32 0.5225]
end

%AvgThruput = Rate.*PredProb.*TranProb;  
AvgThruput = PredProb.*TranProb; 

T = 5000;               % Time horizon
Num_Trials = 100;

AO_SelectedArms       = [];
DAO_SelectedArms      = [];
Ada_SelectedArms      = [];
DAda_SelectedArms      = [];

AO_timer = [];    Ada_timer=[];
DAO_timer = [];    DAda_timer=[];

%% Run Algorithms for Num_Trials Times
for trial = 1:Num_Trials
    disp(trial)

    %% Thompson Sampling
    [~, AO_Arm, timer1] = AOUCB(AvgThruput, Rate, T);
    [~, DAO_Arm, timer2] = DoubleAOUCB(PredProb, TranProb, Rate, T);
    [~, Ada_Arm, timer3] = AdaUCB(AvgThruput, Rate, T);
    [~, DAda_Arm, timer4] = DoubleAdaUCB(PredProb, TranProb, Rate, T);
    %[~, Ada_Arm, timer3] = ThompsonSampling(AvgThruput, Rate, T);
    %[~, DAda_Arm, timer4] = DoubleTS(PredProb, TranProb, Rate, T);
    
    % Record the selected arms through out the trials
    AO_SelectedArms       = [AO_SelectedArms; AO_Arm];
    DAO_SelectedArms       = [DAO_SelectedArms; DAO_Arm];
    Ada_SelectedArms       = [Ada_SelectedArms; Ada_Arm];
    DAda_SelectedArms       = [DAda_SelectedArms; DAda_Arm];
    
    AO_timer = [DAO_timer; timer1];
    DAO_timer = [DAO_timer; timer2];
    Ada_timer = [Ada_timer; timer3];
    DAda_timer = [DAda_timer; timer4];

end


%% Compute and plot regret and statistics
[regret_AO, std_AO, CI95_AO] = CumRegret_woreward(AvgThruput, AO_SelectedArms, Num_Trials);
[regret_DAO, std_DAO, CI95_DAO] = CumRegret_woreward(AvgThruput, DAO_SelectedArms, Num_Trials);
[regret_Ada, std_Ada, CI95_Ada] = CumRegret_woreward(AvgThruput, Ada_SelectedArms, Num_Trials);
[regret_DAda, std_DAda, CI95_DAda] = CumRegret_woreward(AvgThruput, DAda_SelectedArms, Num_Trials);

%save("UCB_result.mat")

PlotRegret2(regret_AO,regret_DAO,std_AO,std_DAO,CI95_AO,CI95_DAO,"Single Feedback AOUCB",...
    "Two-level Feedback AOUCB")
PlotRegret2(regret_Ada,regret_DAda,std_Ada,std_DAda,CI95_Ada,CI95_DAda,"Single Feedback AdaUCB",...
    "Two-level feedback AdaUCB")

%{
% Plot processing time in a time slot
figure
plot(mean(DAO_timer,1),'k', 'LineWidth',1.5);
hold on
%plot(mean(DAO_timer,1),'r', 'LineWidth',1.5);
%grid on
xlabel('Time slot')
ylabel('Mean process time per time slot')
legend('Single Feedback')
%}
%{
% Plot the mean of cumulative regret of all experiments
figure
plot(mean(regret_TS,1),'k', 'LineWidth',1.5);
hold on
plot(mean(regret_DTS,1),'r', 'LineWidth',1.5);
grid on
xlabel('Time slot')
ylabel('Cumulative regret')
legend('Single Feedback Thompson Sampling','Two-level Feedback TS')

% Plot Standard Deviation of all experiments
figure
plot(std_TS,'k', 'LineWidth',1.5);
hold on
plot(std_DTS,'r', 'LineWidth',1.5);
grid on
xlabel('Time slot')
ylabel('Standard Deviation')
legend('Single Feedback Thompson Sampling','Two-level Feedback TS')

% Plot 95% Confidence Intervals of all experiments
figure
plot(mean(regret_TS,1),'k', 'LineWidth',1.5);
hold on
patch('XData',[1:T fliplr(1:T)],'YData',[CI95_TS(1,:) fliplr(CI95_TS(2,:))], 'facecolor','blue',...
        'edgecolor','none', ...
        'facealpha', 0.3)
plot(mean(regret_DTS,1),'r', 'LineWidth',1.5);
patch('XData',[1:T fliplr(1:T)],'YData',[CI95_DTS(1,:) fliplr(CI95_DTS(2,:))], 'facecolor','red',...
        'edgecolor','none', ...
        'facealpha', 0.3)

grid on
xlabel('Time slot')
ylabel('Cumulative regret')
legend('Single Feedback Thompson Sampling','95% Confidence Single',...
    'Two-level Feedback TS','95% Confidence Two-level')
%}
