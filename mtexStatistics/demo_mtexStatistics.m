%% Demonstration description:
% This script modifies the MTEX distribution to return the mean, median 
% and mode values for all classes and object types.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  demo_calcGrains
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


%% Initialise Mtex
clc; clear all; clear hidden; close all;
startup_mtex; runOnce


%% define Mtex plotting convention as X = right, Y = up
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('FontSize', 24);

%% load mtex example data
mtexdata ferrite


%% Calculate the grains
% identify grains
[grains,ebsd.grainId,ebsd.mis2mean,ebsd.mis2median,ebsd.mis2mode] = calcGrains(ebsd('indexed'),'angle',5*degree,'unitcell');
% remove small clusters
ebsd(grains(grains.grainSize <= 5)) = [];
[grains,ebsd.grainId,ebsd.mis2mean,ebsd.mis2median,ebsd.mis2mode] = calcGrains(ebsd('indexed'),'angle',5*degree,'unitcell');
% smooth the grains
grains = grains.smooth(5);
% store the crystal symmetry of magnesium for later use
CS = grains.CS;
% plot the grains
figure;
plot(grains,grains.meanOrientation)

figure;
plot(grains,grains.medianOrientation)

figure;
plot(grains,grains.modeOrientation)

%%