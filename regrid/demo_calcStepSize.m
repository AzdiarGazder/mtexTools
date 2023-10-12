close all; clc; clear all; clear hidden;
startup_mtex

%% UN-REMARK EACH SECTION BELOW AND RUN SEPARATELY
% %-----------------
% % hexGrid
% % define the crystal system
% CS = {'notIndexed',...
%     crystalSymmetry('m-3m', [3.6 3.6 3.6], 'mineral', 'copper')};
% % load an mtex dataset
% mtexdata copper
% ebsd.CSList = CS;
% % consider only indexed data
% ebsd = ebsd('indexed');
% ebsd = ebsd('copper');
% % calculate the step size
% stepSize = calcStepSize(ebsd)
% % re-grid the ebsd map data based on the calculated step size
% ebsd = regrid(ebsd,stepSize)
% %-----------------



%-----------------
% squareGrid
% define the crystal system
CS = {'notIndexed',...
    crystalSymmetry('6/mmm', [1.5708 1.5708 2.0944], 'X||a*', 'Y||b', 'Z||c*', 'mineral', 'Mg')};
% load an mtex dataset
mtexdata twins
ebsd.CSList = CS;
% consider only indexed data
ebsd = ebsd('indexed');
ebsd = ebsd('Mg');
% calculate the step size
stepSize = calcStepSize(ebsd)
% re-grid the ebsd map data based on the calculated step size
ebsd = regrid(ebsd,stepSize)
%-----------------
%%