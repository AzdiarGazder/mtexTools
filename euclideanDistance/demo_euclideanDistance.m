close all; clc; clear all; clear hidden;

%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('FontSize',14);
set(0,'DefaultFigureWindowStyle','normal');


% %-----------------
% hexGrid
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outofPlane');
% define the crystal system
CS = {'notIndexed',...
    crystalSymmetry('m-3m', [2.9 2.9 2.9], 'mineral', 'Ferrite')};
% load an mtex dataset
mtexdata ferrite
ebsd.CSList = CS;
% %-----------------


% % %-----------------
% % squareGrid
% setMTEXpref('xAxisDirection','north');
% setMTEXpref('zAxisDirection','outofPlane');
% % define the crystal system
% CS = {'notIndexed',...
%     crystalSymmetry('6/mmm', [1.5708 1.5708 2.0944], 'X||a*', 'Y||b', 'Z||c*', 'mineral', 'Mg')};
% % load an mtex dataset
% mtexdata twins
% ebsd.CSList = CS;
% % %-----------------









%% Do not edit below this line
% % -----------------
[grains,ebsd.grainId] = calcGrains(ebsd,'threshold',2*degree);
% remove grains less than three pixels
ebsd(grains(grains.grainSize <= 3)) = [];
% re-compute the grains
[grains,ebsd.grainId] = calcGrains(ebsd,'threshold',2*degree);
% smooth grain boundaries
grains = smooth(grains,5);
% denoise the orientations
F = halfQuadraticFilter;
ebsd = smooth(ebsd,F,grains,'fill');

figure; plot(ebsd,ebsd.orientations)
hold all
plot(grains.boundary,'lineWidth',1)
hold off

% compute the 2D Euclidean distances
ebsd = euclideanDistance(ebsd,'angle',2*degree,'euclidean');
% ebsd = euclideanDistance(ebsd,'angle',2*degree,'euclidean','scanUnit');
% plot
figure; plot(ebsd,ebsd.euclid);
mtexColorbar('title','2D Euclidean distance in pixels')
% mtexColorbar('title','2D Euclidean distance in um')
mtexColorMap jet

% re-compute the grains
[grains,ebsd.grainId] = calcGrains(ebsd);

% plot the kernel average misorientation (KAM)
figure; plot(ebsd,ebsd.KAM('threshold',2*degree)./degree)
caxis([0,2])
mtexColorbar('title','Kernel average misorientation (KAM) in degrees')
mtexColorMap parula
hold all
plot(grains.boundary,'lineWidth',1)
hold off

% compute the KAM as a function of the 2D Euclidean distance
KAM_euclid = (ebsd.KAM('threshold',2*degree)./degree)./ebsd.euclid;
% plot
figure; plot(ebsd,KAM_euclid)
caxis([0,2])
mtexColorbar('title','KAM as a function of 2D Euclidean distance [°/pixel]')
% mtexColorbar('title','KAM per 2D Euclidean distance in degrees/um')
mtexColorMap LaboTeX
hold all
plot(grains.boundary,'lineWidth',1)
hold off


% plot the KAM as a function of the 2D Euclidean distance
figure;
yyaxis left
plot(ebsd.euclid,KAM_euclid,'.')
ylabel('\bf KAM as a function of 2D Euclidean distance [°/pixel]');
hold all
yyaxis right
%--- Calculate the counts in each class interval
numBins = 0:1:round(max(ebsd.euclid)/5)*5;
[counts,binCenters] = hist(KAM_euclid,numBins);
%--- Normalise the absolute counts in each class interval
normCounts = 1.*(counts./sum(counts));
h = area(binCenters, normCounts,...
    'linewidth',0.5,'edgecolor',[0 0 0], 'facecolor',[1 0 0], 'facealpha',0.25);
ylabel('\bf Relative frequency [f(g)]');
xlabel('\bf 2D Euclidean distance [um]','FontSize',14);
hold off;


% compute the grain reference orientation deviation (GROD)
GROD = ebsd.calcGROD(grains);
% plot
figure; plot(ebsd,GROD.angle./degree)
mtexColorbar('title','Grain reference orientation deviation (GROD) in degrees')
mtexColorMap cool
hold all
plot(grains.boundary,'lineWidth',1)
hold off

% plot the distribution of misorientation axes in the fundamental sector
axCrystal = GROD.axis;
figure; plot(axCrystal,'contourf','fundamentalRegion','antipodal');
mtexColorbar('title','Distribution of misorientation axes in mrd');

% define a directional color key
colorKey = HSVDirectionKey(ebsd.CS,'antipodal');
% compute the color from the misorientation axis
color = colorKey.direction2color(axCrystal);
% set the transperency from the misorientation angle as a function of
% the 2D Euclidean distance
alpha = min(ebsd.euclid,1);
% plot
figure; plot(ebsd,color,'faceAlpha',alpha);
hold all
plot(grains.boundary,'lineWidth',1)
hold off


return
KAM_euclidArea = (ebsd.KAM('threshold',2*degree)./degree)./ebsd.euclidArea;
% plot
figure; plot(ebsd,KAM_euclidArea)
caxis([0,2])
mtexColorbar('title','KAM as a function of 2D Euclidean distance [°/pixel]')
% mtexColorbar('title','KAM per 2D Euclidean distance in degrees/um')
mtexColorMap LaboTeX
hold all
plot(grains.boundary,'lineWidth',1)
hold off

figure;
plot(ebsd.euclid,KAM_euclidArea,'.')



