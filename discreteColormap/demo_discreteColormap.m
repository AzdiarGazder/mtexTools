close all; clc; clear all; clear hidden;

% visualise the default color palette of the colormap
figure(1)
% define a colormap to use
cmap = colormap('jet');
colorbar;



% visualise a discreted color palette of the colormap
figure(2)
% sub-divide a colormap into a user specified number of discrete colors
% cmap = discreteColormap(cmap,5);
cmap = discreteColormap(colormap('jet'),5);
% define the discretised colormap
colormap(cmap);
colorbar;



% visualise a discreted color palette of the colormap
figure(3)
% define the discretised colormap by sub-dividing a default colormap into 
% a user specified number of discrete colors
colormap(discreteColormap(jet,5));
colorbar;
