% clear variables
clc; clear all; clear hidden; close all;

% start Mtex
startup_mtex;

% define Mtex plotting convention as X = right, Y = up
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('FontSize', 14);

%% Load an ebsd map
% % In this example, a *.ctf map with multiple phases is used
ebsd = loadEBSD_ctf([pwd, '\CR42_800C.ctf'],'interface','ctf','convertSpatial2EulerReferenceFrame');
ebsd = ebsd('indexed');

% %% Assign the phases to different variables
ebsd_fcc = ebsd('fcc');
ebsd_bcc = ebsd('bcc');
ebsd_hcp = ebsd('hcp');


%% Calculate the bcc grains
% identify grains
[grains_bcc,ebsd_bcc.grainId,ebsd_bcc.mis2mean] = calcGrains(ebsd_bcc,'angle',2.*degree,'unitcell');
% remove small clusters
ebsd_bcc(grains_bcc(grains_bcc.grainSize <= 5)) = [];
% re-identify grains
[grains_bcc,ebsd_bcc.grainId,ebsd_bcc.mis2mean] = calcGrains(ebsd_bcc,'angle',2.*degree,'unitcell');


%% Calculate the hcp grains
% identify grains
[grains_hcp,ebsd_hcp.grainId,ebsd_hcp.mis2mean] = calcGrains(ebsd_hcp,'angle',2.*degree,'unitcell');
% remove small clusters
ebsd_hcp(grains_hcp(grains_hcp.grainSize <= 5)) = [];
% re-identify grains
[grains_hcp,ebsd_hcp.grainId,ebsd_hcp.mis2mean] = calcGrains(ebsd_hcp,'angle',2.*degree,'unitcell');


%% Calculate the bcc grain fractions
grains_bcc = gBFraction(grains_bcc,'threshold',[5 10 15 30 60].*degree)

%% Calculate the hcp grain fractions
grains_hcp = gBFraction(grains_hcp,'threshold',[15 30 45 60 90 120].*degree)
