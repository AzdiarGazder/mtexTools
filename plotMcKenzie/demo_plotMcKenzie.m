close all; clc; clear all; clear hidden;

%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('FontSize',14);
set(0,'DefaultFigureWindowStyle','normal');

% Define the crystal system
CS = crystalSymmetry('m-3m', [2.9 2.9 2.9], 'mineral', 'bcc');

% Return the McKenzie distribution
h = plotMcKenzie(1E5,CS)