%% Initialise Mtex
close all; clc; clear all; clear hidden;
startup_mtex

%% Define the Mtex plotting convention
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outofPlane');
setMTEXpref('maxSO3Bandwidth',92);

%% Load an mtex dataset
mtexdata ferrite
CS = ebsd.CS;

%% Calculate the ODF from ebsd data
% compute an optimal kernel
psi = calcKernel(ebsd(ebsd.CS).orientations);
% compute the ODF with the kernel psi
odf = calcDensity(ebsd(ebsd.CS).orientations,'kernel',psi);
disp('Done!');

%% Calculate the discrete ODF intensity from ebsd data
% make a regular grid using 5*degree step size
% MTEX BUG: not returning the correct ori size
% ori = regularSO3Grid(odf.CS,odf.SS,'resolution',5*degree,'Bunge');

x = linspace(0,90*degree,19);
y = linspace(0,360*degree,73);
z = linspace(0,90*degree,19);
% create a meshgrid
[phi1,Phi,phi2] = meshgrid(x, y, z);
ori = orientation.byEuler(phi1,Phi,phi2,odf.CS,odf.SS);

% return the ODF intensity at the gridded points
odf.opt.intensity = odf.eval(ori);
% make negative f(g) values == 0
odf.opt.intensity(odf.opt.intensity<0) = 0;
disp('Done!');

%% Calculate the volume fraction (v) to use as the weight (wt) by
% discretising the ODF 
wt = calcODFVolumeFraction(odf);