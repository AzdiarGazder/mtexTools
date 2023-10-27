%% Demonstration description:
% This script demonstrates how to automatically convert from a hexagonal
% grid ebsd map in TSL OIM's *.ang format to a square grid ebsd map in 
% Oxford Instruments HKL Channel-5 *.cpr and *.crc format.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%%


% clear variables
clc; clear all; clear hidden; close all;

% start Mtex
startup_mtex;

%% Load a hexagonal grid ebsd map in TSL OIM's *.ang format
mtexdata copper
[grains, ebsd.grainId] = calcGrains(ebsd);

% Plot the imported ebsd data
figure;
plot(ebsd,ebsd.orientations)
drawnow;


%% Converting ebsd map data from a hexagonal grid to a square grid
% From https://mtex-toolbox.github.io/EBSDGrid.html
%
% Define a small unit cell to minimise distortion while converting from
% hexagonal to square grids
% USER NOTE:
% When a square unit cell has approximately the same size as the
% hexgonal unit cell, it causes distortions as squares cannot reproduce
% all hexagonal shapes.
% This issue can be minimised by choosing a square unit cell that is
% significantly smaller then the hexagonal unit cell.
unitCell = [-1 -1;...
    -1  1;...
     1  1;...
     1 -1];

% Apply the small square unit cell with the gridify command
gebsd = ebsd.gridify('unitCell',unitCell);

% "gridify" does not increase the number of map data points when
% converting from hexagonal to square grid type.
% Therfore, many zero solutions with orientations set to NaN are
% introduced in the map.
% To fill these zero solutions, use either:
% - the "fill" command which performs nearest neighbour interpolation, or
% - the "smooth" command which uses more sophisticated interpolation
%   methods.

% % METHOD 1: Do nearest neigbour interpolation to fill-in holes containing NaNs
% gebsd = fill(gebsd,grains);

% METHOD 2: Interpolate using a TV regularisation term
F = halfQuadraticFilter;
F.alpha = 0.5;
gebsd = smooth(gebsd,F,'fill',grains);
%%

% Plot the converted ebsd data
figure;
plot(gebsd,gebsd.orientations);
drawnow;


%% Export map to OI Channel-5 *.cpr and *.crc file format
pfName = [pwd,'\copperSquare.crc'];
exportCRC(gebsd,pfName)
%%
