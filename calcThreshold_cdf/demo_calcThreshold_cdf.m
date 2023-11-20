clc; clear all; clear hidden; close all;

% Load a demonstration dataset
load("dataset.mat");
diameters = dataset(:,4); % grain feret diameter

out = calcThreshold_cdf(diameters,'scott','sigma',3)

