function hFig = plotHeatScatter(xData, yData, varargin)
%% Function description:
% Plots a density distribution of the yData versus the xData using user-
% specified tiles by applying custom patches. The xData and yData are 
% equally sized vectors. Rows containing NaN values in either vectors are 
% ignored.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgement(s):
% Gordon Bean and Lukas, for the original functions posted in:
% https://au.mathworks.com/matlabcentral/fileexchange/45639-hexscatter-m 
% https://www.mathworks.com/matlabcentral/fileexchange/47165-heatscatter-plot-for-variables-x-and-y
%
%% Syntax:
%  plotHeatScatter(xData,yData,varargin) 
%
%% Input:
%  xData               - @double
%  yData               - @double
%
%% Options:
% lineStyle        - @char, Defines the line style
%                    '-'     = solid
%                    ':'     = dotted
%                    '-.'    = dashdot 
%                    '--'    = dashed   
%                    (none)  = no line
% lineColor        - @double, Defines the line [RGB] color
% lineWeight       - @double, Defines the line weight
% marker           - @char, Defines the marker type
%                    'c'     = circle
%                    'o'     = octagon
%                    'h'     = hexagon
%                    'p'     = pentagon
%                    'd'     = diamond
%                    's'     = square
%                    'e'     = equilateral triangle
%                    '^'     = isosceles triangle (up)
%                    'v'     = isosceles triangle (down)
%                    '<'     = isosceles triangle (left)
%                    '>'     = isosceles triangle (right)
%                    '*'     = star
%                    '+'     = cross
%                    'x'     = x-mark
% markerEdgeColor  - @double, Defines the marker edge [RGB] color
% resolution       - @double, Defines the grid resolution
% colormap         - @char, Defines the colormap of the grid
% showZeros        - @binary, Flag whether/not to plot the background
%                    values
% 
%%


%% Check for the input data
if ~isvector(xData) || ~isvector(yData) || length(xData) ~= length(yData)
    error('Error. xData and yData must be of the same length.');
end

%% Define the lineStyle
lineStyle = get_option(varargin,'lineStyle','-');

%% Define the lineColor
lineColor = get_option(varargin,'lineColor',[0 0 0]);

%% Define the lineWidth
lineWidth = get_option(varargin,'lineWidth',2);

%% Define the markerType
markerType = get_option(varargin,'marker','c');

%% Define the markerEdgeColor
markerEdgeColor = get_option(varargin,'markerEdgeColor','none');

%% Define the grid resolution
resolution = get_option(varargin,'resolution',50);

%% Define the colormap
colorMap = get_option(varargin,'colormap',parula);

%% Define the flag for showing zeros
showZeros = get_option(varargin,'showZeros',false);


% Determine grid
xLimits = [min(xData(:)) max(xData(:))];
yLimits = [min(yData(:)) max(yData(:))];

xBins = linspace(xLimits(1), xLimits(2), resolution);
yBins = linspace(yLimits(1), yLimits(2), resolution);
deltaY = diff(yBins([1 2])) * 0.5;

[X, Y] = meshgrid(xBins, yBins);
numRows = size(X, 1);
Y(:, 1:fix(end/2)*2) = Y(:, 1:fix(end/2)*2) + repmat([0 deltaY], [numRows, fix(numRows/2)]);

% Map points to boxes
invalidIndices = isnan(xData) | isnan(yData);
xData = xData(~invalidIndices);
yData = yData(~invalidIndices);

% Determine pair of columns
deltaX = diff(xBins([1 2]));
columnIndices = min(length(xBins), max(1, floor((xData - xBins(1)) ./ deltaX) + 1));

% Determine pair of rows using the first row (which starts without an offset) as the standard
rowIndices = min(length(yBins), max(1, floor((yData - yBins(1)) ./ diff(yBins([1 2]))) + 1));

% Determine orientation
orientation = mod(columnIndices, 2) == 1;

% Map points to boxes
dataPoints = [xData - xBins(columnIndices)', yData - yBins(rowIndices)'];
columnIndices = min(length(xBins), max(1, columnIndices));

rowIndices = min(length(yBins), max(1, rowIndices));

% Determine layer
layer = dataPoints(:, 2) > deltaY;

% Transform coordinates to block B format
toFlip = layer == orientation;
dataPoints(toFlip, 1) = deltaX - dataPoints(toFlip, 1);
dataPoints(layer == 1, 2) = dataPoints(layer == 1, 2) - deltaY;

% Previous distance from points to bins
previousDistances = sqrt(sum(dataPoints.^2, 2));
% Updated distance from points to bins after flipping
updatedDistances = sqrt(sum(bsxfun(@minus, [deltaX deltaY], dataPoints).^2, 2));
% Find closest corner
topRightCorner = previousDistances > updatedDistances;

% Map corners back to bins
xBinIndices = min(length(xBins), max(1, columnIndices + ~(orientation == (layer == topRightCorner))));
yBinIndices = min(length(yBins), max(1, rowIndices + (layer & topRightCorner)));

indices = sub2ind(size(X), yBinIndices, xBinIndices);

% Determine counts
counts = histcounts(indices, 1:numel(X)+1);

% Plot the figure
newplot;
xScale = deltaX * 1 / sqrt(3);
yScale = diff(yBins([1 2])) * 1 / sqrt(3);
% xScale = deltaX * 2 / 3;
% yScale = diff(yBins([1 2])) * 1 / sqrt(3);

%% Make the marker shape
switch markerType
    case {'c'}
        [forX,forY] = markerMaker(1*degree,0);

    case {'o'}
        [forX,forY] = markerMaker(45*degree,0);

    case {'h'}
        [forX,forY] = markerMaker(60*degree,1);

    case {'p'}
        [forX,forY] = markerMaker(70*degree,0);

    case {'d'}
        [forX,forY] = markerMaker(90*degree,0);

    case {'s'}
        [forX,forY] = markerMaker(90*degree,0);
        forXY = [forX(:),forY(:)];
        rot = 45*degree;
        R = [cos(rot) -sin(rot); sin(rot) cos(rot)];
        % rotate point(s) counterclockwise
        temp = (R*forXY')';
        forX = temp(:,1)';
        forY = temp(:,2)';

    case {'e'}
        [forX,forY] = markerMaker(120*degree,0);

    case {'^'}
        [forX,forY] = markerMaker(120*degree,0);
        forY = 1./forY;

    case {'v'}
        [forX,forY] = markerMaker(120*degree,0);
        forX = -forX; 
        forY = -1./forY;

    case {'<'}
        [forX,forY] = markerMaker(120*degree,1);
        forX = -1./forX; 
        forY = -forY;

    case {'>'}
        [forX,forY] = markerMaker(120*degree,1);
        forX = 1./forX;

    case {'*'}
        % for even indices
        ii = 1:10; idx = mod(ii, 2) == 0;
        forX(idx) = 2/5 * cos(pi/2 + (ii(idx)-1) * pi/5);
        forY(idx) = 2/5 * sin(pi/2 + (ii(idx)-1) * pi/5);
        % for odd indices
        forX(~idx) = cos(pi/2 + (ii(~idx)-1) * pi/5);
        forY(~idx) = sin(pi/2 + (ii(~idx)-1) * pi/5);

    case {'+'}
        forX = [-0.5 +0.5 +0.5 +1.5 +1.5 +0.5 +0.5 -0.5 -0.5 -1.5 -1.5 -0.5 -0.5];
        forY = [-1.5 -1.5 -0.5 -0.5 +0.5 +0.5 +1.5 +1.5 +0.5 +0.5 -0.5 -0.5 -1.5];

    case {'x'}
        forX = [-0.5 +0.5 +0.5 +1.5 +1.5 +0.5 +0.5 -0.5 -0.5 -1.5 -1.5 -0.5 -0.5];
        forY = [-1.5 -1.5 -0.5 -0.5 +0.5 +0.5 +1.5 +1.5 +0.5 +0.5 -0.5 -0.5 -1.5];
        forXY = [forX(:),forY(:)];
        rot = 45*degree;
        R = [cos(rot) -sin(rot); sin(rot) cos(rot)];
        % rotate point(s) counterclockwise
        temp = (R*forXY')';
        forX = temp(:,1)';
        forY = temp(:,2)';
    
    otherwise
        error('Invalid shape specified. Supported shapes: c, o, h, p, d, s, e, ^, v, <, >, *, +, x');

end

xCoordinates = bsxfun(@plus, X(:), forX * xScale)';
yCoordinates = bsxfun(@plus, Y(:), forY * yScale)';


% Plot a transparent scatter plot (to calculate the least squares line)
hFig = scatter(xData, yData, ones(size(xData)),'MarkerFaceAlpha',.0,'MarkerEdgeAlpha',.0);
hold all;

if showZeros
    hFig = patch(xCoordinates, yCoordinates, counts, 'EdgeColor', markerEdgeColor, 'FaceVertexCData', counts(:));
    xlim([min(xCoordinates,[],"all"), max(xCoordinates,[],"all")]);
    ylim([min(yCoordinates,[],"all"), max(yCoordinates,[],"all")]);

else
    validCounts = counts > 0;
    hFig = patch(xCoordinates(:, validCounts), yCoordinates(:, validCounts), counts(validCounts), 'EdgeColor', markerEdgeColor, 'FaceVertexCData', counts(validCounts)');
    xlim([min(xCoordinates(:, validCounts),[],"all"), max(xCoordinates(:, validCounts),[],"all")]);
    ylim([min(yCoordinates(:, validCounts),[],"all"), max(yCoordinates(:, validCounts),[],"all")]);
end
box on;
axis square;
colormap(colorMap);
colorbar;

[r,p] = corr(xData, yData);
str = {sprintf('corr: %.3f', r), sprintf('pVal: %d', p)};
annotation('textbox', [0.2 0.80 0.1 0.1], 'String', str, 'EdgeColor', 'none');
l = lsline(gca);
set(l,'Color', lineColor,'lineStyle',lineStyle,'lineWidth', lineWidth);


if nargout == 0
    clear hFig;
end

end



function [forX,forY] = markerMaker(thetaStep,flagFlip)
theta = 0:thetaStep:360*degree;

if flagFlip == 0
    forX = sin(theta);
    forY = cos(theta);

elseif flagFlip == 1
    forX = cos(theta);
    forY = sin(theta);
end

end