close all; clc; clear all; clear hidden;
startup_mtex

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
% % ebsd1 = crop(ebsd,'rectangle','color',[1 0 0],'linestyle','--');
% % ebsd1 = crop(ebsd,'circle','color',[0 1 0],'linestyle','-.');
% ebsd1 = crop(ebsd,ebsd.imagequality,'polygon',3,'color',[0 0 1],'linestyle',':');
% 
% figure;
% if ~exist('ebsd1.prop.iq','var') || isempty(ebsd1.prop.iq)
%     plot(ebsd1,ebsd1.imagequality)
% else
%     plot(ebsd1,ebsd1.iq)
% end


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


% ebsd1 = crop(ebsd,'rectangle','color',[1 0 0],'linestyle',':');
% ebsd1 = crop(ebsd,'circle','color',[0 1 0],'linestyle','-.');
ebsd1 = crop(ebsd,ebsd.bands,'polygon',3,'color',[0 0 1],'linestyle','-');
% ebsd1 = crop(ebsd,'area','color',[0 1 0],'linestyle','-.');

figure; 
plot(ebsd1,ebsd1.orientations)


%-----------------
return
gebsd1 = gridify(ebsd1);
currentFolder = pwd;
pfName = [currentFolder,'\croppedMap.ctf']
export_ctf(gebsd1,pfName)
