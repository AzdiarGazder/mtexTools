clc; clear all; clear hidden; close all

% This demonstration describes how to define twins in MTEX using 
% α-titanium as an example.


% In Table 3.3 of Reference (1): 
% M. Battaini, Deformation behaviour and twinning mechanisms of 
% commercially pure titanium alloys, PhD Thesis, Monash University,
% Australia, 2008

% The axis-angle representation for the common twin modes in α-titanium 
% with a = 0.2950 nm and c = 0.4683 nm is stated as:
CS = crystalSymmetry('6/mmm', [0.295 0.295 0.4683], 'X||a', 'Y||b*', 'Z||c*');

angleList = [84.98; 34.99; 64.45; 57.26].*degree;
axisList = [-1 2 -1 0;...
    1 -1 0 0;...
    1 -1 0 0;
    -1 2 -1 0];

% Defining twins as misorientations using their angle-axis representations
mori = orientation.byAxisAngle(Miller(axisList(:,1),axisList(:,2),axisList(:,3),axisList(:,4),CS),...
    angleList,...
    CS,CS);

% Labelling the twin types
% E = extension twin; C = compression twin
mori.opt.types = {'E'; 'C'; 'E'; 'C'};

% The twin shear, s, is calculated using formulas in Table 3 of 
% Reference (2):
% JW Christian & S Mahajan, Deformation twinning, Progress in Materials 
% Science, vol. 39, pp. 1-157, 1995
caRatio = CS.axes.z(3)/CS.axes.x(1);
% For {1 0 1 -2} twins
mori.opt.s(1) = abs((caRatio^2 - 3) / (sqrt(3) * caRatio));
% For {1 1 -2 1} twins
mori.opt.s(2) = abs(caRatio^-1);
% For {1 1 -2 2} twins
mori.opt.s(3) = abs(2 * (caRatio^2 - 2)/(3 * caRatio));
% For {1 0 -1 1} twins
mori.opt.s(4) = abs(((4 * caRatio^2) - 9) / (4 * sqrt(3) * caRatio));

% Calculate the K1, K2, eta1 and eta2 values based on the defined twins
mori = angleAxis2Miller(mori)