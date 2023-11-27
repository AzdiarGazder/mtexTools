%% Demonstration description:
% This script demonstrates how to export a square grid ebsd map in 
% Oxford Instruments HKL Channel-5 *.cpr and *.crc format.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%%


%% USER NOTES:
% % In case of maps with hexagonal grids, prior conversion to a square 
% % grid is required before invoking this function. 
% % For a detailed demonstration, please refer to:
% % https://github.com/AzdiarGazder/mtexTools/tree/main/hex2Square
%%


% clear variables
clc; clear all; clear hidden; close all;

% start Mtex
startup_mtex;


%% Load an ebsd map in square grid format
% % Load a default MTEX map
% mtexdata twins

% % Load a *.cpr & *.crc map
% ebsd = EBSD.load([pwd, '\CR42_800C.cpr'],'interface','crc',...
%     'convertSpatial2EulerReferenceFrame');

% % Load a *.ctf map
ebsd = EBSD.load('CR42_800C.ctf','interface','ctf',...
    'convertSpatial2EulerReferenceFrame');
%%



%% Export map to OI Channel-5 *.cpr and *.crc file format
% pfName = [pwd,'\newTwins.crc'];
% pfName = [pwd,'\newCR42_800C_cprcrc.crc'];
pfName = [pwd,'\newCR42_800C_ctf.crc'];

% exportCRC(ebsd,pfName);
exportCRC(ebsd,pfName,'convertEuler2SpatialReferenceFrame');
% exportCRC(ebsd,pfName,'convertSpatial2EulerReferenceFrame');
%%
