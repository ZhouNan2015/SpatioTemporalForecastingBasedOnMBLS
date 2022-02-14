clear
clc

% Fitting copula functions according to clustering result
season = "SM";
filename = "CopulaData" + season + "Sun.mat";
load(filename)
filename = "UMatrices" + season + "Sun.mat";
load(filename)

NC = max([trainC; testC]);
d = size(trainY, 2);
Rhos = zeros(d, d, NC);
for class = 1 : NC
    idx = find(trainC == class);
    U = UTrain(idx, :);
    X = trainY(idx, :);
    Rhos(:, :, class) = copulafit("gaussian", U);
end
filename = "CopulaResultSOM" + season + "Sun.mat";
save(filename, "Rhos")

season = "SM";
filename = "CopulaData" + season + "Non.mat";
load(filename)
filename = "UMatrices" + season + "Non.mat";
load(filename)

NC = max([trainC; testC]);
d = size(trainY, 2);
Rhos = zeros(d, d, NC);
for class = 1 : NC
    idx = find(trainC == class);
    U = UTrain(idx, :);
    X = trainY(idx, :);
    Rhos(:, :, class) = copulafit("gaussian", U);
end
filename = "CopulaResultSOM" + season + "Non.mat";
save(filename, "Rhos")