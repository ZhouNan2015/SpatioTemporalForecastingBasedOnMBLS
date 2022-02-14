clear
clc

% Calculating marginal PDFs and CDFs
season = "SM";
filename = "CopulaData" + season + "Sun.mat";
load(filename)
capacity = [226.8, 22.6 38.3 327.6 105.9];
Ntrain = size(trainY, 1);
X = [trainY; testY];
[N, dim] = size(X);
U = zeros(N, dim);
f = zeros(N, dim);
for i = 1 : dim
    PVNum = floor((i-1) / 12) + 1;
    x = X(:, i);
    U(:, i) = ksdensity(x, x, 'function', 'cdf', 'support', [-1e-6, capacity(PVNum)]);
    f(:, i) = ksdensity(x, x, 'function', 'pdf', 'support', [-1e-6, capacity(PVNum)]);
end
UTrain = U(1:Ntrain, :);    UTest = U(Ntrain+1:end, :);
fTrain = f(1:Ntrain, :);    fTest = f(Ntrain+1:end, :);
Uname = "UMatrices" + season + "Sun.mat";
fname = "fMatrices" + season + "Sun.mat";
save(Uname, "UTrain", "UTest");
save(fname, "fTrain", "fTest");


season = "SM";
filename = "CopulaData" + season + "Non.mat";
load(filename)
capacity = [226.8, 24 38.3 327.6 105.9];
Ntrain = size(trainY, 1);
X = [trainY; testY];
[N, dim] = size(X);
U = zeros(N, dim);
f = zeros(N, dim);
for i = 1 : dim
    PVNum = floor((i-1) / 12) + 1;
    x = X(:, i);
    U(:, i) = ksdensity(x, x, 'function', 'cdf', 'support', [-1e-6, capacity(PVNum)]);
    f(:, i) = ksdensity(x, x, 'function', 'pdf', 'support', [-1e-6, capacity(PVNum)]);
end
UTrain = U(1:Ntrain, :);    UTest = U(Ntrain+1:end, :);
fTrain = f(1:Ntrain, :);    fTest = f(Ntrain+1:end, :);
Uname = "UMatrices" + season + "Non.mat";
fname = "fMatrices" + season + "Non.mat";
save(Uname, "UTrain", "UTest");
save(fname, "fTrain", "fTest");