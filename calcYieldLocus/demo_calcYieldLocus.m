%% Initialise Mtex
clc; clear all; clear hidden; close all;
startup_mtex;


%% define Mtex plotting convention as X = right, Y = up
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('FontSize', 24);

%% load mtex example data
mtexdata twins


%% Calculate the grains
% identify grains
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',5*degree,'unitcell');
% remove small clusters
ebsd(grains(grains.grainSize <= 5)) = [];
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',5*degree,'unitcell');
% smooth the grains
grains = grains.smooth(5);
% store the crystal symmetry of magnesium for later use
CS = grains.CS;
% plot the grains
figure;
plot(grains,grains.meanOrientation)
%%


%% Define fcc slip system(s)
b = Miller(1,-1,0,CS,'uvw'); % slip direction
n = Miller(1,1,-1,CS,'hkl'); % slip plane normal
sS1 = slipSystem(b,n)

b = Miller(1,1,2,CS,'uvw'); % slip direction
n = Miller(1,1,-1,CS,'hkl'); % slip plane normal
sS2 = slipSystem(b,n)

sS = [sS1, sS2];


%% Preparing the input for the yield locus function
% Using the Taylor factor (works on all crystal systems and slip system 
% combinations)
[sXX_sYY, sXX_sZZ, sYY_sZZ] = calcYieldLocus(grains.meanOrientation,'method','taylor',sS,'points',90); 

% Using the Bishop-Hill criterion (only works for cubic systems with 24 
% slip systems only)
% stressStates = calcBHStressStates(sS); % calculate the Bishop-Hill stress states
% [sXX_sYY, sXX_sZZ, sYY_sZZ] = calcYieldLocus(grains.meanOrientation,'method','bishopHill',stressStates,'points',90); 
%% --- 



%% Plotting the yield locus 
figure
plot(sXX_sYY(:,1), sXX_sYY(:,2), 'r', 'linewidth', 1.5);
pbaspect([1 1 1]);
xlim([-2 2]);
ylim([-2 2]);
xlabel('\sigma_{\it X}_{\it X}');
ylabel('\sigma_{\it Y}_{\it Y}');



figure
plot(sXX_sZZ(:,1), sXX_sZZ(:,2), 'k', 'linewidth', 1.5);
pbaspect([1 1 1]);
xlim([-2 2]);
ylim([-2 2]);
xlabel('\sigma_{\it X}_{\it X}');
ylabel('\sigma_{\it Z}_{\it Z}');
hold all


figure
plot(sYY_sZZ(:,1), sYY_sZZ(:,2), 'b', 'linewidth', 1.5);
pbaspect([1 1 1]);
xlim([-2 2]);
ylim([-2 2]);
xlabel('\sigma_{\it Y}_{\it Y}');
ylabel('\sigma_{\it Z}_{\it Z}');
hold all

