function l_0 = Compute_min_l_0(delta, n)

for x=7:n
    if sqrt((log(x)+3*log(log(x)))/(2*floor(x/6))) < delta
        l_0 = x;
        break
    end
end
