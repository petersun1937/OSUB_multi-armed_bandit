function ucb = DoubleKLBinSearch(d,mu1,mu2)

K = length(mu1);

% Initialize upper bounds and lower bounds
lbp = mu1; ubp = min(1,mu1+sqrt(d/2)); 
lbq = mu2; ubq = min(1,mu2+sqrt(d/2));
%lbp = zeros(size(mu1)); ubp = ones(size(mu1)); 
%lbq = zeros(size(mu1)); ubq = ones(size(mu1));

for j = 1:2^(K)
    % Pick p,q as the middle value of upperbounds and lowerbounds
    p = (ubp+lbp)/2;
    q = (ubq+lbq)/2;
    
    y1 = KLDiv(mu1,p);
    y2 = KLDiv(mu2,q);

    % Check which elements(arms) in sum of y1,y2 is greater than d
    % If yes, update the corresponding values in p
    % as upperbounds and the rest as lowerbounds
    down = y1+y2 > d;  

    ubp(down) = p(down);    lbp(~down) = p(~down);
    ubq(down) = q(down);    lbq(~down) = q(~down);
end
% Maximize the product of p,q
ucb = ubp.*ubq;

end