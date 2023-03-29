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
% % select one or multiple grain(s) of interest
% % grainId = 176; % CASE 1: for one grain
% % grainId = [139, 71, 98]; % CASE 2: for multiple contiguous grains
% grainId = [168, 208, 24]; % CASE 3: for multiple discrete grains
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
% select one or multiple grain(s) of interest
% grainId = 51; % CASE 1: for one grain
% grainId = [53, 44, 40]; % CASE 2: for multiple contiguous grains
grainId = [53, 20, 28]; % CASE 3: for multiple discrete grains
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
    
% % FOR CASE 1 and CASE 2: for one grain or multiple contiguous grains
% % dilate the grain(s) of interest as a group
% ebsd1 = dilate(ebsd,grains(grainId(1))); 
% figure; % plot the grain(s) of interest
% plot(ebsd1,ebsd1.orientations);

% FOR CASE 3: for multiple discrete grains
% dilate the grain(s) of interest individually
ebsd1 = dilate(ebsd,grains(grainId(1))); 
ebsd2 = dilate(ebsd,grains(grainId(2)));
ebsd3 = dilate(ebsd,grains(grainId(3)));
ebsd123 = [ebsd1 ebsd2 ebsd3]; % group them together
figure; % plot the grain(s) of interest
plot(ebsd123,ebsd123.orientations);
%-----------------

