%% Demonstration description:
% This script demonstrates tetxure evolution of copper during uniaxial
% tension via Taylor modelling.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  demo_taylorModel
%
%% Input:
%  none
%
%% Output:
%  none
%
%% Options:
%  none
%%


%% Initialise Mtex
close all; clc; clear all; clear hidden;
startup_mtex


%% Define the Mtex plotting convention
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','intoPlane');
pfAnnotations = @(varargin) text([-vector3d.X,vector3d.Y],{'Tension','TD'},...
  'BackgroundColor','w','tag','axesLabels',varargin{:});
setMTEXpref('pfAnnotations',pfAnnotations);

%% Load an mtex dataset
% mtexdata twins
mtexdata copper

%% Define the crystal system and specimen symmetry
CS = ebsd.CS;
SS = specimenSymmetry('orthorhombic');


%% Calculate the grains
% identify grains
disp('---')
disp('Identifying grains...')
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',5*degree);
disp('Done!')
disp('---')
% remove small clusters
disp('Deleting small grain clusters...')
ebsd(grains(grains.grainSize <= 5)) = [];
disp('Done!')
disp('---')
% recalculate the grains
disp('Re-calculating grains...')
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',5*degree);
disp('Done!')
disp('---')
ori = grains.meanOrientation;


%% Plot the data
figure
plot(grains,ori);
hold all
plot(grains.boundary,'lineWidth',2);
hold off




%% Define fcc slip system(s)
% sS = [slipSystem.basal(CS,1),...
%   slipSystem.prismatic2A(CS,66),...
%   slipSystem.pyramidalCA(CS,80),...
%   slipSystem.twinC1(CS,100)];

b = Miller(1,-1,0,CS,'uvw'); % slip direction
n = Miller(1,1,-1,CS,'hkl'); % slip plane normal
sS1 = slipSystem(b,n,50)
b = Miller(1,1,2,CS,'uvw'); % slip direction
n = Miller(1,1,-1,CS,'hkl'); % slip plane normal
sS2 = slipSystem(b,n,100)
sS = [sS1, sS2];


%% Define strain tensors
rhoRange = linspace(0,1,11); % 0% to 100% uniaxial tension
strainTensor_sRF = strainTensor(zeros(3,3,length(rhoRange))); % define an empty strain tensor in the specimen reference frame (sRF)
strainTensor_sRF.M(1,1,:) = 1;
strainTensor_sRF.M(2,2,:) = -rhoRange;
strainTensor_sRF.M(3,3,:) = -(1 - rhoRange);


%% Apply the Taylor model
for ii = 1:length(rhoRange)
    % Transform the strain tensor from the specimen reference frame
    % (sRF) to the crystal reference frame (xRF)
    strainTensor_xRF = inv(ori) .* strainTensor_sRF(ii);
    [~,tempbb,tempW] = calcTaylor(strainTensor_xRF,sS,'silent');
    bb{ii} = tempbb;
    W{ii} = tempW;

    % Apply the Taylor spin to the initial orientations
    oriEvolve(:,ii) = ori .* orientation(-tempW);

    progress(ii,length(rhoRange));
end


%% Plot the data
figure
plot(grains,oriEvolve(:,end));
hold all
plot(grains.boundary,'lineWidth',2);
hold off


figure;
h = Miller({1,1,1},{2,0,0},{2,2,0},CS);
% h = Miller({0,0,0,1},{1,0,-1,0},{1,0,-1,1},CS);
plotPDF(ori,h,'antipodal','contourf','grid','grid_res',30*degree)
mtexColorbar;

nextAxis %create a new axis on the existing figure and put along side
plotPDF(oriEvolve(:,end),h,'antipodal','contourf','grid','grid_res',30*degree)
mtexColorbar;

% get figure handle and set correct layout
mtexFig = gcm;
mtexFig.layoutMode = 'user';
mtexFig.nrows = 2; 
mtexFig.ncols = 3; 
drawNow(gcm)




