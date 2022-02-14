function [] = generateDataset(PVNum, season, validMSun, NlagPSun, NlagMSun, ...
    validMNon, NlagPNon, NlagMNon)
    load rawData
    cap = [226.8, 22.6 38.3 327.6 105.9];
    time = eval("time" + season);
    PV = eval("PV" + season);
    meteor = eval("meteor" + season);

    % Classify sunny and non-sunny days accoring to the output curves of PV1
    Ndays = size(PV, 1) / 288;
    cnt = zeros(Ndays, 1);
    maxOut = zeros(Ndays, 1);

    for i = 1 : Ndays
        PVi = PV((i-1)*288+1:i*288, 1);
        cnt(i) = countFluctuation(PVi, cap(1));
        maxOut(i) = max(PVi);
    end
    idx1 = find(cnt <= 1); idx2 = find(maxOut > 0.6 * cap(1));
    idxSunny = intersect(idx1, idx2);
    idxNonSunny = setdiff(1:Ndays, idxSunny)';

    % for i = idxSunny'
    %     figure
    %     PVi = PVAT((i-1)*288+1:i*288, 1);
    %     plot(PVi)
    % end

    rangeSun = [];  rangeNon = [];
    for i = idxSunny'
        rangeSun = [rangeSun (i-1)*288+1 : i*288];
    end
    for i = idxNonSunny'
        rangeNon = [rangeNon (i-1)*288+1 : i*288];
    end

    timeSun = time(rangeSun, :);
    timeNon = time(rangeNon, :);
    PVSun = PV(rangeSun, PVNum);
    PVNon = PV(rangeNon, PVNum);
    meteorSun = meteor(rangeSun, :);
    meteorNon = meteor(rangeNon, :);
   
    idx = find(PV(:, 1) > 0);
    ts = [];
    for i = 1 : Ndays
        ts = [ts 1:288];
    end
    sunrise = min(ts(idx)) - 12 + 1;
    sunset = max(ts(idx));
    n = sunset - sunrise + 1;  Ntest = n * 10;
    Nlead = 12;

    %%%%%%% Generate dataset of sunny days %%%%%%
    [XSun, YSun] = formatData(PVSun, meteorSun, validMSun, NlagPSun, NlagMSun, Nlead);
    NdaysSun = size(XSun, 1) / 288;
    range = [];
    for i = 0 : NdaysSun - 1
        range = [range sunrise + 1 + 288 * i : sunset + 1 + 288 * i];
    end
    XSun = XSun(range, :);
    YSun = YSun(range, :);

    testXSun = XSun(end-Ntest+1 : end, :);
    testYSun = YSun(end-Ntest+1 : end, :);
    trainXSun = XSun(1:end-Ntest, :);
    trainYSun = YSun(1:end-Ntest, :);

    %%%%%%% Generate dataset of non-sunny days %%%%%%
    [XNon, YNon] = formatData(PVNon, meteorNon, validMNon, NlagPNon, NlagMNon, Nlead);
    NdaysNon = size(XNon, 1) / 288;
    range = [];
    for i = 0 : NdaysNon - 1
        range = [range sunrise + 1 + 288 * i : sunset + 1 + 288 * i];
    end
    XNon = XNon(range, :);
    YNon = YNon(range, :);

    testXNon = XNon(end-Ntest+1 : end, :);
    testYNon = YNon(end-Ntest+1 : end, :);
    trainXNon = XNon(1:end-Ntest, :);
    trainYNon = YNon(1:end-Ntest, :);
    
    nameSun = "dataset" + num2str(PVNum) + season + "Sun.mat";
    nameNon = "dataset" + num2str(PVNum) + season + "Non.mat";
    save(nameSun, 'trainXSun', 'trainYSun', 'testXSun', 'testYSun', 'sunset', 'sunrise')
    save(nameNon, 'trainXNon', 'trainYNon', 'testXNon', 'testYNon', 'sunset', 'sunrise')
end