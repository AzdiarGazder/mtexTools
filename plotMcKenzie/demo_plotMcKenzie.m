close all; clc; clear all; clear hidden;

%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('FontSize',14);
set(0,'DefaultFigureWindowStyle','normal');

% Define the crystal system(s)
CS1 = crystalSymmetry('m-3m', [2.9 2.9 2.9], 'mineral', 'bcc');
CS2 = crystalSymmetry('6/mmm', [2.5 2.5 4.1], 'X||a*', 'Y||b', 'Z||c*', 'mineral', 'hcp');
CS3 = crystalSymmetry('4/mmm', [8.8 8.8 4.5], 'mineral', 'tet');

% Return the McKenzie distribution of the bcc CS
% h = plotMcKenzie(1E5,CS1)
% h = plotMcKenzie(1E5,CS1,CS1)

% Return the McKenzie distribution of the bcc and hcp CS
h = plotMcKenzie(1E5,CS1,CS2)




