close all; clc; clear all; clear hidden;

%% Initialize MTEX
% Startup and set some settings
startup_mtex;

% output a single set of random Euler angles
o = randomEuler()
disp('---')

o = randomEuler('orientation')
disp('---')

% output a single set of random quaternions
o = randomEuler('quaternion')
disp('---')

% output a single rotation matrix
o = randomEuler('rotationMatrix')
disp('---')

% output 10 uniformly distributed random Euler angles
o = randomEuler(10)
disp('---')

% output 10 uniformly distributed random Euler angles around a seed
% orientation
ori = orientation.byEuler([45, 45, 45].*degree, crystalSymmetry('m-3m'));
o = randomEuler(10,'orientation',ori)
disp('---')


% output 10 uniformly distributed random Euler angles around a seed
% quaternion
q = quaternion(sqrt(2)/2, 0, sqrt(2)/2, 0);
o = randomEuler(10,'quaternion',q)
disp('---')


% output 10 uniformly distributed random Euler angles around a seed
% rotation matrix
rotMat = [sqrt(2)/2, 0, sqrt(2)/2;...
    sqrt(2)/2, 0, sqrt(2)/2;...
    sqrt(2)/2, 0, sqrt(2)/2];
o = randomEuler(10,'rotationMatrix',rotMat)
disp('---')
