function currentFolder
%% Function description:
% Change MATLAB's current folder to the folder containing this function and 
% add all of its sub-folders to the work path.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Version(s):
% The first version of this function was posted in:
% https://github.com/ORTools4MTEX/ORTools/blob/develop/currentFolder.m
%
%% Syntax:
%  currentFolder
%%

if(~isdeployed)
    folder = fileparts(mfilename('fullpath'));
    cd(folder);
    % Add the current folder plus all of its subfolders to the work path
    addpath(genpath(folder));
end