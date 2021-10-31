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
        % AvgThruput = [0.198 0.54 1 0.78 0.405]  
    case 'sim2'
       % 2nd setup
        Rate = [2 3 8 10 11]; 
        PredProb = [0.01 0.08 0.8 0.88 0.95];
        TranProb = [0.99 0.9 0.85 0.15 0.05];
        % AvgThruput = [0.0198 0.216 5.44 1.32 0.5225]  
end

AvgThruput = PredProb.*TranProb;  
%AvgThruput = Rate.*PredProb.*TranProb; 

Time = 5000; %Overall number of interaction with the environment
Num_Trials = 1000;

KLUCB_SelectedArms = [];	DKLUCB_SelectedArms = [];
KLUCB_timer = [];  DKLUCB_timer = [];

%% Run Algorithms for Num_Trials Times
for trial = 1:Num_Trials
    disp(trial)

    %% KL-UCB

    [~, KLUCB_Arm, timer1] = KLUCB(AvgThruput, Rate, Time);
    [~, DKLUCB_Arm, timer2] = DoubleKLUCB(PredProb, TranProb, Rate, Time);
    
    % Record the selected arms through out the trials
    KLUCB_SelectedArms    = [KLUCB_SelectedArms; KLUCB_Arm];
    DKLUCB_SelectedArms    = [DKLUCB_SelectedArms; DKLUCB_Arm];
    KLUCB_timer = [KLUCB_timer; timer1];
    DKLUCB_timer = [DKLUCB_timer; timer2];
end



%% Compute and plot regret and statistics
[regret_KLUCB, std_KLUCB, CI95_KLUCB] = CumRegret_woreward(AvgThruput, KLUCB_SelectedArms, Num_Trials);
[regret_DKLUCB, std_DKLUCB, CI95_DKLUCB] = CumRegret_woreward(AvgThruput, DKLUCB_SelectedArms, Num_Trials);

save("KLUCB_result.mat")

PlotRegret2(regret_KLUCB,regret_DKLUCB,std_KLUCB,std_DKLUCB,CI95_KLUCB,CI95_DKLUCB,...
    "Single Feedback KLUCB","Two-level Feedback KLUCB")

% Plot processing time in a time slot
figure
plot(mean(KLUCB_timer,1),'k', 'LineWidth',1.5);
hold on
plot(mean(DKLUCB_timer,1),'r', 'LineWidth',1.5);
grid on
xlabel('Time slot')
ylabel('Mean process time per time slot')
legend('Single Feedback KLUCB','Two-level Feedback KLUCB')

%figure
%plot(mean(regret_KLUCB,1),'k', 'LineWidth',1.5);
%grid on
%hold on

%legend('Single Feedback KLUCB','Two-level Feedback KLUCB')
