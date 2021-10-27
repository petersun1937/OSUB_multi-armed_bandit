function [regret, rSTD, rCI95] = CumRegret_woreward(Env,Arms,Num_Trials)

regret = [];

for t = 1:Num_Trials
    regret = [regret; cumsum(max(Env)- Env(Arms(t,:)))];
end

% Standard deviation of the regret
rSTD = std(regret,1);
% Standard error of the mean
SEM = rSTD/sqrt(Num_Trials);
% 95% confidence interval
rCI95 = [mean(regret,1)-1.96*SEM; mean(regret,1)+1.96*SEM]; 

end
