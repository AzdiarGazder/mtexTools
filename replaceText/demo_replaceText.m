% clear variables
clc; clear all; clear hidden; close all;

% start Mtex
startup_mtex;

% Assume we do not know the full path of the mtex folder on the computer
% Also assume we want to change a line in file "C:\~\mtex\geometry\@symmetry\symmetry.m" 
% Here "~" is the unknown part of the mtex folder path
% Since we are sure of the "\geometry\@symmetry\symmetry.m" part:
pName = what('geometry\@symmetry'); % finds the location of the required folder containing the file
pfName = [pName.path,'\symmetry.m']; % defines the full path & file name

% The following commands replace **the first instance** of the line:
% 'classdef symmetry < handle'
% with 
% 'classdef symmetry < matlab.mixin.Copyable'
replaceText(pfName, pfName, 'classdef symmetry < handle', 'classdef symmetry < matlab.mixin.Copyable');
replaceText(pfName, pfName, 'classdef symmetry < handle', 'classdef symmetry < matlab.mixin.Copyable','first');

% The following command replaces **all instances** of the line:
% 'classdef symmetry < handle'
% with 
% 'classdef symmetry < matlab.mixin.Copyable'
replaceText(pfName, pfName, 'classdef symmetry < handle', 'classdef symmetry < matlab.mixin.Copyable','all');
