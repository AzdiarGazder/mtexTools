%% Demonstration description:
% This script demonstrates how to automatically segment and quantify the 
% area fractions of granular bainite and polygonal ferrite in EBSD maps of 
% steel grades using the critical kernel average misorientation (KAM) 
% criterion.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements:
% For details, please refer to the following reference:
% RM Jentner, SP Tsai, A Welle, S Scholl, K Srivastava, JP Best, 
% C Kirchlechner, G Dehm, 'Automated classification of granular bainite 
% and polygonal ferrite by electron backscatter diffraction verified 
% through local structural and mechanical analyses',SSRN, 2023.
% https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4324505
% 
%% Syntax:
%  demo_kamSegmenter
%
%% Input:
%  none
%
%% Output:
% Output in the command window:
% - the area fractions of the microconstituents
%
% Figures comprising:
% - Plot: Granular bainite number fraction vs. KAM kernel size (um)
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
[stepSize,~] = calcStepSize(ebsd0);


% Make subsets of the zero solutions & other phases for later use
ebsd_nI = ebsd0('notindexed');
ebsd_fcc = ebsd0('Iron fcc');
% Specify the bcc phase for segmentation
ebsd_bcc = ebsd0('indexed');
ebsd_bcc = ebsd_bcc(CS.mineral);



%% Critical KAM -based segmentation parameters
% NOTE: Please make changes with care & prior knowledge of what the 
% variables do
criticalAngle = 5*degree; % to define a grain (options = 5 or 10)
maxkamOrder = 30;         % n-th neighbour to use for KAM calculations (do not use < 20)
fitThreshold = 0.99;      % quality of fit for calculating the inflection point for the 2 straight line sections in the plot
% ---


%% Calculate the grains
% identify grains
disp('Identifying grains...')
[grains_bcc,ebsd_bcc.grainId,ebsd_bcc.mis2mean] = calcGrains(ebsd_bcc('indexed'),'angle',criticalAngle,'unitcell');
disp('Done!')
% remove small clusters
disp('Deleting small grain clusters...')
ebsd_bcc(grains_bcc(grains_bcc.grainSize <= 5)) = [];
disp('Done!')
% recalculate the grains
disp('Re-calculating grains...')
[grains_bcc,ebsd_bcc.grainId,ebsd_bcc.mis2mean] = calcGrains(ebsd_bcc('indexed'),'angle',criticalAngle);
disp('Done!')

% store the crystal symmetry for later use
CS = grains_bcc.CS;
CS.color = [0 0 1];
fR = fundamentalRegion(CS,CS);


disp('---')
disp('Calculating KAM values...')
cnt = zeros(length(grains_bcc),maxkamOrder);
for jj = 1:maxkamOrder % KAM order
    kam = ebsd_bcc.KAM('order',jj);
    for ii = 1:length(grains_bcc)
        kamValues = kam(ismember(ebsd_bcc.grainId,ii));
        if any(kamValues >= 3*degree)
            cnt(ii,jj) = 1;
        end    
    end
    progress(jj,maxkamOrder);
end
disp('Done!')
disp('---')



disp('---')
disp('Calculating the inflection point...')
% % Based on the discussion shown in:
% % https://au.mathworks.com/matlabcentral/answers/509326-how-to-divide-the-curve-into-two-sections-and-then-fit-straight-line-for-both-sections-separately-an
xData = ((1:maxkamOrder).*stepSize)';
yData = (sum(cnt)./length(grains_bcc))';
numPoints = length(xData);

% The (x,y) data is best represented by a growth rate saturation equation
% Alternatively, the (x,y) data may also be fitted using a 3rd degree 
% polynominal
coeffs = polyfit(xData,yData,3);
xx = xData;
yy = polyval(coeffs, xx);

% Find the inflection point of the best fit polynomial based on a 
% user-defined fitting threshold
fitValue = 1; % initialize the fit value to 1
idx = 2;  % start with (x1,y1) and (x2,y2)
while fitValue >= fitThreshold && idx <= numPoints
    % Fit a straight line between points 1 and idx
    p = polyfit(xx(1:idx),yy(1:idx),1);
    
    % Calculate the correlation coefficient (fit value)
    yFit = polyval(p, xx(1:idx));
    r = corrcoef(yy(1:idx), yFit);
    fitValue = r(1,2);
    
    if fitValue >= fitThreshold
        idx = idx + 1; % move to the next point
    else 
        idx = idx - 1;
        break
    end
end
disp('Done!')
disp('---')

% Display the inflection point result
disp('---')
disp(['The 2 straight lines of best fit are between:']) 
disp(['points 1 to ' num2str(idx),' and points ',num2str(idx),' to ', num2str(numPoints)]);
disp(['Inflection point @ kernel size     : ' num2str(xData(idx)),' um']);
disp('---')


% Get the LHS data
xLHS = xData(1:idx);
yLHS = yData(1:idx);
% Fit a streight line through the LHS data
coeffsLHS = polyfit(xLHS,yLHS,1);
% Calculate the quality of fit
yfitLHS = polyval(coeffsLHS, xLHS);
rLHS = corrcoef(yLHS, yfitLHS);
fitValueLHS = rLHS(1,2);

% Get the RHS data
xRHS = xData(idx:end);
yRHS = yData(idx:end);
% Fit a line through the RHS data
coeffsRHS = polyfit(xRHS,yRHS,1);
% Calculate the quality of fit
yfitRHS = polyval(coeffsRHS, xRHS);
rRHS = corrcoef(yRHS, yfitRHS);
fitValueRHS = rRHS(1,2);

disp('---')
eq1 = sprintf('LHS  equation: y = %.3f * x + %.3f', coeffsLHS(1), coeffsLHS(2));
eq2 = sprintf('RHS  equation: y = %.3f * x + %.3f', coeffsRHS(1), coeffsRHS(2));
eq12 = sprintf('%s\n%s', eq1, eq2);
fprintf('%s\n', eq12);
disp('---')

disp('---')
disp(['Fit value for LHS line             : ' num2str(fitValueLHS)]);
disp(['Fit value for RHS line             : ' num2str(fitValueRHS)]);
disp('---')


% Plot the map and fitted data
figH = figure;

% Plot the map data
plot(xData, yData, 'o-b','lineWidth',2); 
grid on;
xlabel('KAM kernel size (um)','fontSize',14);
ylabel('Granular bainite number fraction','fontSize',14);
hold all;

% Plot the 3rd degree fitted polynomial
plot(xx, yy, '--k','lineWidth',2); 
hold all;

% Use the LHS equation to get the fitted yLHS values
xLHS = xData(1:idx+1);
yLHS = polyval(coeffsLHS, xLHS);
% Plot LHS line of best fit
plot(xLHS, yLHS,'r-','lineWidth',2);

% Use the RHS equation to get the fitted yRHS values
xRHS = xData(idx-1:end);
yRHS = polyval(coeffsRHS, xRHS);
% Plot RHS line of best fit
plot(xRHS, yRHS,'r-','lineWidth',2);

% Plot the inflection point
xInflection = (coeffsRHS(2) - coeffsLHS(2)) / (coeffsLHS(1) - coeffsRHS(1));
xline(xInflection,'color','k','lineWidth',2);



disp('---')
disp('Segmenting the microstucture using the KAM-based inflection point...')
criticalOrder = xData(idx)/stepSize;
criticalKAM = ebsd_bcc.KAM('order',criticalOrder);
criticalCnt = logical(cnt(:,criticalOrder));

grains_bainite = grains_bcc(criticalCnt);
grains_ferrite = grains_bcc(~criticalCnt);

ebsd_bainite = ebsd_bcc(ismember(ebsd_bcc.grainId,grains_bcc(criticalCnt).id));
ebsd_ferrite = ebsd_bcc(ismember(ebsd_bcc.grainId,grains_bcc(~criticalCnt).id));

% Calculate the area fractions
grainArea = area(grains_bcc);
area_bainite = sum(grainArea(criticalCnt));
area_ferrite = sum(grainArea(~criticalCnt));
area_total = sum(grainArea);

areaFraction_ferrite = area_ferrite / area_total;
areaFraction_bainite = area_bainite / area_total;

disp('Done!')
disp('---')


% Display the area fractions
disp('----');
disp(['Area fraction of polygonal ferrite  = ' num2str(areaFraction_ferrite)]);
disp(['Area fraction of granular bainite   = ' num2str(areaFraction_bainite)]);
disp('----');


return
%% Re-assigning the ferrite microconstituents as new phases in the ebsd map
% To get this section of the script to work, please do the following first:
% Go to C:\mtex\geometry\@symmetry\symmetry.m
% replace the first line with the following line:
% classdef symmetry < matlab.mixin.Copyable

% ---
% Assuming the ferrite phase that was orignally indexed in the map is 
% "polygonal ferrite"
ebsd_bcc.CSList{3}.mineral = 'Polygonal ferrite';
ebsd_bcc.CSList{3}.color = [0 0 1];

% define the crystal symmetries of the new phases
CS_bainite = copy(CS);

% assign names to these new symmetry
CS_bainite.mineral = 'Granular bainite';

% assign a color to the new symmetry
CS_bainite.color = [0.5 0.5 0];

% add the new symmetry to the EBSD data set
ebsd_bcc.CSList{end+1} = CS_bainite;

% assign a phase number to the new symmetry 
ebsd_bcc.phaseMap(end+1) = max(ebsd_bcc.phaseMap) + 1;

% change the  microconstituent fraction to the new phase number
ebsd_bcc(ismember(ebsd_bcc.grainId,grains_bainite.id)).phase = 3;

figH = figure;
plot(ebsd_bcc)
set(figH,'Name','Map: EBSD map of ferrite microconstituent distribution','NumberTitle','on');
% ---

% ----
% Add the zero solutions & fcc phase back to the map
% The following 2 lines are needed to populate the grainId and mis2mean
% variables. If this step is ignored, concatenation of the subsets will
% fail.
[~,ebsd_nI.grainId,ebsd_nI.mis2mean] = calcGrains(ebsd_nI('notIndexed'),'angle',criticalAngle,'unitcell'); 
[~,ebsd_fcc.grainId,ebsd_fcc.mis2mean] = calcGrains(ebsd_fcc('Iron fcc'),'angle',criticalAngle,'unitcell');

% add the new symmetry to the EBSD data set
ebsd_nI.CSList{end+1} = CS_bainite;
% assign a phase number to the new symmetry
ebsd_nI.phaseMap(end+1) = max(ebsd_bcc.phaseMap) + 1;

% add the new symmetry to the EBSD data set
ebsd_fcc.CSList{end+1} = CS_bainite;
% assign a phase number to the new symmetry 
ebsd_fcc.phaseMap(end+1) = max(ebsd_bcc.phaseMap) + 1;
% ---


% ---
% Concatenate the subsets
ebsd1 = [ebsd_nI, ebsd_fcc, ebsd_bcc];

figH = figure;
plot(ebsd1)
set(figH,'Name','Map: EBSD map of ferrite microconstituent distribution','NumberTitle','on');
% ---
