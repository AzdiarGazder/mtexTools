close all; clc; clear all; clear hidden;
startup_mtex


% %-----------------
% % hexGrid
% setMTEXpref('xAxisDirection','east');
% setMTEXpref('zAxisDirection','outofPlane');
% % crystal symmetry
% CS = {...
%     'notIndexed',...
%     crystalSymmetry('mmm', [4.762 10.225 5.994], 'mineral', 'olivine', 'color', [0 0 1]),...
%     crystalSymmetry('mmm', [18.241 8.830 5.185], 'mineral', 'Enstatite', 'color', [1 0 0])};
% % load datasets
% ebsdL = EBSD.load('ebsdL.ang',CS,'interface','ang',...
%   'convertEuler2SpatialReferenceFrame','setting 2');
% ebsdR = EBSD.load('ebsdR.ang',CS,'interface','ang',...
%   'convertEuler2SpatialReferenceFrame','setting 2');
% 
% figure;
% plot(ebsdL,ebsdL.iq);
% 
% figure;
% plot(ebsdR,ebsdR.iq);
% 
% ebsd = stitch(ebsdL,ebsdR,'east',[11,13]);
% figure;
% plot(ebsd,ebsd.iq)
% 
% %-----------------
% return
% [grains,ebsd.grainId,~] = calcGrains(ebsd,'angle',15*degree,'unitCell');
% gB = grains.boundary;
% figure;
% plot(ebsd('olivine'),ebsd('olivine').orientations);
% hold all;
% plot(gB('olivine'),'LineWidth',0.5);



%-----------------
% squareGrid
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','intoPlane');
% crystal symmetry
CS = {...
    'notIndexed',...
    crystalSymmetry('m-3m', [3.7 3.7 3.7], 'mineral', 'Iron fcc', 'color', [0 0 1]),...
    crystalSymmetry('m-3m', [2.9 2.9 2.9], 'mineral', 'Iron bcc (old)', 'color', [1 0 0])};
% load datasets
ebsdL = EBSD.load('DuplexL.ctf',CS,'interface','ctf',...
    'convertEuler2SpatialReferenceFrame');
ebsdR = EBSD.load('DuplexR.ctf',CS,'interface','ctf',...
    'convertEuler2SpatialReferenceFrame');

figure;
plot(ebsdL,ebsdL.bc);

figure;
plot(ebsdR,ebsdR.bc);

ebsd = stitch(ebsdL,ebsdR,'east',[99,0]);
figure;
plot(ebsd,ebsd.bc);

%-----------------
return
[grains,ebsd.grainId,~] = calcGrains(ebsd,'angle',15*degree,'unitCell');
gB = grains.boundary;
figure;
plot(ebsd('Iron bcc (old)'),ebsd('Iron bcc (old)').orientations);
hold all;
plot(gB('Iron bcc (old)'),'LineWidth',0.5);



%-----------------
return
gebsd1 = gridify(ebsd);
currentFolder = pwd;
pfName = [currentFolder,'\stitchedMap.ctf']
export_ctf(gebsd1,pfName)
