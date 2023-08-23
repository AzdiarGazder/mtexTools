%% Demonstration description:
% This script demonstrates how to use EBSD map data to automatically 
% quantify the area fractions of various ferrite microconstituents 
% formed within steel grades produced by the CASTRIP(R) process.
% The three ferrite microconstituents namely, (1) acicular ferrite, 
% (2) polygonal ferrite and (3) bainite, significantly influence the 
% mechanical properties of steel. They are distinguished using the grain 
% aspect ratio, grain boundary misorientation angle, grain average 
% misorientation and grain size criteria.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements:
% Drs. Sachin Shrestha and Andrew Breen
% For developing the original script that used EBSD map data from the OI 
% Channel-5 Tango software as input.
% 
% For details, please refer to the following reference:
% SL Shrestha, AJ Breen, P Trimby, G Proust, SP Ringer, JM Cairney, 'An 
% automated method of quantifying ferrite microstructures using electron 
% backscatter diffraction (EBSD) data', Ultramicroscopy, 137, 2014, 40-47.
%
%% Syntax:
%  demo_ferriteQuantifier
%
%% Input:
%  none
%
%% Output:
% Output in the command window:
% - the number of grains having more than 1 critical misorientation and 
%   excluded from the analysis (ideally = 0)
% - the volume fractions of the microconstituents
%
% Figures comprising:
% - Map: Image quality/band contrast
% - Map: IPF
% - Histogram: Grain boundary misorientation distribution
% - Histogram: Grain area vs. grain boundary misorientation distribution
% - Histogram: Grain aspect ratio distribution
% - Histogram: Grain average misorientation (GAM) distribution
% - Map: EBSD map of ferrite microconstituent distribution
%
%% Options:
%  none
%
%%


% clear variables
clc; clear all; clear hidden; close all;

% start Mtex
startup_mtex;

% define Mtex plotting convention as X = right, Y = up
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('FontSize', 14);

% load mtex example data
mtexdata ferrite
ebsd.phaseMap = [0; 1]; % over-writing the strange numbers in the MTEX dataset



%% Calculate the grains
% identify grains
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',[1 5].*degree,'unitcell');
% remove small clusters
ebsd(grains(grains.grainSize <= 5)) = [];
% store the crystal symmetry for later use
CS = grains.CS;
CS.color = [0 0 1];
fR = fundamentalRegion(CS,CS);

figH = figure;
plot(ebsd(CS.mineral),ebsd(CS.mineral).iq);
colormap(gray)
set(figH,'Name','Map: Image quality','NumberTitle','on');


figH = figure;
ipfKey = ipfColorKey(ebsd(CS.mineral));
colors = ipfKey.orientation2color(ebsd(CS.mineral).orientations);
plot(ebsd(CS.mineral),colors)
set(figH,'Name','Map: IPF','NumberTitle','on');



%% calculate the grains
for ii = 5:2:ceil((fR.maxAngle/degree)/0.5)*0.5
    [grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',[1 ii].*degree,'unitcell');
    cnt = sum(rem(5:2:ii,2));
    grainsCells{cnt} =  grains;
    ebsdCells{cnt} =  ebsd;
end



%% Calculate the logical matrix of grainIds
logicalMatrix1 = zeros(length(grainsCells{1}),30);
logicalMatrix2 = zeros(length(grainsCells{1}),30);
for ii = 1:cnt
[tempLogical,~] = ismember(grainsCells{1}.centroid,grainsCells{ii}.centroid,'rows');
logicalMatrix1(:,ii) = tempLogical;
end
% if the index of a grain in a column is different from the index of the 
% grain in a previous column; then that grain is within the bin of critical 
% misorientation
for ii = 2:cnt % start from the second column
        logicalMatrix2(:,ii) = logicalMatrix1(:,ii-1) ~= logicalMatrix1(:,ii);   
end
logicalMatrix2 = logical(logicalMatrix2);

% A bug in the OI Channel-5 Tango software causes the same grains to be 
% counted in more than 1 bin. In case such an error occurs in MTex, 
% where grains have more than one critical misorientation, they should be 
% removed from the analysis.
numGrains = sum(sum(logicalMatrix2') > 1);
display('----');
display(['Number of grains with > 1 critical misorientation        = ' num2str(numGrains)]);
display(['Percent grains deleted from the analyis due to the above = ' num2str(100*(numGrains/length(logicalMatrix2)))]);
display('----');
% remove grains that are in more than one bin
idx = sum(logicalMatrix2') > 1;
logicalMatrix1(idx,:) = [];
logicalMatrix2(idx,:) = [];
grains_baseSet = grainsCells{1}(~idx);
ebsd_baseSet = ebsdCells{1}(ismember(ebsdCells{1}.grainId,grains_baseSet.id));



%% Calculate the grain boundaries
gB = grains_baseSet(CS.mineral).boundary(CS.mineral,CS.mineral);
% calculate the grain misorientation angles
miso = gB.misorientation.angle./degree;
% define the class interval and range
classRange = [5:2:ceil((fR.maxAngle/degree)/0.5)*0.5]';
% calculate the number of absolute counts in each class interval
counts.absolute = histc(miso,classRange);
% normalise the absolute counts in each class interval
counts.normalised = 1.*(counts.absolute./sum(counts.absolute));
misoData = [classRange, counts.normalised];
figH = figure;
bar(classRange, counts.normalised,'barwidth',1);
xlabel('Grain boundary misorientation (deg)','fontsize',14, 'color', 'k')
ylabel('Normalised frequency','fontsize',14,'color', 'k')
set(gca,'XColor','k','YColor','k','fontsize',14,'linewidth',2,'box','on','xtick',5:2:ceil((fR.maxAngle/degree)/0.5)*0.5);
set(figH,'Name','Histogram: Grain boundary misorientation distribution','NumberTitle','on');



%% Calculate the grain area
grainArea = area(grains_baseSet);
% calculate the area fractions of each bin
areaTotal = sum(grainArea);
areaAbs = zeros(1,30);
areaFraction = zeros(1,30);
for ii = 1:cnt 
    areaAbs(ii) = sum(grainArea(logicalMatrix2(:,ii)));
    areaFraction(ii) = areaAbs(ii) / areaTotal;
end
% plot a bar chart of the percent area for each interval
figH = figure;
bar(5:2:ceil((fR.maxAngle/degree)/0.5)*0.5,areaFraction,'barwidth',1);
xlabel('Grain boundary misorientation (deg)','fontsize',14)
ylabel('Normalised grain area fraction','fontsize',14)
set(gca,'XColor','k','YColor','k','fontsize',14,'linewidth',2,'box','on','xtick',5:2:ceil((fR.maxAngle/degree)/0.5)*0.5)
set(figH,'Name','Histogram: Grain area vs. grain boundary misorientation distribution','NumberTitle','on');



%% Calculate the grain aspect ratio
[~, grainLength, grainWidth] = principalComponents(grains_baseSet);
grainAspectRatio = abs(grainLength./grainWidth);
% histogram of the grain aspect ratio
classRange = 1:0.1:ceil(max(grainAspectRatio)/10)*10;
counts.absolute = histc(grainAspectRatio,classRange);
% normalise the absolute counts in each class interval
counts.normalised = 1.*(counts.absolute./sum(counts.absolute));

expFit = fit(classRange', counts.normalised,'gauss2');
xFit = 1:0.01:ceil(max(grainAspectRatio)/10)*10;
y1Fit = expFit.a1 * exp(-((xFit - expFit.b1) / expFit.c1).^2);
y2Fit = expFit.a2 * exp(-((xFit - expFit.b2) / expFit.c2).^2);

figH = figure;
plot(classRange,counts.normalised,'o','MarkerSize',5,'markeredgecolor','k','linewidth',2);
hold all
plot(xFit, y1Fit, '--r', xFit, y2Fit, '--b', 'linewidth', 2);
plot(xFit,(y1Fit + y2Fit),'k', 'linewidth',3);
xlabel('Grain aspect ratio','fontsize',14, 'color', 'k')
ylabel('Normalised number of grains','fontsize',14,'color', 'k')
set(gca,'XColor','k','YColor','k','fontsize',14,'linewidth',2,'box','on', 'xtick',1:1:ceil(max(grainAspectRatio)/10)*10);
legend('mapData', 'gaussFit 1', 'gaussFit 2', 'fit')
set(figH,'Name','Histogram: Grain aspect ratio distribution','NumberTitle','on');



%% Calculate the grain average misorientation
gam = ebsd_baseSet.grainMean(ebsd_baseSet.KAM)./degree;
% histogram of the grain average misorientation
classRange = 0:0.1:ceil(max(gam)/10)*10;
counts.absolute = histc(gam,classRange);
% normalise the absolute counts in each class interval
counts.normalised = 1.*(counts.absolute./sum(counts.absolute));
figH = figure;
plot(classRange,counts.normalised,'o','MarkerSize',5,'markeredgecolor','k','linewidth',2);
hold all
f = fit(classRange',counts.normalised,'smoothingspline');
fPlot = plot(f);
set(fPlot,'linewidth',2)
xlabel('Grain average misorientation (GAM, deg.)','fontsize',14, 'color', 'k')
ylabel('Normalised frequency','fontsize',14,'color', 'k')
set(gca,'XColor','k','YColor','k','fontsize',14,'linewidth',2,'box','on', 'xtick',0:1:ceil(max(gam)/10)*10);
legend('mapData', 'fit')
set(figH,'Name','Histogram: Grain average misorientation (GAM) distribution','NumberTitle','on');



%% Calculate the area fractions of the ferrite microconstituents
% acicular ferrite
% create an index of grains with a critical misorientation >50 deg and aspect
% ratio > 2.3
idx_acicularFerrite = sum(logicalMatrix2(:,20:end)')' == 1 & grainAspectRatio > 2.3;
grains_acicularFerrite = grains_baseSet(idx_acicularFerrite);
ebsd_acicularFerrite = ebsd_baseSet(ismember(ebsd_baseSet.grainId,grains_acicularFerrite.id));
area_acicularFerrite = sum(grainArea(idx_acicularFerrite));

% polygonal ferrite
% create an index of grains with aspect ratio < 1.5
idx_polygonalFerrite1 = grainAspectRatio < 1.5 & idx_acicularFerrite == 0;
% create an index of grains with aspect ratio >= 1.5, gam <= 3 amd area >= 150
idx_polygonalFerrite2 = grainAspectRatio >= 1.5 & gam <= 3 & grainArea >= 150 & idx_acicularFerrite == 0;
idx_polygonalFerrite = idx_polygonalFerrite1 | idx_polygonalFerrite2;
grains_polygonalFerrite = grains_baseSet(idx_polygonalFerrite);
ebsd_polygonalFerrite = ebsd_baseSet(ismember(ebsd_baseSet.grainId,grains_polygonalFerrite.id));
area_polygonalFerrite = sum(grainArea(idx_polygonalFerrite));


% bainite
idx_bainite = ones(length(grains_baseSet),1) & idx_acicularFerrite == 0 & idx_polygonalFerrite == 0;
grains_bainite = grains_baseSet(idx_bainite);
ebsd_bainite = ebsd_baseSet(ismember(ebsd_baseSet.grainId,grains_bainite.id));
area_bainite = sum(grainArea(idx_bainite));
% area_bainite = totalArea - (area_acicularFerrite + area_polygonalFerrite);


% calculate the area fractions
totalArea = sum(grainArea);
areaFraction_acicularFerrite = area_acicularFerrite / totalArea;
areaFraction_polygonalFerrite = area_polygonalFerrite / totalArea;
areaFraction_bainite = area_bainite / totalArea;

% display the area fractions
display('----');
display(['Area fraction of acicular ferrite   = ' num2str(areaFraction_acicularFerrite)]);
display(['Area fraction of polygonal ferrite  = ' num2str(areaFraction_polygonalFerrite)]);
display(['Area fraction of bainite            = ' num2str(areaFraction_bainite)]);
display('----');



figH = figure;
ebsd_polygonalFerrite.CS.color = [0 0 1];
ebsd_polygonalFerrite.CS.mineral = 'Polygonal ferrite';
plot(ebsd_polygonalFerrite)
hold all;
ebsd_acicularFerrite.CS.color = [1 0 0];
ebsd_acicularFerrite.CS.mineral = 'Acicular ferrite';
plot(ebsd_acicularFerrite)
ebsd_bainite.CS.color = [1 1 0];
ebsd_bainite.CS.mineral = 'Bainite';
plot(ebsd_bainite)
set(figH,'Name','Map: EBSD map of ferrite microconstituent distribution','NumberTitle','on');




return

%% Re-assigning the ferrite microconstituents as new phases
% This is currently not working due to a bug in MTEX

% Assume the ferrite phase that was orignally indexed in the map is 
% "polygonal ferrite"
ebsd_baseSet.CS.mineral = 'Polygonal ferrite';

% define the crystal symmetries of the new phases
CS_acicularFerrite = CS;
CS_bainite = CS;
clear CS

% assign names to these new phases
CS_acicularFerrite.mineral = 'Acicular ferrite';
CS_bainite.mineral = 'Bainite';

% assign colors to these new phases
CS_acicularFerrite.color = [1 0 0];
CS_bainite.color = [1 1 0];

% add the new phases to the EBSD data set
ebsd_baseSet.CSList{end+1} = CS_acicularFerrite;
ebsd_baseSet.CSList{end+1} = CS_bainite;

% based on the EBSD map, give these symmetries phase numbers 
ebsd_baseSet.phaseMap(end+1) = max(ebsd_baseSet.phaseMap) + 1;
ebsd_baseSet.phaseMap(end+1) = max(ebsd_baseSet.phaseMap) + 1;

% change the phase number of each microconstituent to the new phase number
ebsd_baseSet(ismember(ebsd_baseSet.grainId,grains_acicularFerrite.id)).phase = 2;
ebsd_baseSet(ismember(ebsd_baseSet.grainId,grains_bainite.id)).phase = 3;

figH = figure;
plot(ebsd_baseSet)
set(figH,'Name','Map: EBSD map of ferrite microconstituent distribution','NumberTitle','on');

