close all; clc; clear all; clear hidden;

%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('FontSize',14);
set(0,'DefaultFigureWindowStyle','normal');


% %-----------------
% hexGrid
% setMTEXpref('xAxisDirection','east');
% setMTEXpref('zAxisDirection','outofPlane');
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','intoPlane');
% define the crystal system
CS = {'notIndexed',...
    crystalSymmetry('m-3m', [2.9 2.9 2.9], 'mineral', 'Ferrite')};
% load an mtex dataset
mtexdata ferrite
ebsd.CSList = CS;

split(ebsd,'matrix',[1 6],'overlap',[0.35 0.25]);
figure; plot(ebsd,ebsd.iq)

figure; plot(ebsd11,ebsd11.iq)
figure; plot(ebsd12,ebsd12.iq)
figure; plot(ebsd13,ebsd13.iq)
figure; plot(ebsd14,ebsd14.iq)
figure; plot(ebsd15,ebsd15.iq)
figure; plot(ebsd16,ebsd16.iq)

% figure; plot(ebsd11,ebsd11.iq)
% figure; plot(ebsd21,ebsd21.iq)
% figure; plot(ebsd31,ebsd31.iq)
% figure; plot(ebsd41,ebsd41.iq)
% figure; plot(ebsd51,ebsd51.iq)
% figure; plot(ebsd61,ebsd61.iq)
% %-----------------


% % %-----------------
% % squareGrid
% % setMTEXpref('xAxisDirection','north');
% % setMTEXpref('zAxisDirection','outofPlane');
% % define the crystal system
% CS = {'notIndexed',...
%     crystalSymmetry('6/mmm', [1.5708 1.5708 2.0944], 'X||a*', 'Y||b', 'Z||c*', 'mineral', 'Mg')};
% % load an mtex dataset
% mtexdata twins
% ebsd.CSList = CS;
% 
% split(ebsd,'matrix',[1 4],'overlap',[0.5 0.5]);
% figure; plot(ebsd,ebsd.bc)
% 
% figure; plot(ebsd11,ebsd11.bc)
% figure; plot(ebsd12,ebsd12.bc)
% figure; plot(ebsd13,ebsd13.bc)
% figure; plot(ebsd14,ebsd14.bc)
% 
% % figure; plot(ebsd11,ebsd11.bc)
% % figure; plot(ebsd21,ebsd21.bc)
% % figure; plot(ebsd31,ebsd31.bc)
% % figure; plot(ebsd41,ebsd41.bc)
% % %-----------------


