% clear variables
clc; clear all; clear hidden; close all;

% start Mtex
startup_mtex;

% define Mtex plotting convention as X = right, Y = up
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('FontSize', 14);

% Import the dataset
ebsd = EBSD.load('Duplex.ctf','interface','ctf',...
    'convertEuler2SpatialReferenceFrame');
ebsd = ebsd('indexed');

%% calculate the grains
% identify grains
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',5*degree);
% remove small clusters
ebsd(grains(grains.grainSize <= 5)) = [];
% re-calculate grains
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',5*degree);
% denoise orientation data
F = halfQuadraticFilter;
ebsd = smooth(ebsd,F,'fill',grains);
% calculate the grain boundaries
gB = grains.boundary;


% define the fcc phase variables
ebsd_fcc = ebsd('Fe-FCC');
grains_fcc = grains('Fe-FCC');

% grid the ebsd data
ebsd_fcc = ebsd_fcc.gridify;

% compute the curvature tensor
kappa_fcc = ebsd_fcc.curvature;

% define the dislocation system
dS_fcc = dislocationSystem.fcc(ebsd_fcc.CS);
% define the energy of the edge dislocations as per Hull & Bacon assumption
dS_fcc(dS_fcc.isEdge).u = 1;
% define the energy of the screw dislocations as per Hull & Bacon assumption
dS_fcc(dS_fcc.isScrew).u = 1 - 0.3;
% rotate the dislocation tensors into the specimen reference frame
dSRot_fcc = ebsd_fcc.orientations * dS_fcc;

% fit dislocations to the incomplete dislocation density tensor
[rho_fcc,~] = fitDislocationSystems(kappa_fcc,dSRot_fcc);

% plot the data
factor = 1E16;
gnd_fcc = factor * sum(abs(rho_fcc .* dSRot_fcc.u),2);
plot(ebsd_fcc,gnd_fcc);
hold all
plot(grains_fcc.boundary,'linewidth',1);
hold off
mtexColorMap(flipud(hot));
mtexColorbar;
set(gca,'ColorScale','log');
set(gca,'CLim',[min(gnd_fcc) max(gnd_fcc)]);

