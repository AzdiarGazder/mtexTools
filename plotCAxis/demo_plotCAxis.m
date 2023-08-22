%% Demonstration description:
% This script demonstrates how to plot the angle between the c-axis of the 
% hexagonal unit cell and a macroscopic specimen axis.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  demo_mergeTwins
%
%% Input:
%  none
%
%% Output:
%  none
%
%% Options:
%  none
%%


% clear variables
clc; clear all; clear hidden; close all;

% start Mtex
startup_mtex;

% define Mtex plotting convention as X = right, Y = up
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('FontSize', 24);

% load mtex example data
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
plot(grains,grains.meanOrientation);
%%



%% Identify grain boundaries
gB = grains(CS.mineral).boundary(CS.mineral,CS.mineral);
%%



%% Define the twin
% Method 1: Define a twin as an orientation with angle-axis = 60 deg / <0001>
twin = orientation('axis',Miller(-1,2,-1,0,CS),'angle',86*degree,CS,CS);
% Method 2: Define a twin as a misorientation
% twin = orientation.map(Miller(0,1,-1,-1,CS),Miller(-1,1,0,-1,CS),...
%   Miller(1,0,-1,1,CS,'uvw'),Miller(1,0,-1,-1,CS,'uvw'))
%%



%% Identify twin boundaries
% Method 1
tB = gB(gB.isTwinning(twin, 5*degree));
% % Method 2
% isTwinning = angle(gB.misorientation,twin) <= 5*degree; % restrict twin boundaries by defining a threshold value
% tB = gB(isTwinning); % identify the twins from the grain boundaries
%%



%% Make subsets of the "grains" variable with and without twins
% In this method, "grains" are not merged.
% The original grain list is preserved.
%---
% find ids of grains with twin boundaries
grainId_withTBs = unique(reshape(tB.grainId,[],1));
grains_withTBs = grains(grainId_withTBs); % subset of grains with twins
figure;
% plot the grains with twins
plot(grains_withTBs);
hold all;
% plot the twin boundaries in red
plot(tB,'linecolor','r','linewidth',1,'displayName','TBs');
hold off;
%---
% find the ids of grains without twin boundaries
% (in case of multi-phase maps, this may include other phases as well)
grainId_withoutTBs = grains(~ismember(grains.id,grainId_withTBs)).id;
grains_withoutTBs = grains(grainId_withoutTBs);
grains_withoutTBs = grains_withoutTBs(CS.mineral);  % subset of grains without twins
figure;
% plot the grains without twins
plot(grains_withoutTBs);
hold all;
% plot the twin boundaries in red
plot(tB,'linecolor','r','linewidth',1,'displayName','TBs');
hold off;
%%



% define the crystal direction of interest
h = Miller(0,0,0,1,CS);
%---

% define the grain mean orientations
meanOri = grains(CS.mineral).meanOrientation;
meanOri_withTBs = grains_withTBs.meanOrientation;
meanOri_withoutTBs = grains_withoutTBs.meanOrientation;
%---

% calculate 'h' in the specimen coordinate system
vecH = meanOri .* h;
vecH_withTBs = meanOri_withTBs .* h;
vecH_withoutTBs = meanOri_withoutTBs .* h;
%---

% calculate the angle between the vector of crystal direction 'h' in 
% the specimen coordinate system and one of the specimen axes
ang = angle(vecH, xvector)./degree;
ang_withTBs = angle(vecH_withTBs, xvector)./degree;
ang_withoutTBs = angle(vecH_withoutTBs, xvector)./degree;
%---

% % if the exact direction is not important, find angles > 90 deg...
% % and subtract from 180 deg
% ang(ang > 90) = 180 - ang(ang > 90);
% ang_withTBs(ang > 90) = 180 - ang_withTBs(ang_withTBs > 90);
% ang_withoutTBs(ang > 90) = 180 - ang_withoutTBs(ang_withoutTBs > 90);
% %---

% plot a map of grains showing the c-axis angular distribution
figure;
plot(grains(CS.mineral),ang)
colormap jet
%---


% define the angular range to display in the c-axis angular 
% distribution
minAng = 0; maxAng = 180;
% define the class interval for the histogram
classInterval = 1;
% define the class range for the histogram
classRange = minAng: classInterval: maxAng;
% calculate the absolute counts in each class interval
absCounts_withTBs = histc(ang_withTBs,classRange);
absCounts_withoutTBs = histc(ang_withoutTBs,classRange);
% normalise the absolute counts in each class interval
normCounts_withTBs = 100.*(absCounts_withTBs ./ sum(absCounts_withTBs));
normCounts_withoutTBs = 100.*(absCounts_withoutTBs ./ sum(absCounts_withoutTBs));
% plot the bar graph based on class specifications
figure;
h1 = bar(classRange, absCounts_withoutTBs, 'histc')
set(h1,'FaceColor',[1 0 0],'EdgeColor',[0 0 0],'LineWidth',1);
hold all
h2 = bar(classRange, absCounts_withTBs, 'histc')
set(h2,'FaceColor',[0 0 1],'EdgeColor',[0 0 0],'LineWidth',1);
legend('without TBs','with TBs');
set(gca, 'xlim',[classRange(1) classRange(end)]);
% annotate the graph axes and title
xlabel('c-Axis angle from specimen X-axis (degrees)','FontSize',14);
ylabel('Absolute counts', 'FontSize',14);
% output the bar graph data in the command window
xy_withTBs = [classRange', absCounts_withoutTBs]
xy_withoutTBs = [classRange', absCounts_withTBs]
hold off;
%---


% plot a scatter plot of shape factor versus aspect ratio to check for 
% correlation. The size of the dots corresponds to the area of the grains.
% http://mtex-toolbox.github.io/files/doc/GrainStatistics.html
figure;
scatter(grains_withoutTBs.shapeFactor, grains_withoutTBs.aspectRatio, 70*grains_withoutTBs.area./max(grains_withoutTBs.area), 'MarkerEdgeColor',[1 0 0],'LineWidth',1)
hold all
scatter(grains_withTBs.shapeFactor, grains_withTBs.aspectRatio, 70*grains_withTBs.area./max(grains_withTBs.area), 'MarkerEdgeColor',[0 0 1],'LineWidth',1)
legend('without TBs','with TBs');
xlabel('Grain shape factor','FontSize',14);
ylabel('Grain aspect ratio', 'FontSize',14);
hold off
%---
