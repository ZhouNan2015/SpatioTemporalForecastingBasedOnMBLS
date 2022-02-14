clear
clc

% Fitting a single copula function using all historical data
season = "SM";
filename = "CopulaData" + season + "Sun.mat";
load(filename)
filename = "UMatrices" + season + "Sun.mat";
load(filename)


U = UTrain;
X = trainY;

Rho = copulafit("gaussian", U);
% imagesc(Rho)
% colorbar
% set(gca,'FontSize',14);
% set(gca, 'fontname', 'times');

filename = "CopulaResultSingle" + season + "Sun.mat";
save(filename, "Rho")


filename = "CopulaData" + season + "Non.mat";
load(filename)
filename = "UMatrices" + season + "Non.mat";
load(filename)


U = UTrain;
X = trainY;

Rho = copulafit("gaussian", U);
% imagesc(Rho)
% colorbar
% set(gca,'FontSize',14);
% set(gca, 'fontname', 'times');

filename = "CopulaResultSingle" + season + "Non.mat";
save(filename, "Rho")
