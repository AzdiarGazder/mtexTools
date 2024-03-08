function figH = plotMcKenzie(n,varargin)
%% Function description:
% Plots the McKenzie distribution of 1 or 2 crystal systems for a 
% user-defined number of orientations in publication-ready format. It 
% returns the histogram data as well as MTEX's default McKenzie distribtuon
% after scaling.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  plotMcKenzie(n,CS,varargin)
%
%% Input:
%  n               - @double
%  CS              - @crystalSymmetry
%
%% Options:
%  bins            - @double, the number of bins for the distribution
%
%%


% Apply the class function to each element of varargin
vargTypes = cellfun(@class, varargin, 'UniformOutput', false);

% Return a logical array for search string matches
matchIdx = strcmp(vargTypes, 'crystalSymmetry');
% Find the column indices of the matches
[~, col] = find(matchIdx == 1);
% Count the number of matches
numMatch = numel(col);

if numMatch == 1
    CS = varargin{col(1)};
    % Define the fundamental region of the crystal symmetry
    fR = fundamentalRegion(CS);
    % Define n - number of random orientations
    ori1 = orientation.rand(n,CS);
    ori2 = orientation.rand(n,CS);
elseif numMatch == 2
    CS1 = varargin{col(1)};
    CS2 = varargin{col(2)};
    % Define the fundamental region of the crystal symmetry
    fR = fundamentalRegion(CS1,CS2);
    % Define n - number of random orientations
    ori1 = orientation.rand(n,CS1);
    ori2 = orientation.rand(n,CS2);
elseif numMatch > 2
    error('A maximum of two crystal symmetries are allowed.');
end

% Calculate the maximum misorientation of the crystal symmetry
maxAngle = fR.maxAngle./degree;

% Calculate the misorientation angle between the random orientations
miso = (inv(ori1).*ori2);
miso = miso.angle./degree;

% Calculate the McKenzie histogram
numBins = get_option(varargin,'bins',length(1:ceil(maxAngle)));
binWidth = ceil(maxAngle) / numBins;
% Bin the data using the specified bin width and number of bins
[counts, binEdges] = histcounts(miso, 'BinWidth', binWidth, 'NumBins', numBins);
% Calculate the bin centers
binCenters = binEdges(1:end-1) + binWidth/2;
% Calculate the probability distribution function (PDF)
pdf = counts ./ (sum(counts) * binWidth);

disp('boo3')
figH = figure;
% Plot MTEX's default McKenzie distribution while scaling its y-axis data
% to the number of orientations
if numMatch == 1
    h1 = plotAngleDistribution(CS,CS,'numBins',numBins);
elseif numMatch == 2
    h1 = plotAngleDistribution(CS1,CS2,'numBins',numBins);
end
hold all;
% Plot the misorientation histogram based on the user defined number of
% bins
h2 = bar(binCenters,pdf);
hold all;
% Scale MTEX's default McKenzie distribution to the data
h1.YData = (h1.YData./sum(h1.YData));
scaleFactor = max(h2.YData)/max(h1.YData);
h1.YData = h1.YData.* scaleFactor;
hold off;
xlabel('Misorientation angle (°)')
ylabel('Normalised freq.');

% % Output histogram data in a table
disp(table(binCenters',h2.YData','VariableNames',{'bins','Freq'}))


end
