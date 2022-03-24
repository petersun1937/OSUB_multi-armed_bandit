function [k,Gamma] = F_TS_2lv(S1,S2,F1,F2)

    Alpha = [];  Beta=[];
    for n = 1:length(S1)
        % Generate probabilities with Beta distribution
       Alpha = [Alpha betarnd(S1(n)+1,F1(n)+1)]; 
       Beta = [Beta betarnd(S2(n)+1,F2(n)+1)];
    end
    Gamma = Alpha.*Beta;
    
    m = max(Gamma);
    % Randomly pick one of the max-valued arm
    mI = find(Gamma == m);
    k = mI(randi(length(mI)));         

end