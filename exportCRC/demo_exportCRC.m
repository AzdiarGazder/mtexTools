%% Demonstration description:
% This script demonstrates how to export a square grid ebsd map in 
% Oxford Instruments HKL Channel-5 *.cpr and *.crc format.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%%


% clear variables
clc; clear all; clear hidden; close all;

% start Mtex
startup_mtex;

%% Load an ebsd map in square grid format
mtexdata twins


% % In case of maps with hexagonal grids, prior conversion to a square 
% % grid is required before invoking this function. 
% % For a detailed demonstration, please refer to:
% % https://github.com/AzdiarGazder/mtexTools/tree/main/hex2Square


%% Export map to OI Channel-5 *.cpr and *.crc file format
pfName = [pwd,'\newTwins.crc'];
exportCRC(ebsd,pfName)
%%
