close all; clc; clear all; clear hidden;

%-----------------
% define a binary map
colmax = 100; romax = 100; 
inMap = zeros(randi([1,colmax],1,1), randi([1,romax],1,1));
size(inMap)

% plot the input map
figure; imagesc(inMap); colorbar; caxis([0 1]); 
% xlim([1 colmax]); ylim([1 romax]); %axis tight
title('Input map')

% pad the map
%% UN-REMARK EACH COMMAND IN THIS SECTION AND RUN SEPARATELY
% outMap = pad(inMap,'size',[0 5],'ones');
outMap = pad(inMap,'square','ones');
% outMap = pad(inMap,'auto','ones');
%%
size(outMap)


% plot the padded map
figure; imagesc(outMap); colorbar; caxis([0 1]); 
% xlim([1 100]); ylim([1 50]);
title('Padded map')
%-----------------