close all; clc; clear all; clear hidden;

%% Initialize MTEX
% Startup and set some settings
startup_mtex;

cs_fcc = crystalSymmetry('m-3m', [3.6599 3.6599 3.6599], 'mineral', 'fcc');
cs_bcc = crystalSymmetry('m-3m', [2.866 2.866 2.866], 'mineral', 'bcc');
cs_hcp = crystalSymmetry('6/mmm', [2.545 2.545 4.14], 'X||a', 'Y||b*', 'Z||c', 'mineral', 'hcp');

% Define a Miller index
m = Miller(1, 1, 1, cs_fcc);

% Calculate the interplanar spacing
d = calcSpacing(m)

% MTEX equivalent
d = 1./norm(m)
