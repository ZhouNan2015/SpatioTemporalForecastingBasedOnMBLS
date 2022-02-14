function cnt = countFluctuation(arr, cap)
    N = numel(arr);
    cnt = 0;
    for i = 2 : N
        if abs(arr(i) - arr(i-1)) > cap / 10
            cnt = cnt + 1;
        end
    end
end