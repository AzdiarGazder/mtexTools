close all; clc; clear all; clear hidden;
startup_mtex

% ***** NOTE TO USER *****
% Function use is currently restricted to single phase, square grid maps 
% only.
% *****

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
% 
% figure; 
% lineProfile(ebsd,ebsd.orientations,'color',[0 0 0],'linestyle','-');
% % -----------------



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
[grains,ebsd.grainId] = calcGrains(ebsd,'angle',2*degree);

lineProfile(ebsd,ebsd.orientations,'color',[0 0 0],'linestyle','-');
% lineProfile(ebsd,ebsd.bc,'color',[0 0 0],'linestyle','--');
% lineProfile(ebsd,ebsd.bands,'color',[0 0 0],'linestyle',':');
%-----------------
