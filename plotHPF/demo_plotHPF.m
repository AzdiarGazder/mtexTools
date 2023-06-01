close all; clc; clear all; clear hidden;

%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('FontSize',14);
set(0,'DefaultFigureWindowStyle','normal');

%% UN-REMARK EACH SECTION AND RUN SEPARATELY
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
% % %-----------------



%% DO NOT EDIT/MODIFY BELOW THIS LINE
setInterp2Latex

% Calculate the optimal kernel size
psi = calcKernel(ebsd.orientations,'method','ruleOfThumb');

% Calculate the orientation distribution function
odf = calcDensity(ebsd.orientations,'de la Vallee Poussin','kernel',psi);

% Plot the pole figures
hpf = {Miller(1,1,0,odf.CS),Miller(2,0,0,odf.CS), Miller(2,1,1,odf.CS)};
plotHPF(odf,'poleFigures',hpf,specimenSymmetry('triclinic'),'stepSize',1,'colormap',flipud(hot));

setInterp2Tex
%%