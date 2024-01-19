close all; clc; clear all; clear hidden;

%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('FontSize',14);
set(0,'DefaultFigureWindowStyle','normal');


% % %-----------------
% % hexGrid
% setMTEXpref('xAxisDirection','east');
% setMTEXpref('zAxisDirection','outofPlane');
% % define the crystal system
% CS = {'notIndexed',...
%     crystalSymmetry('m-3m', [2.9 2.9 2.9], 'mineral', 'Ferrite')};
% % load an mtex dataset
% mtexdata ferrite
% ebsd.CSList = CS;
% [grains,ebsd.grainId] = calcGrains(ebsd,'angle',10*degree);
% % %-----------------


% %-----------------
% squareGrid
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','intoPlane');
% define the crystal system
CS = {...
    'notIndexed',...
    crystalSymmetry('SpaceId',141, [6.58 6.58 5.93], [90 90 90]*degree, 'mineral', 'Zircon', 'color', [1 0 0]),...
    crystalSymmetry('SpaceId',2, [8.1732 12.8583 14.1703], [93.172 115.952 91.222]*degree, 'mineral', 'Anorthite', 'color', [0 1 0]),...
    crystalSymmetry('SpaceId',148, [5.05614 5.05614 13.91152], [90 90 120]*degree, 'mineral', 'Ilmenite', 'color', [0 0 1]),...
    crystalSymmetry('SpaceId',176, [9.45549 9.45549 6.88357], [90 90 120]*degree, 'mineral', 'Apatite', 'color', [1 1 0]),...
    crystalSymmetry('SpaceId',12, [9.8701 18.0584 5.3072], [90 105.2002 90]*degree, 'mineral', 'Hornblende', 'color', [0 1 1]),...
    crystalSymmetry('SpaceId',15, [9.7381 8.8822 5.2821], [90 106.231 90]*degree, 'mineral', 'Augite', 'color', [1 0 1]),...
    crystalSymmetry('SpaceId',227, [8.39503 8.39503 8.39503], [90 90 90]*degree, 'mineral', 'Magnetite', 'color', [1 1 1]),...
    crystalSymmetry('SpaceId',0, [4.99 4.99 17.064], [90 90 120]*degree, 'mineral', 'Calcite', 'color', [0 0 0])};

% directory path
pname = 'C:\Users\azdiar\Documents\MATLAB\GitHub\mtexTools\GAM\';
% file name
fname = 'Zircon_C.ctf';
pfname = [pname fname];
% create an EBSD variable containing the data
ebsd = EBSD.load(pfname,CS,'interface','ctf',...
    'convertEuler2SpatialReferenceFrame');
ebsd.CSList = CS;
[grains,ebsd.grainId] = calcGrains(ebsd,'angle',10*degree);
% %-----------------


gam = GAM(ebsd,'threshold',10*degree);
figure
plot(ebsd,gam./degree)
hold all
plot(grains.boundary)

return