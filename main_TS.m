clear
addpath('Algs')
addpath('Funcs')

%% Sim Setup
setup = 'sim1';

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
Num_Trials = 1000;

TS_SelectedArms       = [];
DTS_SelectedArms      = [];
TS_timer = [];  DTS_timer = [];

%% Run Algorithms for Num_Trials Times
for trial = 1:Num_Trials
    disp(trial)

    %% Thompson Sampling
    [~, TS_Arm, timer1] = ThompsonSampling(AvgThruput, Rate, T);
    [~, DTS_Arm, timer2] = DoubleTS(PredProb, TranProb, Rate, T);
    
    % Record the selected arms through out the trials
    TS_SelectedArms       = [TS_SelectedArms; TS_Arm];
    DTS_SelectedArms       = [DTS_SelectedArms; DTS_Arm];
    TS_timer = [TS_timer; timer1];
    DTS_timer = [DTS_timer; timer2];

end


%% Compute and plot regret and statistics
[regret_TS, std_TS, CI95_TS] = CumRegret_woreward(AvgThruput, TS_SelectedArms, Num_Trials);
[regret_DTS, std_DTS, CI95_DTS] = CumRegret_woreward(AvgThruput, DTS_SelectedArms, Num_Trials);

save("TS_result.mat")

PlotRegret2(regret_TS,regret_DTS,std_TS,std_DTS,CI95_TS,CI95_DTS,...
    "Single-Feedback Thompson Sampling", "Two-level feedback TS")

% Plot processing time in a time slot
figure
plot(mean(TS_timer,1),'k', 'LineWidth',1.5);
hold on
plot(mean(DTS_timer,1),'r', 'LineWidth',1.5);
grid on
xlabel('Time slot')
ylabel('Mean process time per time slot')
legend('Single Feedback Thompson Sampling','Two-level Feedback TS')

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
