clc; clear all; clear hidden

plotx2east
plotzIntoPlane

% *.crc file with EDS information
fname = 'MEA_ZrB2_60CR_1.cpr';
ebsd = loadEBSD_crc(fname,'interface','crc','convertSpatial2EulerReferenceFrame')

% Automatically load all *.csv files containing Trumap or Quantmap 
% elemental information
ebsd = loadEDS_csv(ebsd);
