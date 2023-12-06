clc; clear all; clear hidden; close all;

% Load a demonstration dataset
load("dataset.mat");
% Note: Minimum requirement = an array of grain diameters and grain areas

area = dataset(:,2); % grain area
diameters = dataset(:,4); % grain feret diameter

% Plot default
figure;
plotHeatScatter(diameters,area);


% Plot equilateral triangles with marker edge color
figure;
plotHeatScatter(diameters,area,'marker','e','markerEdgeColor',[0 0 0]);


% Plot hexagons with zeros
figure;
plotHeatScatter(diameters,area,'marker','h','showZeros',1);

