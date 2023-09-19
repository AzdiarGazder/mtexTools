%% Demonstration description:
% This script demonstrates how to automatically segment and quantify the 
% area fractions of various ferrite microconstituents in EBSD maps of 
% steel grades produced by the CASTRIP(R) process.
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
% https://www.sciencedirect.com/science/article/pii/S0304399113002957
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
% - the area fractions of the microconstituents
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

% % load example data
% crystal symmetry
CS0 = {...
    'notIndexed',...
    crystalSymmetry('m-3m', [3.7 3.7 3.7], 'mineral', 'Iron fcc', 'color', [1 0 0]),...
    crystalSymmetry('m-3m', [2.9 2.9 2.9], 'mineral', 'Iron bcc (old)', 'color', [0 0 1])};
% Import the dataset
ebsd0 = EBSD.load('Duplex.ctf',CS0,'interface','ctf',...
    'convertEuler2SpatialReferenceFrame');
ebsd0 = gridify(ebsd0);
% store the bcc crystal symmetry for later use
% NOTE: the CSList index changes depending on the number of the bcc 
% phase in the ebsd map
CS = ebsd0.CSList{3};
CS.color = [0 0 1];
fR = fundamentalRegion(CS,CS);

% Make subsets of the zero solutions & other phases for later use
ebsd_nI = ebsd0('notindexed');
ebsd_fcc = ebsd0('Iron fcc');
% Specify the bcc phase for segmentation
ebsd_bcc = ebsd0('indexed');
ebsd_bcc = ebsd_bcc(CS.mineral);


%% Calculate the grains
% identify grains
[grains_bcc,ebsd_bcc.grainId,ebsd_bcc.mis2mean] = calcGrains(ebsd_bcc(CS.mineral),'angle',[1 5].*degree,'unitcell');
% remove small clusters
ebsd_bcc(grains_bcc(grains_bcc.grainSize <= 5)) = [];


figH = figure;
% plot(ebsd_bcc(CS.mineral),ebsd_bcc(CS.mineral).iq);
plot(ebsd_bcc(CS.mineral),ebsd_bcc(CS.mineral).bc);
colormap(gray)
set(figH,'Name','Map: Image quality','NumberTitle','on');


figH = figure;
ipfKey = ipfColorKey(ebsd_bcc(CS.mineral));
colors = ipfKey.orientation2color(ebsd_bcc(CS.mineral).orientations);
plot(ebsd_bcc(CS.mineral),colors)
set(figH,'Name','Map: IPF','NumberTitle','on');



%% calculate the grains
for ii = 5:2:ceil((fR.maxAngle/degree)/0.5)*0.5
    [grains_bcc,ebsd_bcc.grainId,ebsd_bcc.mis2mean] = calcGrains(ebsd_bcc('indexed'),'angle',[1 ii].*degree,'unitcell');
    cnt = sum(rem(5:2:ii,2));
    grainsCells{cnt} =  grains_bcc;
    ebsdCells{cnt} =  ebsd_bcc;
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
ebsd_acicularFerrite.CS.color = [0 1 1];
ebsd_acicularFerrite.CS.mineral = 'Acicular ferrite';
plot(ebsd_acicularFerrite)
ebsd_bainite.CS.color = [0.5 0.5 0];
ebsd_bainite.CS.mineral = 'Bainite';
plot(ebsd_bainite)
set(figH,'Name','Map: EBSD map of ferrite microconstituent distribution','NumberTitle','on');




return
%% Re-assigning the ferrite microconstituents as new phases in the ebsd map
% To get this section of the script to work, please do the following first:
% Go to C:\mtex\geometry\@symmetry\symmetry.m
% replace the first line with the following line:
% classdef symmetry < matlab.mixin.Copyable

% ---
% Assuming the ferrite phase that was orignally indexed in the map is 
% "polygonal ferrite"
ebsd_baseSet.CSList{3}.mineral = 'Polygonal ferrite';
ebsd_baseSet.CSList{3}.color = [0 0 1];

% define the crystal symmetries of the new phases
CS_acicularFerrite = copy(CS);
CS_bainite = copy(CS);

% assign names to these new symmetries
CS_acicularFerrite.mineral = 'Acicular ferrite';
CS_bainite.mineral = 'Bainite';

% assign colors to these new symmetries
CS_acicularFerrite.color = [0 1 1];
CS_bainite.color = [0.5 0.5 0];

% add the new symmetries to the EBSD data set
ebsd_baseSet.CSList{end+1} = CS_acicularFerrite;
ebsd_baseSet.CSList{end+1} = CS_bainite;

% assign phase numbers to these new symmetries 
ebsd_baseSet.phaseMap(end+1) = max(ebsd_baseSet.phaseMap) + 1;
ebsd_baseSet.phaseMap(end+1) = max(ebsd_baseSet.phaseMap) + 1;

% change each microconstituent fraction to the new phase number
ebsd_baseSet(ismember(ebsd_baseSet.grainId,grains_acicularFerrite.id)).phase = 3;
ebsd_baseSet(ismember(ebsd_baseSet.grainId,grains_bainite.id)).phase = 4;

figH = figure;
plot(ebsd_baseSet)
set(figH,'Name','Map: EBSD map of ferrite microconstituent distribution','NumberTitle','on');
% ---


% ----
% Add the zero solutions & fcc phase back to the map
% The following 2 lines are needed to populate the grainId and mis2mean
% variables. If this step is ignored, concatenation of the subsets will
% fail.
[~,ebsd_nI.grainId,ebsd_nI.mis2mean] = calcGrains(ebsd_nI('notIndexed'),'angle',[1 5].*degree,'unitcell'); 
[~,ebsd_fcc.grainId,ebsd_fcc.mis2mean] = calcGrains(ebsd_fcc('Iron fcc'),'angle',[1 5].*degree,'unitcell');

% add the new symmetries to the EBSD data set
ebsd_nI.CSList{end+1} = CS_acicularFerrite;
ebsd_nI.CSList{end+1} = CS_bainite;
% assign phase numbers to these new symmetries 
ebsd_nI.phaseMap(end+1) = max(ebsd_baseSet.phaseMap) + 1;
ebsd_nI.phaseMap(end+1) = max(ebsd_baseSet.phaseMap) + 1;

% add the new symmetries to the EBSD data set
ebsd_fcc.CSList{end+1} = CS_acicularFerrite;
ebsd_fcc.CSList{end+1} = CS_bainite;
% assign phase numbers to these new symmetries 
ebsd_fcc.phaseMap(end+1) = max(ebsd_baseSet.phaseMap) + 1;
ebsd_fcc.phaseMap(end+1) = max(ebsd_baseSet.phaseMap) + 1;
% ---


% ---
% Concatenate the subsets
ebsd1 = [ebsd_nI, ebsd_fcc, ebsd_baseSet];

figH = figure;
plot(ebsd1)
set(figH,'Name','Map: EBSD map of ferrite microconstituent distribution','NumberTitle','on');
% ---


