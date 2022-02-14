function quantiles = ProbabilisticForecast(trainX, trainY, testX, testY, ...
    numFea, numWin, numEnhan, taus, capacity, threshold, lamVM, lamWM, lamWI, batchsize)
    trainXN = zeros(size(trainX));
    trainYN = zeros(size(trainY));
    testXN = zeros(size(testX));
    testYN = zeros(size(testY));

    % Data normalization
    for i = 1 : size(trainX, 2)
        maxVal = max(trainX(:, i));
        minVal = min(trainX(:, i));
        trainXN(:, i) = (trainX(:, i) - minVal) / (maxVal - minVal);
        testXN(:, i) = (testX(:, i) - minVal) / (maxVal - minVal);
    end
    for i = 1 : size(trainY, 2)
        maxVal = max(trainY(:, i));
        minVal = min(trainY(:, i));
        trainYN(:, i) = (trainY(:, i) - minVal) / (maxVal - minVal);
        testYN(:, i) = (testY(:, i) - minVal) / (maxVal - minVal);
    end
    capacityN = (capacity - min(trainY(:, 1))) / (max(trainY(:, 1)) - min(trainY(:, 1)));

    idxM = 1;
    [trainXS, trainYS, testXS, testYS] = stackDataset(trainXN, trainYN, ...
        testXN, testYN, taus);

    tic
    YPredN = QRMBLS(trainXS, trainYS, testXS, testYS, numFea, numWin, numEnhan, ...
        idxM, taus, capacityN, threshold, lamVM, lamWM, lamWI, batchsize);
    time = toc;
    disp("time = " + num2str(time))
    NK = size(testXS, 1)   ;
    K = numel(taus);
    N = NK / K; 

    YPred = zeros(size(YPredN));

    for i = 1 : size(trainY, 2)
        maxVal = max(trainY(:, i));
        minVal = min(trainY(:, i));
        YPred(:, i) = YPredN(:, i) * (maxVal - minVal) + minVal;
    end

    quantiles = reshape(YPred, N, K);
end