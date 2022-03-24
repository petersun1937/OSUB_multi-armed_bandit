function [k,Gamma] = F_TS(S,F)

    Gamma = [];
    for n = 1:length(S)
        % Generate probabilities with Beta distribution
        Gamma = [Gamma betarnd(S(n)+1,F(n)+1)];
    end

    m = max(Gamma);
    % Randomly pick one of the max-valued arm
    mI = find(Gamma == m);
    k = mI(randi(length(mI)));         

end