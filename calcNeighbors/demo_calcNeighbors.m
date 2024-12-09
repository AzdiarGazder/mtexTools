clc; close all

% Load a sample EBSD dataset
mtexdata twins silent
CS = ebsd('indexed').CS;

% Reconstruct grains
[grains, ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',5*degree);
grains = smooth(grains,5);

% Calculate grain boundary pairs
pairs = grains.neighbors;

%% Calculate the first-order neighbours of grain 74
neighbors = calcNeighbors(74, pairs, 'order', 1,'include')

% Highlight the neighbours of grain 74
plot(grains,grains.meanOrientation); % plot all grains
hold all
text(grains,int2str(grains.id)); % grain Id
plot(grains(neighbors).boundary,'LineWidth',4,'linecolor','b'); % neighbour grains
plot(grains(74).boundary,'LineWidth',4,'linecolor','w'); % grain of interest
hold off
%%



%% Calculate the neighbours of all grains
% Number of grains
numGrains = length(grains);

% Pre-allocate a cell array for storing neighbours of each grain
allNeighbours = cell(numGrains, 1);

% Loop through each grain and compute its neighbours
for ii = 1:numGrains
    % Get the grain Id
    grainId = grains(ii).id;
    % Calculate only the third-order neighbours of the current grain
    allNeighbours{ii} = calcNeighbors(grainId, pairs, 'order',3,'exclude');
end
%%