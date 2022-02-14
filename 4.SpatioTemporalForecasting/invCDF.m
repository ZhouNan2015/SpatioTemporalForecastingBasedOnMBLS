function sample = invCDF(quantiles, cdfVal, capacity)
    [f, xi] = ksdensity(quantiles, 'Support', [-1e-6, capacity], 'Function', 'cdf');
    if cdfVal < f(1)
        sample = xi(1);
    elseif cdfVal > f(end)
        sample = xi(end);
    else
        distance = sqrt((f - cdfVal).^2);
        [~, idx] = min(distance);
        sample = xi(idx);
    end
end