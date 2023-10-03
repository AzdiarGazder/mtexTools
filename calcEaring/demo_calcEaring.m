%% Initialise Mtex
close all; clc; clear all; clear hidden;
startup_mtex


%% Define the Mtex plotting convention
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outofPlane');
setMTEXpref('maxSO3Bandwidth',92);

%% Load an mtex dataset
mtexdata ferrite
CS = ebsd.CS;


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

%% Plot the data
figure
plot(ebsd,ebsd.orientations);
hold all
plot(grains.boundary,'lineWidth',2);
hold off


%% Define bcc slip system(s)
b1 = Miller(1,1,-1,CS,'uvw'); % slip direction
n1 = Miller(1,-1,0,CS,'hkl'); % slip plane normal
sS1 = slipSystem(b1,n1);

b2 = Miller(1,1,-1,CS,'uvw'); % slip direction
n2 = Miller(1,1,2,CS,'hkl'); % slip plane normal
sS2 = slipSystem(b2,n2);

b3 = Miller(1,1,1,CS,'uvw'); % slip direction
n3 = Miller(1,2,-3,CS,'hkl'); % slip plane normal
sS3 = slipSystem(b3,n3);

sS = [sS1, sS2, sS3];

prop.miu0 = 0.05;            % Value ranges from 0 to 0.1 for rolling textures
prop.n = 1;                  % Value equal to 0.1 for rolling textures
prop.UTS = 250;              % Ultimate tensile strength (in MPa)
% prop.YS = XXX;               % Yield stress (in MPa)
% prop.k = 0.025;
prop.radiusBlank = 40;       % Radius of blank (Rb, in mm)
prop.radiusDie = 20;         % Radius of die (Rd, in mm)
prop.radiusPunch = 19;       % Radius of punch (Rp, in mm)
prop.radiusPunchProfile = 4; % Radius of punch profile (rp, in mm)
prop.thicknessBlank = 0.8;   % Thickness of blank (t0, in mm)


% h = calcEaring(ebsd,sS, prop);
h = calcEaring(ebsd,sS, prop,'discrete');
% h = calcEaring(grains,sS, prop);

figure
plot(linspace(0,360,73),h,'-r','lineWidth',1.5);
axis tight
xlabel('Angle to RD (degrees)');
ylabel('Cup height (mm)');

