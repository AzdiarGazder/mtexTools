close all; clc; clear all; clear hidden;

%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('FontSize',14);
set(0,'DefaultFigureWindowStyle','normal');
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outofPlane');

%% Load an mtex dataset
mtexdata titanium
CS = ebsd.CS;

%% Calculate the grains
% identify grains
disp('Identifying grains...')
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',5*degree);
disp('Done!')
% remove small clusters
disp('Deleting small grain clusters...')
ebsd(grains(grains.grainSize <= 5)) = [];
disp('Done!')
% recalculate the grains
disp('Re-calculating grains...')
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',5*degree);
disp('Done!')
ori = grains.meanOrientation;


%% Plot the data
figure
plot(ebsd,ebsd.orientations);
hold all
plot(grains.boundary,'lineWidth',2);
hold off


%% Define hcp slip system(s) 
sS = [slipSystem.basal(CS,1),...
  slipSystem.prismatic2A(CS,66),...
  slipSystem.pyramidalCA(CS,80),...
  slipSystem.twinC1(CS,100)];


% Calculate the plastic anisotropy of the sheet
[minMtheta, R, Mtheta, rhoTheta] = calcLankford(ori,sS);



figure
plot(linspace(0,1,11), Mtheta(:,[1,19]).','s-','lineWidth',1.5);
xlabel('{\rho} = -d{\epsilon}_Y / d{\epsilon}_X');
ylabel('Relative strength, M = {\sigma}_x / {\tau}');
% % This is recreates Fig. 3.10 on page 74 of:
% % William F. Hosford, The mechanics of crystals and textured polycrystals
% % https://onlinelibrary.wiley.com/doi/epdf/10.1002/crat.2170290414
% % Dependence of M on rho = -d{\epsilon}_Y / d{\epsilon}_X for rolling 
% % and transverse direction tension tests for an ideal (1 1 0)[1 -1 2]
% % Brass orientation. In the rolling direction test x = [1 -1 2], and 
% % in the transverse test x = [-1 1 1].
 
figure
plot(linspace(0,90,19),rhoTheta,'o-r','lineWidth',1.5);
xlabel('Angle to tensile direction, {\theta} (in degrees)');
ylabel('{\rho} = -d{\epsilon}_Y / d{\epsilon}_X');

figure;
plot(linspace(0,90,19),minMtheta,'o-b','lineWidth',1.5);
xlabel('Angle to tensile direction, {\theta} (in degrees)');
ylabel('Min. relative strength, min(M) = min({\sigma}_x / {\tau}_m_i_n_(_M_))');

figure
plot(linspace(0,90,19),R,'o-r','lineWidth',1.5);
xlabel('Angle to tensile direction, {\theta} (in degrees)');
ylabel('R @ M_m_i_n, R = {\rho} / (1 - {\rho}) = -d{\epsilon}_Y / d{\epsilon}_Z');

