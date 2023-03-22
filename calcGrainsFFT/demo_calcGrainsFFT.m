close all; clc; clear all; clear hidden;
startup_mtex

%% UN-REMARK EACH SECTION BELOW AND RUN SEPARATELY
%-----------------
% hexGrid
% define the crystal system
CS = {'notIndexed',...
    crystalSymmetry('m-3m', [3.6 3.6 3.6], 'mineral', 'copper')};
% load an mtex dataset
mtexdata copper
ebsd.CSList = CS;
% consider only indexed data
ebsd = ebsd('indexed');
ebsd = ebsd('copper');
[grains,ebsd.grainId] = calcGrains(ebsd,'angle',2*degree);
% remove EBSD data of grains < 5 pixels
ebsd(grains(grains.grainSize < 5)) = [];
% re-calculate the grains from the remaining data
[grains,ebsd.grainId] = calcGrains(ebsd,'angle',2*degree);
% smooth the grain boundaries
grains = smooth(grains,5);
% select a grain of interest
grainId = 176;
%-----------------



% %-----------------
% % squareGrid
% % define the crystal system
% CS = {'notIndexed',...
%     crystalSymmetry('6/mmm', [1.5708 1.5708 2.0944], 'X||a*', 'Y||b', 'Z||c*', 'mineral', 'Mg')};
% % load an mtex dataset
% mtexdata twins
% ebsd.CSList = CS;
% % consider only indexed data
% ebsd = ebsd('indexed');
% ebsd = ebsd('Mg');
% % calculate grains
% [grains,ebsd.grainId] = calcGrains(ebsd,'angle',2*degree);
% % remove EBSD data of grains < 5 pixels
% ebsd(grains(grains.grainSize < 5)) = [];
% % re-calculate the grains from the remaining data
% [grains,ebsd.grainId] = calcGrains(ebsd,'angle',2*degree);
% % smooth the grain boundaries
% grains = smooth(grains,5);
% % select a grain of interest
% grainId = 53;
% %-----------------
%%


%% PLEASE DO NOT MODIFY BELOW THIS LINE 
%-----------------
% compute the ffts of individual grains
grains = calcGrainsFFT(ebsd,grains);
% grains = calcFFT(ebsd,grains,'noPad');


figure; % plot the grain map
plot(grains,grains.meanOrientation)

figure; % plot the grain of interest
plot(grains(grainId),grains(grainId).meanOrientation)

figure; % show the fft
imagesc(grains.fftReal{grainId});
axis tight

% Applying a 2D Gaussian smoothing kernel to the FFT 
% Note: the standard deviation is used here
smooth_fftReal = imgaussfilt(grains.fftReal{grainId},...
    std(reshape(grains.fftReal{grainId},[size(grains.fftReal{grainId},1)*size(grains.fftReal{grainId},2),1])),...
    'FilterDomain','spatial');
figure; % show the smoothed fft
imagesc(smooth_fftReal);
axis tight
%-----------------