clear
clc

% path1 = "Yulara_2017.csv";
% path2 = "Yulara_2018.csv";
% 
% [time2017, data2017] = loadData(path1);
% [time2018, data2018] = loadData(path2);
% 
% [time2017, PV2017, meteor2017] = cleanseData(time2017, data2017);
% [time2018, PV2018, meteor2018] = cleanseData(time2018, data2018);
% 
% save('dataSummary.mat', "time2017", "PV2017", "meteor2017", "time2018", ...
%     "PV2018", "meteor2018");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Division of different seasons
load dataSummary
time = [time2017; time2018];
PV = [PV2017; PV2018];
meteor = [meteor2017; meteor2018];

% SP: spring (Sept., Oct., Nov.)
% SM: summer (Jan., Feb., Dec.)
% AT: autumn (Mar., Apr., May)
% WT: winter (June, July, Aug.)
idxSP = find(time(:, 1) >= 9 & time(:, 1) <= 11);
timeSP = time(idxSP, :);  PVSP = PV(idxSP, :);  meteorSP = meteor(idxSP, :);
idxSM = find(time(:, 1) <= 2 | time(:, 1) >= 12);
timeSM = time(idxSM, :);  PVSM = PV(idxSM, :);  meteorSM = meteor(idxSM, :);
idxAT = find(time(:, 1) >= 3 & time(:, 1) <= 5);
timeAT = time(idxAT, :);  PVAT = PV(idxAT, :);  meteorAT = meteor(idxAT, :);
idxWT = find(time(:, 1) >= 6 & time(:, 1) <= 8);
timeWT = time(idxWT, :);  PVWT = PV(idxWT, :);  meteorWT = meteor(idxWT, :);

filename = "rawData.mat";
save(filename, "timeSP", "PVSP", "meteorSP", ...
               "timeSM", "PVSM", "meteorSM", ...
               "timeAT", "PVAT", "meteorAT", ...
               "timeWT", "PVWT", "meteorWT");



