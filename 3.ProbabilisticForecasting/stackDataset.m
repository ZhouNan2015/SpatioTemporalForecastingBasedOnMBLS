function [trainXS, trainYS, testXS, testYS] = stackDataset(trainX, trainY, ...
    testX, testY, taus)
    K = numel(taus);
    Ntrain = size(trainX, 1);
    Ntest = size(testX, 1);
    Nfea = size(trainX, 2);
    Ntarg = size(trainY, 2);
    trainXS = zeros(K * Ntrain, Nfea + 1);
    trainYS = zeros(K * Ntrain, Ntarg);
    testXS = zeros(K * Ntest, Nfea + 1);
    testYS = zeros(K * Ntest, Ntarg);
    for i = 1 : K
        trainXS((i-1)*Ntrain+1: i*Ntrain, 1) = taus(i) * ones(Ntrain, 1);
        trainXS((i-1)*Ntrain+1: i*Ntrain, 2:end) = trainX;
        trainYS((i-1)*Ntrain+1: i*Ntrain, :) = trainY;
        testXS((i-1)*Ntest+1: i*Ntest, 1) = taus(i) * ones(Ntest, 1);
        testXS((i-1)*Ntest+1: i*Ntest, 2:end) = testX;
        testYS((i-1)*Ntest+1: i*Ntest, :) = testY;
    end
end