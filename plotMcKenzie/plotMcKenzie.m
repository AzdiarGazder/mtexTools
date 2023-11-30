function figH = plotMcKenzie(n,CS,varargin)
%% Function description:
% Plots the McKenzie distribution of a crystal system for a user-defined 
% number of orientations in publication-ready format. It returns the 
% histogram data as well as MTEX's default McKenzie distribtuon after 
% scaling.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  plotPF(n,CS,varargin) 
%
%% Input:
%  n               - @double
%  CS              - @crystalSymmetry
%
%% Options:
%  bins            - @double, the number of bins for the distribution
%
%%


% Define the fundamental region of the crystal symmetry
fR = fundamentalRegion(CS);
% Calculate the maximum misorientation of the crystal symmetry
maxAngle = fR.maxAngle./degree; 

% Define n - number of random orientations
ori1 = orientation.rand(n,CS);
ori2 = orientation.rand(n,CS);
% Calculate the misorientation angle between the random orientations
miso = (inv(ori1).*ori2);
miso = miso.angle./degree;

% Calculate the McKenzie historgram
numBins = get_option(varargin,'bins',length(1:ceil(maxAngle)));
binWidth = ceil(maxAngle) / numBins;
% Bin the data using the specified bin width and number of bins
[counts, binEdges] = histcounts(miso, 'BinWidth', binWidth, 'NumBins', numBins);
% Calculate the bin centers
binCenters = binEdges(1:end-1) + binWidth/2;
% Calculate the probability distribution function (PDF)
pdf = counts ./ (sum(counts) * binWidth);


figH = figure;
% Plot MTEX's default McKenzie distribution while scaling its y-axis data 
% to the number of orientations
h1 = plotAngleDistribution(CS,CS,'numBins',numBins);
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
