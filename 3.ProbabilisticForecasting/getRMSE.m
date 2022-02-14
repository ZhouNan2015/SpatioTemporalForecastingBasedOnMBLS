function rmse = getRMSE(YMeas, YPred)
    nVar = size(YPred, 2);
    rmse = zeros(nVar, 1);
    for i = 1 : nVar
        rmse(i) = sqrt(sum((YPred(:, i)-YMeas(:, i)).^2)/size(YMeas,1));
    end
end