clear
clc

capacity = [226.8, 22.6 38.3 327.6 105.9];
season = "SM";
taus = 0.05: 0.05: 0.95;

% for PVNum = 1:5
for PVNum = 1
    %% Construct dataset %%
    validMSun = 3;  NlagPSun = 19; NlagMSun = 2;
    validMNon = 3;  NlagPNon = 18; NlagMNon = 1;
    generateDataset(PVNum, season, validMSun, NlagPSun, NlagMSun, ...
    validMNon, NlagPNon, NlagMNon);

    %% Point forecasting %%
    % Sunny days
    rand('seed', 1)
    dsname = "dataset" + num2str(PVNum) + season + "Sun.mat";
    load(dsname)
    nFeaSun = 4;
    nWinSun = 20;
    nEnhanSun = 114;
    YPredSun = PointForecast(trainXSun, trainYSun, testXSun, testYSun, nFeaSun, nWinSun, nEnhanSun);
    rsname = "point" + num2str(PVNum) + season + "Sun.mat";
    save(rsname, 'YPredSun')
    RMSESun = getRMSE(testYSun, YPredSun);
 
    % Non-sunny days
    rand('seed', 1)
    dsname = "dataset" + num2str(PVNum) + season + "Non.mat";
    load(dsname)
    nFeaNon = 2;
    nWinNon = 49;
    nEnhanNon = 26;
    YPredNon = PointForecast(trainXNon, trainYNon, testXNon, testYNon, nFeaNon, nWinNon, nEnhanNon);
    rsname = "point" + num2str(PVNum) + season + "Non.mat";
    save(rsname, 'YPredNon')
    RMSENon = getRMSE(testYNon, YPredNon);
    
    %% Probabilistic forecasting %%
    % Sunny days
    cap = capacity(PVNum);
    nFeaSun = 3;
    nWinSun = 17;
    nEnhanSun = 92;
    threshold = 1e-5;
    lamVM = 1e-7;
    lamWM = 1e-2;
    lamWI = 1e-3;
    batchsize = 50;
   
    parfor step = 1:12
        rand('seed', 1)
        trainY = trainYSun(:, step);
        testY = testYSun(:, step); 
        trainX = [trainXSun trainY]; 
        testX = [testXSun YPredSun(:, step)];
        quantiles = ProbabilisticForecast(trainX, trainY, testX, testY, ...
            nFeaSun, nWinSun, nEnhanSun, taus, cap, threshold, lamVM, lamWM, lamWI, batchsize);
        filename = "Quantiles" + num2str(PVNum) + season + "Sun" + num2str(step);
        saveQuantiles(filename, quantiles, "Sun")
    end
    
    % Non-sunny days
    nFeaNon = 4;
    nWinNon = 26;
    nEnhanNon = 29;
    threshold = 1e-6;
    lamVM = 1e-4;
    lamWM = 1e-4;
    lamWI = 1e-4;
    batchsize = 20;
    
    parfor step = 1:12
        rand('seed', 1)
        trainY = trainYNon(:, step);
        testY = testYNon(:, step); 
        trainX = [trainXNon trainY]; 
        testX = [testXNon YPredNon(:, step)];
        quantiles = ProbabilisticForecast(trainX, trainY, testX, testY, ...
            nFeaNon, nWinNon, nEnhanNon, taus, cap, threshold, lamVM, lamWM, lamWI, batchsize);
        filename = "Quantiles" + num2str(PVNum) + season + "Non" + num2str(step);
        saveQuantiles(filename, quantiles, "Non")
    end
end









