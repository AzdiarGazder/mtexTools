close all; clc; clear all; clear hidden;

%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('FontSize',14);
set(0,'DefaultFigureWindowStyle','normal');


% %-----------------
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

%% Import the Data
% current directory path & file name
pfname = [pwd '\Zircon_C.ctf'];
% create an EBSD variable containing the data
ebsd = EBSD.load(pfname,CS,'interface','ctf',...
    'convertEuler2SpatialReferenceFrame');
ebsd.CSList = CS;

% plot the phase map using the originally specified names
figure;
plot(ebsd)

% % rename phases using the interactive GUI
% ebsd = rename(ebsd); 

% % rename phases using a cell array
ebsd = rename(ebsd,{'Zrcn','Anoth','Ilm','','','','',''});
% grains = calcGrains(ebsd,'angle',10*degree);
% grains = rename(grains,{'Zrcn','Anoth','Ilm','','','','',''});


% % rename phases using phase names
% ebsd = rename(ebsd,'zircon','ZRCN','anorthite','ANORTH');

% % rename phases using crystal symmetries
% ebsd = rename(ebsd,CS{2},'ZiRcOn',CS{3},'AnOrT');
% ebsd = rename(ebsd,ebsd.CSList{2},'ZiRcOn',CS{3},'AnOrT');


% % rename phases using phase names & crystal symmetries
% ebsd = rename(ebsd,CS{2},'ZiRcOn','Anorthite','AnOrT');

% plot the phase map using the newly specified names
figure;
plot(ebsd)
