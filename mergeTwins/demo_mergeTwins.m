%% Demonstration description:
% This script demonstrates how to correctly separate grains with and 
% without twins and how to correctly merge grains containing twins.
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
plot(grains,grains.meanOrientation)
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



%% Working with the subset of grains with twins
% create an ebsd variable from the subset of grains with twins
ebsd_withTBs = ebsd(grains_withTBs);
% reconstruct grains from the ebsd variable from the subset of grains with twins
[g_withTBs,ebsd_withTBs.grainId,ebsd_withTBs.mis2mean] = calcGrains(ebsd_withTBs('indexed'),'angle',5*degree,'unitcell');
% identify the grain boundaries of the subset
gB_withTBs = g_withTBs(CS.mineral).boundary(CS.mineral,CS.mineral);
% identify the twin boundaries of the subset
tB_withTBs = gB_withTBs(gB_withTBs.isTwinning(twin, 5*degree));
% merge the grains in the subset with twins
[gMerged_withTBs,mergeId_withTBs] = merge(g_withTBs,tB_withTBs);
figure;
% plot the merged grains that used to contain twins
plot(gMerged_withTBs);
hold all;
% plot the twin boundaries in red
plot(tB,'linecolor','r','linewidth',1,'displayName','TBs');
hold off;
%%







%% Merge "grains" with twins
% In this method, "grains" are merged.
% The original grain list is NOT preserved.
%---
% merge the original grains
[newGrains,mergeId] = merge(grains,tB);
% generate lists of new grains that originally:(i) contained twins, and
% (ii) did not contain twins.
% count how often a grainId occurs in the mergedId list
counts = histc(mergeId,unique(mergeId));
withTBs = counts > 1; % list of grains that contained twins
% new grains that originally contained twins and were subsequently merged
newGrains_withTBs = newGrains(withTBs);
figure;
% plot the merged grains that originally contained twins
plot(newGrains_withTBs);
hold all;
% plot the twin boundaries in red
plot(tB,'linecolor','r','linewidth',1,'displayName','TBs');
hold off;
%---
% new grains that originally did not contain twins and were untouched during the merger
newGrains_withoutTBs = newGrains(~withTBs);
newGrains_withoutTBs = newGrains_withoutTBs(CS.mineral);
figure;
% plot the untouched grains that originally did not contain twins
plot(newGrains_withoutTBs);
hold all;
% plot the twin boundaries in red
plot(tB,'linecolor','r','linewidth',1,'displayName','TBs');
hold off;
%%


