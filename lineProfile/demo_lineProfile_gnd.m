%% Demonstration description:
% This script demonstrates how to use lineProfile with data from calcGND.
% From https://mtex-toolbox.github.io/GND.html
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%%


% clear variables
clc; clear all; clear hidden; close all;

% start Mtex
startup_mtex;

% setup the plotting convention
plotx2north

% import the EBSD data
ebsd = EBSD.load([mtexDataPath filesep 'EBSD' filesep 'DC06_2uniax.ang'],'convertSpatial2EulerReferenceFrame','setting 2') 

% reconstruct grains
[grains,ebsd.grainId] = calcGrains(ebsd,'angle',5*degree);
% remove small grains
ebsd(grains(grains.grainSize<=5)) = [];
% re-do grain reconstruction
[grains,ebsd.grainId] = calcGrains(ebsd,'angle',2.5*degree);
% smooth grain boundaries
grains = smooth(grains,5);

% denoise orientation data
F = halfQuadraticFilter;
ebsd = smooth(ebsd('indexed'),F,'fill',grains);

% consider only the Fe(alpha) phase
ebsd = ebsd('indexed').gridify;

% compute the curvature tensor
kappa = ebsd.curvature;

% define the dislocation density tensor
alpha = kappa.dislocationDensity;

% define the dislocation system
dS = dislocationSystem.bcc(ebsd.CS);

% rotate the dislocation tensors into the specimen reference frame
dSRot = ebsd.orientations * dS;

% fit dislocations to the incomplete dislocation density tensor
[rho,factor] = fitDislocationSystems(kappa,dSRot);

% calculate the total dislocation energy
gnd = factor*sum(abs(rho .* dSRot.u),2);

% use the lineProfile tool
lineProfile(ebsd,gnd,'color',[0 0 0],'linestyle','-');

