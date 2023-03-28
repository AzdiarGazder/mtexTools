close all; clc; clear all; clear hidden;

%% UN-REMARK EACH SECTION BELOW AND RUN SEPARATELY
% %-----------------
% % define a binary map
% colmax = 25; romax = 100; 
% inMap = ones(randi([1,colmax],1,1), randi([1,romax],1,1));
% size(inMap)
% 
% % plot the input map
% figure; imagesc(inMap); colorbar; caxis([0 1]); 
% xlim([1 colmax]); ylim([1 romax]); 
% title('Input map')
% 
% % pad the map
% outMap = autoPad(inMap,1,'zeros');
% size(outMap)
% 
% % plot the padded map
% figure; imagesc(outMap); colorbar; caxis([0 1]); 
% % xlim([1 100]); ylim([1 50]);
% title('Padded map')
% %-----------------



%-----------------
% define a binary map
colmax = 25; romax = 100; 
inMap = zeros(randi([1,colmax],1,1), randi([1,romax],1,1));
size(inMap)

% plot the input map
figure; imagesc(inMap); colorbar; caxis([0 1]); 
xlim([1 colmax]); ylim([1 romax]); 
title('Input map')

% pad the map
outMap = autoPad(inMap,1,'ones');
size(outMap)

% plot the padded map
figure; imagesc(outMap); colorbar; caxis([0 1]); 
% xlim([1 100]); ylim([1 50]);
title('Padded map')
%-----------------
