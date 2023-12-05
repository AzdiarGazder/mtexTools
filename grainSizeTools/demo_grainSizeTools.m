%% Toolbox description
% GrainSizeTools is a free, open-source, cross-platform script written in 
% Python and maintained by Dr Marco A. Lopez-Sanchez. 
%
% This toolbox replicates the data analysis and plots in GrainSizeTools 
% for a MATLAB and MTEX -based environmment by providing tools for:
% (1) describing and visualising grain size populations, and
% (2) applying stereology methods to approximate the 3D distribution of 
%     grain size from thin sections. 
%
%% Acknowledgements:
% Dr. Marco A. Lopez-Sanchez              - GrainSizeTools
% Drs. Dorian Depriester and Régis Kubler - automatic-Saltykov
% MATLAB file exchange                   - shapiroWilk and hatchFill
%
%% Repository locations:
% GrainSizeTools     - https://github.com/marcoalopez/GrainSizeTools
% automatic-Saltykov - https://github.com/DorianDepriester/automatic-Saltykov
% shapiroWilk        - https://au.mathworks.com/matlabcentral/fileexchange/13964-shapiro-wilk-and-shapiro-francia-normality-tests
% hatchFill          - https://au.mathworks.com/matlabcentral/fileexchange/53593-hatchfill2
%
%%


clc; clear all; clear hidden; close all;
currentFolder;

% Load a demonstration dataset
load("dataset.mat");
% Note: Minimum requirement = an array of grain diameters and grain areas

area = dataset(:,2); % grain area
diameters = dataset(:,4); % grain feret diameter

grainStatistics(diameters)

% Plot the distribution of grain diameters
plot_distr(diameters);

% Plot an area-weighted histogram of a grain diameters
plot_wtdArea(diameters, area);

% Plot the lognormal distribution test using a quantile–quantile (q-q) 
% plot and a Shapiro-Wilk test
plot_qq(diameters);

% Plot the log-transformed normalised distribution  of grain diameters
plot_normDistr(diameters,area);

% Find the best parameters for performing the Saltykov method by 
% minimising the Cramer-von Mises (CvM) goodness-of-fit criterion. 
out = autoSaltykov(diameters);

% Plot two figures:
% Figure 1: % the data histogram based on Saltykov's optimal number of bins
% and best-fit lognormal distribution (two-step method)
%
% Figure 2: Two sub-plots after applying the Saltykov method of: 
% (2.1) a bar plot of Saltykov frequency versus grain size, and
% (2.2) a line plot of Saltykov volume-weighted cumulative frequency.
plot_saltykov(diameters, out);
