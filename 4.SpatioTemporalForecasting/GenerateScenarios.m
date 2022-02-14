clear
clc

% Generate scenarios using the joint probabilistic distribution
% given by the fitted copulas
type = "Sun";
season = "SM";
filename = "CopulaResultSOM" + season + type + ".mat";
load(filename)
filename = "CopulaData" + season + type + ".mat";
load(filename)
filename = "dataset1" + season + type + ".mat";
load(filename)
method = "SOM";
% method = "Sin";

n = sunset - sunrise + 1; 
capacity = [226.8, 22.6 38.3 327.6 105.9];
Nsamples = 100;
d = size(Rhos, 1);
% T = n;
T = size(testY, 1);
scenarios = zeros(Nsamples, d, T);

for idx = 1 : T
    class = testC(idx);
    if method == "SOM"
        U = copularnd('Gaussian', Rhos(:, :, class), Nsamples);
    elseif method == "Sin"
        U = copularnd('Gaussian', Rho, Nsamples);
    else
        U = rand(Nsamples, size(Rho, 2));
    end
    
    for PVNum = 1 : 5
        for step = 1 : 12
            col = (PVNum - 1) * 12 + step;
            filename = "Quantiles" + num2str(PVNum) + season + type + num2str(step) + ".mat";
            load(filename)
            quantiles = eval("quantiles" + type);
            for i = 1 : Nsamples
                scenarios(i, col, idx) = invCDF(quantiles(idx, :), U(i, col), capacity(PVNum));
            end
        end
    end
end

scenariosN = scenarios;
testYN = testY;
for i = 1 : size(scenarios, 2)
    PVNum = floor((i - 1) / 12) + 1;
    scenariosN(:, i, :) = scenariosN(:, i, :) / capacity(PVNum);
    testYN(:, i) = testYN(:, i) / capacity(PVNum);
end

filename = "Scenarios" + method + season + type + ".mat";
save(filename, "scenariosN", "testYN")