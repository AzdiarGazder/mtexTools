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


%% Calculate the grains
% identify grains
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',5*degree);
% remove small clusters
ebsd(grains(grains.grainSize <= 5)) = [];
% re-calculate grains
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',5*degree);
% smooth grains
grains = smooth(grains,5);
% calculate the grain boundaries
gB = grains.boundary;


ebsd_fcc = ebsd('Fe-FCC');
grains_fcc = grains('Fe-FCC');
gB_fcc = gB('Fe-FCC','Fe-FCC');

cond = gB_fcc.misorientation.angle > 57 * degree;

figure
plot(ebsd_fcc,ebsd_fcc.orientations);
hold all;
plot(gB_fcc,'lineWidth',2);
plot(gB_fcc(cond),'lineWidth',2,'lineColor','w');
hold off;

figure
gbnd1 = calcGBPD(gB_fcc(cond),ebsd_fcc);
gbnd2 = calcGBPD(gB_fcc(~cond),ebsd_fcc);

contourf(gbnd1);
mtexTitle('GBPD for misorientation angle \(> 57^{\circ}\)');
mtexColorMap parula;
nextAxis;

contourf(gbnd2);
mtexTitle('GBPD for misorientation angle \(< 57^{\circ}\)');
mtexColorMap parula;
mtexColorbar;