clc; clear all; clear hidden; close all;

%% DEMO SET #1
% Load a demonstration dataset
load("grainSize.mat");

% Threshold the PDF
out = calcThreshold(grainSize_rcrx,'pdf','binWidth',0.01,'sigma',3)
out.x(out.id)


%% DEMO SET #2
% Load a demonstration dataset
load("dataset.mat");
diameters = dataset(:,4); % grain feret diameter

% Threshold the cumulative distribution function (CDF)
out = calcThreshold(diameters,'scott','sigma',3)
% which is equivalent to
%  out = calcThreshold(diameters,'cdf','scott','sigma',3)

% Threshold the CDF differential
out = calcThreshold(diameters,'dcdf','binWidth',10,'sigma',3)
