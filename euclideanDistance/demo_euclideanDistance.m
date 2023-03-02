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

% plot the orientation map
figure; 
plot(ebsd,ebsd.orientations)
hold all
plot(grains.boundary,'lineWidth',1.5)
hold off

% compute the 2D Euclidean distances
ebsd = euclideanDistance(ebsd,'angle',2*degree,'euclidean');
% ebsd = euclideanDistance(ebsd,'angle',2*degree,'euclidean','scanUnit');

% plot the 2D euclidean distance map
figure; 
plot(ebsd,ebsd.euclid);
mtexColorbar('title','2D Euclidean distance in pixels')
% mtexColorbar('title','2D Euclidean distance in um')
mtexColorMap jet

% re-compute the grains
[grains,ebsd.grainId] = calcGrains(ebsd,'threshold',2*degree);

% compute the kernel average misorientation (KAM)
kam = ebsd.KAM./degree;

% plot the KAM map
figure; 
plot(ebsd,kam);
caxis([0,round(max(ebsd.KAM./degree)/5)*5]);
mtexColorbar('title','Kernel average misorientation (KAM) in degrees')
mtexColorMap parula
hold all
plot(grains.boundary,'lineWidth',1.5)
hold off

% define the bins for the 2D Euclidean distance
% in this example: 1 pixel = 1 bin
numBins = 0:1:round(max(ebsd.euclid)/5)*5; % for max, round to the nearest 5
% find the bin indices for the 2D Euclidean distance array
[~,~,binIdx] = histcounts(ebsd.euclid,numBins);
% apply the bin indices of the 2D Euclidean distance array to the KAM array
for ii = 0:1:round(max(ebsd.euclid)/5)*5
    ro = find(binIdx == ii);
    temp = kam(ro,1); % may contain NaNs
    values_KAMperBin{ii+1} = temp(~isnan(temp)); % ignore NaNs
    counts_KAMperbin(ii+1,1) = size(values_KAMperBin{ii+1},1);
    mean_KAMperBin(ii+1,1) = mean(values_KAMperBin{ii+1});
    std_KAMperBin(ii+1,1) = std(values_KAMperBin{ii+1});
    max_KAMperBin(ii+1,1) = max(values_KAMperBin{ii+1});
    min_KAMperBin(ii+1,1) = min(values_KAMperBin{ii+1});
end

% plot the KAM as a function of the 2D Euclidean distance
figure;
yyaxis left
plot(0:1:round(max(ebsd.euclid)/5)*5,max_KAMperBin,'-ob','MarkerFaceColor','b','LineWidth',2);
hold on
plot(0:1:round(max(ebsd.euclid)/5)*5,min_KAMperBin,'-og','MarkerFaceColor','g','LineWidth',2);
hold on
ylabel('KAM [\circ, max = blue, min = green]')
yyaxis right
bar(0:1:round(max(ebsd.euclid)/5)*5,mean_KAMperBin,'FaceColor','r');
hold on
errhigh = mean_KAMperBin+std_KAMperBin;
errlow  = mean_KAMperBin-std_KAMperBin;
er = errorbar(0:1:round(max(ebsd.euclid)/5)*5,mean_KAMperBin,errlow,errhigh);
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
ylabel('Mean KAM [\circ, mean = red, err = black]')
hold off
title('KAM as a function of the 2D Euclidean distance')
xlabel('2D Euclidean distance [pixels]')
ax = gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'k';
% xlim([0 25])


% plot the image quality or band contrast as a function of the 2D 
% Euclidean distance
% in this example: up to 3 pixels from the grain center 
% (with 1 pixel = 1 bin)
ebsd.prop.iq = (255/max(ebsd.prop.iq)).*ebsd.prop.iq;
euclidIQ = NaN(size(ebsd.prop.iq));
ro = find(binIdx <= 3);
euclidIQ(ro,1) = ebsd.prop.iq(ro,1);
figure;
plot(ebsd,euclidIQ)
caxis([0,255])
mtexColorbar
mtexColorMap LaboTeX
hold on
plot(grains.boundary,'lineWidth',1)
hold off


% compute the grain reference orientation deviation (GROD)
GROD = ebsd.calcGROD(grains);
% plot
figure;
plot(ebsd,GROD.angle./degree)
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

% plot the IPF map as function of the 2D Euclidean distance (shown as transparency)
figure;
plot(ebsd,color,'faceAlpha',alpha);
hold all
[grains,ebsd.grainId] = calcGrains(ebsd,'threshold',[1 15]*degree);
plot(grains.boundary,'lineWidth',1.5);
% plot the subgrain boundaries
plot(grains.innerBoundary,'linewidth',1,'linecolor',[0.5 0.5 0.5]);
hold off


