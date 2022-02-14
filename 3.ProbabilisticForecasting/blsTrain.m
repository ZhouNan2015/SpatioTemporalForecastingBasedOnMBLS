function [YTest, HiddenLayer] = blsTrain(trainX, trainY, testX, testY, ...
    numFea, numWin, numEnhan)
%%%%%%%%%%%%%%%%%%%%%%%%%%Training Stage%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
% Generate feature nodes
Z = zeros(size(trainX, 1), numWin * numFea);
Xbias = [trainX, 0.1 * ones(size(trainX,1),1)];
for i = 1:numWin
    weightFea = 2 * rand(size(trainX,2)+1,numFea) - 1;
    T1 = Xbias * weightFea;
    T1 = mapminmax(T1);
    clear weightFea;

    weightFeaSparse = blsSparse(T1,Xbias,1e-3,50)';
    WFSparse{i} = weightFeaSparse;
    
    Zi = Xbias * weightFeaSparse;
    [Zi, psi] = mapminmax(Zi',0,1);    
    Zi = Zi';   ps(i) = psi;
    Z(:, numFea*(i-1)+1:numFea*i) = Zi;
end
clear XBias; clear Zi;

% Generate enhancement nodes
Zbias = [Z, 0.1 * ones(size(Z,1),1)];
weightEnhan = 2 * rand(numWin*numFea+1, numEnhan) - 1;
H = tansig(Zbias * weightEnhan);
A = [Z, H];
HiddenLayer = A;
clear Zbias; clear H;

% Calculate output weights
inv = pinv(A);
W = inv * trainY;
% trainingTime = toc;

%%%%%%%%%%%%%%%%%%%%%%%%%%Testing Stage%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
XbiasTest = [testX 0.1 * ones(size(testX,1),1)];
ZTest = zeros(size(testX, 1), numWin * numFea);
for i = 1:numWin
    weightFeaSparse = WFSparse{i};   ps1=ps(i);
    ZiTest = XbiasTest * weightFeaSparse;
    ZiTest = mapminmax('apply', ZiTest', ps1)';
    
    clear weigthSparse; clear ps1;
    ZTest(:, numFea*(i-1)+1:numFea*i) = ZiTest;
end
clear XbiasTest; clear ZiTest;

ZbiasTest = [ZTest 0.1 * ones(size(ZTest,1),1)];
HTest = tansig(ZbiasTest * weightEnhan);
ATest = [ZTest HTest];
clear ZbiasTest; clear HTest;
YTest = ATest * W;

% testingTime = toc;
% disp(['The Total Time is: ', num2str(trainingTime + testingTime), ' seconds' ]);
