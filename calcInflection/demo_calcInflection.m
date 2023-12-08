clc; clear all; clear hidden; close all;

% Load a demonstration dataset
load("dataset.mat");
diameters = dataset.feretDiameter; % grain feret diameter

% Calculate the inflection points of the cumulative distribution function (CDF)
out = calcInflection(diameters)

out = calcInflection(diameters,'binWidth',5,'min',0,'max',ceil(max(diameters)))