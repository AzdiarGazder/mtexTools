% clear variables
clc; clear all; clear hidden; close all;

% start Mtex
startup_mtex;

%% Load a hexagonal grid ebsd map in TSL OIM's *.ang format
mtexdata copper
[grains, ebsd.grainId] = calcGrains(ebsd);


%% Converting ebsd map data from a hexagonal grid to a square grid
% This creates a map with NaNs in it
unitCell = [-1 -1;...
    -1  1;...
     1  1;...
     1 -1];
% Apply the small square unit cell with the gridify command
gebsd = ebsd.gridify('unitCell',unitCell);
% Interpolate using a TV regularisation term
F = halfQuadraticFilter;
F.alpha = 0.5;
gebsd = smooth(gebsd,F,'fill',grains);
% Convert gridified ebsd data back to conventional ebsd data
ebsd = EBSD(gebsd);
%%


%% Calculate second neighbour KAM and plot a line profile
% Method 1
kam = KAM(ebsd,'order',2);
lineProfile(ebsd, kam,'color',[0 0 0],'linestyle','-');

% Method 2
ebsd.prop.kam = kam;
lineProfile(ebsd,ebsd.kam,'color',[0 0 0],'linestyle','--');







