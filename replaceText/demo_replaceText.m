%% Function description:
% In this example, the replaceText function permanently edits a line in 
% the MTEX in-built function "...\mtex\geometry\@symmetry\symmetry.m".
% The edit enables users to copy crystal symmetries. This ability is 
% especially useful when working on phase segmentation and phase 
% transformation analysis.
%
% USER NOTES:
% Given this is a working example, This file only needs to be run once. 
% The replaceText function can be adapted to other uses.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Input:
%  none
%
%% Output:
%  none
%
%%


% Assume the full path to the mtex folder on the computer is unknown such 
% that if the path is "C:\~\mtex\...", the "~" signifies the unknown part.

% We want to change a line in file "C:\~\mtex\geometry\@symmetry\symmetry.m" 
% Since the "\geometry\@symmetry\symmetry.m" part of the path is known:
pName = what('geometry\@symmetry'); % finds the location of the required folder (containing the file)
pfName = [pName.path,'\symmetry.m']; % defines the full path & file name


% The following are the 2 methods to use the replaceText function:
%% Method 1
% The following commands replace **the first instance** of the line:
% 'classdef symmetry < handle'
% with 
% 'classdef symmetry < matlab.mixin.Copyable'
% replaceText(pfName, pfName, 'classdef symmetry < handle', 'classdef symmetry < matlab.mixin.Copyable');
replaceText(pfName, pfName, 'classdef symmetry < handle', 'classdef symmetry < matlab.mixin.Copyable','first');
%%


%% Method 2
% The following command replaces **all instances** of the line:
% 'classdef symmetry < handle'
% with 
% 'classdef symmetry < matlab.mixin.Copyable'
replaceText(pfName, pfName, 'classdef symmetry < handle', 'classdef symmetry < matlab.mixin.Copyable','all');
%%