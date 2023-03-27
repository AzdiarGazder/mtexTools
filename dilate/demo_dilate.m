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
% [grains,ebsd.grainId] = calcGrains(ebsd,'angle',2*degree);
% % remove EBSD data of grains < 5 pixels
% ebsd(grains(grains.grainSize < 5)) = [];
% % re-calculate the grains from the remaining data
% [grains,ebsd.grainId] = calcGrains(ebsd,'angle',2*degree);
% % smooth the grain boundaries
% grains = smooth(grains,5);
% % select a grain of interest
% grainId = 176;
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
% calculate grains
[grains,ebsd.grainId] = calcGrains(ebsd,'angle',2*degree);
% remove EBSD data of grains < 5 pixels
ebsd(grains(grains.grainSize < 5)) = [];
% re-calculate the grains from the remaining data
[grains,ebsd.grainId] = calcGrains(ebsd,'angle',2*degree);
% smooth the grain boundaries
grains = smooth(grains,5);
% select a grain of interest
grainId = 53;
%-----------------
%%


%% PLEASE DO NOT MODIFY BELOW THIS LINE 
%-----------------
figure; % plot the ebsd map
plot(ebsd,ebsd.orientations)

figure; % plot the grain map
plot(grains,grains.meanOrientation)

figure; % plot the ebsd data of the grain of interest
plot(ebsd(grains(grainId)),ebsd(grains(grainId)).orientations)

% dilate the grain of interest
ebsd1 = dilate(ebsd,grains(grainId));

figure; % plot the grain of interest
plot(ebsd1,ebsd1.orientations)
%-----------------



