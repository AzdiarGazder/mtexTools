close all; clc; clear all; clear hidden;

%% UN-REMARK EACH SECTION BELOW AND RUN SEPARATELY
%-----------------
% define a binary map
inMap = ones(randi([1,100],1,1), randi([1,50],1,1));
size(inMap)
tiledlayout(1,2);

% LHS plot
nexttile;
imagesc(inMap); colorbar; caxis([0 1]);
title('Input map')

% pad the map
outMap = pad(inMap,[4 1],'zeros');
size(outMap)

% RHS plot
nexttile;
imagesc(outMap); colorbar; caxis([0 1]);
title('Padded map')
%-----------------


% %-----------------
% % define a binary map
% inMap = zeros(randi([1,100],1,1), randi([1,50],1,1));
% size(inMap)
% tiledlayout(1,2);
% 
% % LHS plot
% nexttile;
% imagesc(inMap); colorbar; caxis([0 1]);
% title('Input map')
% 
% % pad the map
% outMap = pad(inMap,[3 1],'ones');
% size(outMap)
% 
% % RHS plot
% nexttile;
% imagesc(outMap); colorbar; caxis([0 1]);
% title('Padded map')
% %-----------------
