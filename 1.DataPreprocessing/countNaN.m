function numNaN = countNaN(arr)
    abnorm = find(isnan(arr));
    numNaN = zeros(365, 1);
    for i = abnorm'
        date = floor((i-1)/288 + 1);
        numNaN(date) = numNaN(date) + 1;
    end
end