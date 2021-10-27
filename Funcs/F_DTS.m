function [k] = F_DTS(S1,S2,F1,F2)

    %% Recommend arms
    Gamma = [];
    for n = 1:length(S)
        % Generate probabilities with Beta distribution
       Alpha = [Alpha betarnd(S1(n)+1,F1(n)+1)]; 
       Beta = [Beta betarnd(S2(n)+1,F2(n)+1)];
    end

    %% Apply the arm (selected rate) and observe
    m = max(Gamma);
    % Randomly pick one of the max-valued arm
    if ( ~isnan(m))
        mI = find(Gamma == m);
        k = mI(randi(length(mI)));         
    else
        k = randi(length(Gamma));
    end

end