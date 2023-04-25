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
% % %-----------------


% %-----------------
% squareGrid
setMTEXpref('xAxisDirection','north');
setMTEXpref('zAxisDirection','outofPlane');
% define the crystal system
CS = {'notIndexed',...
    crystalSymmetry('6/mmm', [1.5708 1.5708 2.0944], 'X||a*', 'Y||b', 'Z||c*', 'mineral', 'Mg')};
% load an mtex dataset
mtexdata twins
ebsd.CSList = CS;
% %-----------------



%% DO NOT EDIT/MODIFY BELOW THIS LINE
% compute an optimal kernel
psi = calcKernel(ebsd(CS{2}).orientations);

% compute the ODF with the kernel psi
odf = calcDensity(ebsd(CS{2}).orientations,'kernel',psi);

% compute the ODF intensity
% odf = calcODFIntensity(odf);
odf = calcODFIntensity(odf,'phi2',(0:5:90)*degree);