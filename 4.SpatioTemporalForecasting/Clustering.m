clear
clc

load rawData
season = "SM";

% Sunny days
rand('seed', 1)
NlagP = 19; NlagM = 2; Nlead = 12;
dsname = "dataset1" + season + "Sun.mat";
load(dsname)
Nmeteor = 1;
Ntrain = size(trainXSun, 1);
trainX = zeros(Ntrain, NlagP * 5 + Nmeteor*NlagM);
trainY = zeros(Ntrain, Nlead * 5);
Ntest = size(testXSun, 1);
testX = zeros(Ntest, NlagP * 5 + Nmeteor*NlagM);
testY = zeros(Ntest, Nlead * 5);

for i = 1 : 5
    dsname = "dataset" + num2str(i) + season + "Sun.mat";
    load(dsname)
    range1 = (i-1) * NlagP + 1 : i * NlagP;
    trainX(:, range1) = trainXSun(:, 1:NlagP);
    testX(:, range1) = testXSun(:, 1:NlagP); 
    range2 = (i-1) * Nlead + 1 : i * Nlead;
    trainY(:, range2) = trainYSun;
    testY(:, range2) = testYSun;
end
trainX(:, end-Nmeteor*NlagM:end) = trainXSun(:, end-Nmeteor*NlagM:end);
testX(:, end-Nmeteor*NlagM:end) = testXSun(:, end-Nmeteor*NlagM:end);

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

X = [trainXN; testXN];
NA = 2; NB = 3;
net = selforgmap([NA NB], 100);
net = train(net, X');
SOMout = net(X');
classes = vec2ind(SOMout)';
trainC = classes(1:Ntrain);    testC = classes(Ntrain+1:end);

filename = "CopulaData" + season + "Sun.mat";
save(filename, "trainY", "testY", "trainC", "testC");


% Non-Sunny days
rand('seed', 1)
NlagP = 18; NlagM = 1; Nlead = 12;
dsname = "dataset1" + season + "Non.mat";
load(dsname)
Nmeteor = 1;
Ntrain = size(trainXNon, 1);
trainX = zeros(Ntrain, NlagP * 5 + Nmeteor*NlagM);
trainY = zeros(Ntrain, Nlead * 5);
Ntest = size(testXNon, 1);
testX = zeros(Ntest, NlagP * 5 + Nmeteor*NlagM);
testY = zeros(Ntest, Nlead * 5);
for i = 1 : 5
    dsname = "dataset" + num2str(i) + season + "Non.mat";
    load(dsname)
    range1 = (i-1) * NlagP + 1 : i * NlagP;
    trainX(:, range1) = trainXNon(:, 1:NlagP);
    testX(:, range1) = testXNon(:, 1:NlagP); 
    range2 = (i-1) * Nlead + 1 : i * Nlead;
    trainY(:, range2) = trainYNon;
    testY(:, range2) = testYNon;
end
trainX(:, end-Nmeteor*NlagM:end) = trainXNon(:, end-Nmeteor*NlagM:end);
testX(:, end-Nmeteor*NlagM:end) = testXNon(:, end-Nmeteor*NlagM:end);

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

X = [trainXN; testXN];
NA = 3; NB = 2;
net = selforgmap([NA NB], 100);
net = train(net, X');
SOMout = net(X');
classes = vec2ind(SOMout)';
trainC = classes(1:Ntrain);    testC = classes(Ntrain+1:end);

filename = "CopulaData" + season + "Non.mat";
save(filename, "trainY", "testY", "trainC", "testC");