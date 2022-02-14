clear
clc
PVNum = 1;  SEASON = "SM";
filename1 = "dataset" + num2str(PVNum) + SEASON + "Sun.mat";
filename2 = "dataset" + num2str(PVNum) + SEASON + "Non.mat";
load(filename1)
load(filename2)
rand('seed', 1)


trainX = trainXSun;  trainY = trainYSun;
testX = testXSun;  testY = testYSun;
% trainX = trainXNon;  trainY = trainYNon;
% testX = testXNon;  testY = testYNon;

n = sunset - sunrise + 1;
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

% Optimal BLS hyperparameter determined using grid search
numFea = 4;
numWin = 20;
numEnhan = 114;
% numFea = 2;
% numWin = 49;
% numEnhan = 26;
timer = tic;
[YPredN, H] = blsTrain(trainXN, trainYN, testXN, testYN, numFea, numWin, numEnhan);
time = toc(timer);

YPred = zeros(size(YPredN));
% Data reverse normalization
for i = 1 : size(trainY, 2)
    maxVal = max(trainY(:, i));
    minVal = min(trainY(:, i));
    YPred(:, i) = YPredN(:, i) * (maxVal - minVal) + minVal;
end

idx = find(YPred < 0);
YPred(idx) = zeros(size(idx));
RMSE = getRMSE(testY, YPred);

% Plot point forecasting results
date = 1;
for step = 1 : numel(RMSE)
    figure(step)
    range = (date-1) * n + 1 : date * n;
    plot(YPred(range, step));
    hold on
    plot(testY(range, step)); 
    legend("Predicted", "Measured")
end


YPredSun = YPred;
resultName1 = "point" + num2str(PVNum) + SEASON + "Sun.mat";
save(resultName1, 'testYSun', 'YPredSun');
% YPredNon = YPred;
% resultName2 = "point" + num2str(PVNum) + SEASON + "Non.mat";
% save(resultName2, 'testYNon', 'YPredNon');
