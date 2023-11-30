clc; clear all; clear hidden; close all

% This demonstration describes how to define twins in MTEX using 
% α-titanium as an example.


% In Table 1 of Reference (1): 
% M. Ruffino, J. Nutter, X. Zeng, D. Guan, W.M. Rainforth, A.T. Paxton, 
% Triple and double twin interfaces in magnesium — The role of 
% disconnections and facets, Scientific Reports, 13:3861, 2023, 
% https://doi.org/10.1038/s41598-023-30880-w

% The axis-angle representation for the common twin modes in magnesium 
% with c = 0.52 nm and a = 0.32 nm is stated as:
CS = crystalSymmetry('6/mmm', [0.32 0.32 0.52], 'X||a*', 'Y||b', 'Z||c');

angleList = [86; 56; 38; 30; 38; 30; 48; 56; 56; 64].*degree;
axisList = [1 -2 1 0;...
    1 -2 1 0;...
    1 -2 1 0;...
    1 -2 1 0;...
    1 -2 1 0;...
    1 -2 1 0;...
    1 -2 1 0;...
    1 -2 1 0;...
    1 -2 1 0;...
    1 -2 1 0];

% Defining twins as misorientations using their angle-axis representations
mori = orientation.byAxisAngle(Miller(axisList(:,1),axisList(:,2),axisList(:,3),axisList(:,4),CS),...
    angleList,...
    CS,CS);

% Labelling the twin types
% E = extension twin; C = compression twin
mori.opt.types = {'E'; 'C'; 'CE1'; 'CE2'; 'EC1'; 'EC2'; 'ECE1a'; 'ECE1b'; 'ECE2a'; 'ECE2b'};

% Calculate the K1, K2, eta1 and eta2 values based on the defined twins
mori = angleAxis2Miller(mori)