close all; clc; clear all; clear hidden;

%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('FontSize',14);
set(0,'DefaultFigureWindowStyle','normal');


% %-----------------
setMTEXpref('xAxisDirection','north');
setMTEXpref('zAxisDirection','outofPlane');
% define the crystal system
CS = {'notIndexed',...
    crystalSymmetry('6/mmm', [1.5708 1.5708 2.0944], 'X||a*', 'Y||b', 'Z||c*', 'mineral', 'Mg')};
% load an mtex dataset
mtexdata twins
ebsd.CSList = CS;
% %-----------------


figure
plot(ebsd,ebsd.bc)

figure
plot(ebsd,ebsd.orientations)

saveImage
