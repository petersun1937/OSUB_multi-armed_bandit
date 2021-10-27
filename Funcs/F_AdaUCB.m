function [kt] = F_AdaUCB(mu,T,Time)

    k = length(T);
    %mu = zeros(1,K);
    
    %{
    K = zeros(size(mu));
    for i=1:k
        for j=1:k
            %K(i) = K(i) + min(1,sqrt(T(j)/T(i)));
            K(i) = K(i) + min(T(i),sqrt(T(i)*T(j)));
        end
    end
    %}
    
    K = 0;
    for i=1:k
        for j=1:k
        K = K + min(T(i),sqrt(T(i)*T(j)));
        end
    end
    %}
    H = T.*K;
    f = mu+sqrt((2./T).*log(Time./(K)));
    %% Pick the arm with max index 
    m = max(f);
    % Randomly pick one of the max-valued arm
    if ( ~isnan(m))
    mI = find(f == m);
    kt = mI(randi(length(mI)));
    else
    kt = randi(length(mu));
    end
        
        
end
    
