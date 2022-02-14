function YPred = PointForecast(trainX, trainY, testX, testY, numFea, numWin, numEnhan)
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

    YPredN = blsTrain(trainXN, trainYN, testXN, testYN, numFea, numWin, numEnhan);
    YPred = zeros(size(YPredN));

    for i = 1 : size(trainY, 2)
        maxVal = max(trainY(:, i));
        minVal = min(trainY(:, i));
        YPred(:, i) = YPredN(:, i) * (maxVal - minVal) + minVal;
    end

    idx = find(YPred < 0);
    YPred(idx) = zeros(size(idx));
end