%% Initialise Mtex
close all; clc; clear all; clear hidden;
startup_mtex


%% Define the Mtex plotting convention
setMTEXpref('xAxisDirection','north');
setMTEXpref('zAxisDirection','intoPlane');
setMTEXpref('maxSO3Bandwidth',100);


%% Define the crystal systems of the phases in the ebsd map
CS = {...
    'notIndexed',...
    crystalSymmetry('SpaceId',225,[3.7 3.7 3.7],'mineral','Iron fcc','color',[0 0 1]),...
    crystalSymmetry('SpaceId',229,[2.9 2.9 2.9],'mineral','Iron bcc (old)','color',[1 0 0]),...
    crystalSymmetry('SpaceId',191,[2.5 2.5 4.1],'X||a*', 'Y||b', 'Z||c*','mineral','Epsilon_Martensite','color',[1 1 0])};


%% Import the EBSD map data
% directory path
pname = 'C:\Users\azdiar\Documents\MATLAB\GitHub\mtexTools\calcModelTexture\';
% file name
fname = 'MEA_60CR_1C.ctf';
% create an EBSD variable containing the map data
ebsd = EBSD.load([pname fname],CS,'interface','ctf',...
    'convertSpatial2EulerReferenceFrame');
% use only indexed map data
ebsd = ebsd('indexed');
% in case of multi-phase maps, select the dominant phase to work with
ebsd = ebsd('Iron fcc');

% From Steps 1 & 3: One combination of phi1, Phi and phi2 that exactly
% matches the crystallographic texture displayed in OI Channel-5 or Aztec
% Crystal.
phi1 = 180*degree;
Phi = 0*degree;
phi2 = 0*degree;
ebsdRot = rotate(ebsd,rotation('Euler', phi1, Phi, phi2),'keepXY');

% From Step 2: spatially rotate the ebsd map WITHOUT disturbing the ebsd
% map orientation data. The user must specify the spatial rotations needed
% to enable Mtex to display the EBSD map data in a spatial format that
% exactly matches OI Channel-5 or Aztec Crystal.
rot1 = rotation.byAxisAngle(zvector,90*degree);
rot2 = rotation.byAxisAngle(yvector,180*degree);

ebsdRot = rotate(ebsdRot,rot1,'keepEuler');
ebsdRot = rotate(ebsdRot,rot2,'keepEuler');


%% Plot the ebsd orientation data to check if it matches Channel-5 or Aztec
ipfKey = ipfColorKey(ebsdRot);
% set the referece direction to X
ipfKey.inversePoleFigureDirection = vector3d.X;
% compute the colors
colors = ipfKey.orientation2color(ebsdRot.orientations);
% plot the ebsd data together with the colors
figH = figure;
plot(ebsdRot,colors);


%% Calculate and plot the experimental PFs and ODF sections
% Calculate the optimal kernel size
psi = calcKernel(ebsdRot.orientations,'method','ruleOfThumb');

% Calculate the experimental orientation distribution function
expODF = calcDensity(ebsdRot.orientations,'de la Vallee Poussin','kernel',psi);

% Plot the experimental pole figures
hpf = {Miller(1,1,1,expODF.CS),Miller(2,0,0,expODF.CS), Miller(2,2,0,expODF.CS)};
plotHPF(expODF,hpf,specimenSymmetry('triclinic'),'stepSize',2,'colormap',flipud(gray));

% Plot the experimental orientation distribution function
plotHODF(expODF,specimenSymmetry('orthorhombic'),'sections',[0:5:90]*degree,'stepSize',5,'colormap',flipud(gray));



%% Create a list of ideal orientations from which the model ODF will be
% calculated
% % Cube (C):              phi1 = 0;  PHI = 0;  phi2 = 0; **
% % Cube-RD (C_RD):        phi1 = 22; PHI = 0;  phi2 = 0;
% % Rotated Cube (RtC):    phi1 = 45; PHI = 0;  phi2 = 0;
% % Cube-ND (C_ND):        phi1 = 0;  PHI = 22; phi2 = 0; **
% % Goss (G):              phi1 = 0;  PHI = 45; phi2 = 0; **
% % Goss-Brass (GBr):      phi1 = 15; PHI = 45; phi2 = 0;
% % Brass (Br):            phi1 = 35; PHI = 45; phi2 = 0;
% % A:                     phi1 = 55; PHI = 45; phi2 = 0;
% % Rotated Goss (RtG):    phi1 = 90; PHI = 45; phi2 = 0;
% % ---
% % Cube Twin (CT):        phi1 = 27; PHI = 48; phi2 = 27;
% % ---
% % Goss Twin (GT):        phi1 = 90; PHI = 25; phi2 = 45;
% % Rotated Copper (RtCu): phi1 = 0;  PHI = 35; phi2 = 45; **
% % Copper (Cu):           phi1 = 90; PHI = 35; phi2 = 45;
% % E:                     phi1 = 0;  PHI = 55; phi2 = 45; **
% % F:                     phi1 = 30; PHI = 55; phi2 = 45;
% % Copper Twin (CuT):     phi1 = 90; PHI = 74; phi2 = 45;
% % ---
% % S:                     phi1 = 59; PHI = 37; phi2 = 63;
% % ---
eA = [360  0  0;...
    22 0  0;...
    45 0  0;...
    360  22 0;...
    360  45 0;...
    15 45 0;...
    35 45 0;...
    55 45 0;...
    90 45 0;...
    27 48 27;...
    90 25 45;...
    360  35 45;...
    90 35 45;...
    360  55 45;...
    30 55 45;...
    90 74 45;...
    59 37 63];
ori = orientation.byEuler(eA.*degree,expODF.CS);


%% Create a model ODF from the list of ideal orientations
[modelODF,modes,vol] = calcModelTexture(expODF,ori,psi);


%% Plot the model PFs and ODF sections
% Plot the model pole figures
hpf = {Miller(1,1,1,modelODF.CS),Miller(2,0,0,modelODF.CS), Miller(2,2,0,modelODF.CS)};
plotHPF(modelODF,hpf,specimenSymmetry('triclinic'),'stepSize',2,'colormap',jet);

% Plot the model orientation distribution function
plotHODF(modelODF,specimenSymmetry('orthorhombic'),'sections',[0:5:90]*degree,'stepSize',5,'colormap',jet);


%% Calculate the statisitics for comparison
% Define the ODF specimen symmetries
expODF.SS = specimenSymmetry('triclinic');
modelODF.SS = specimenSymmetry('triclinic');
% calculate the texture index of the experimental texture
T_exp = sqrt(mean(abs(expODF).^2));
% calculate the texture index of the model texture
T_mod = sqrt(mean(abs(modelODF).^2));
% calculate the texture difference between experimental and model textures
Td = sqrt(mean((abs(modelODF)-abs(expODF)).^2));
% calculate the normalised texture difference between experimental and model textures
Td_hat = Td/T_exp;
disp('-----------')
disp(['Texture index (Experiment)    = ',num2str(T_exp)]);
disp(['Texture index (Model)         = ',num2str(T_mod)]);
disp(['Difference index              = ',num2str(Td)]);
disp(['Normalised difference index   = ',num2str(Td_hat)]);
disp('-----------')

% save an MTEX ASCII File *.txt file
pfName_Out = 'modelTexture.txt';
export(modelODF,pfName_Out,'Bunge','MTEX');
return
%---



%---
% Import and plot the saved *.txt file
importODF = ODF.load('modelTexture.txt',...
    'CS',CS{2},...
    'SS',specimenSymmetry('triclinic'),...
    'interface','generic',...
    'resolution',psi.halfwidth,...
    'ColumnNames',{'Euler 1','Euler 2','Euler 3','weights'},...
    'Columns', [1 2 3 4],...
    'Bunge');

% Plot the imported pole figures
hpf = {Miller(1,1,1,importODF.CS),Miller(2,0,0,importODF.CS), Miller(2,2,0,importODF.CS)};
plotHPF(importODF,hpf,specimenSymmetry('triclinic'),'stepSize',2,'colormap',jet);

% Plot the imported orientation distribution function
plotHODF(importODF,specimenSymmetry('orthorhombic'),'sections',[0:5:90]*degree,'stepSize',5,'colormap',jet);
%---



%---
% Output unique modes versus possible ideal orientations in a table
[m,~,id2] = unique(modes,'tolerance',2*psi.halfwidth);
v = accumarray(id2,vol);

ori = ori(:);
miso = zeros(length(m),length(ori));
for ii = 1:length(m)
    for jj = 1:length(ori)
        miso(ii,jj) = min(angle(m(ii),symmetrise(ori(jj))))./degree;
    end
end
[minVal,minIdx] = min(miso,[],2);
mm = [1:length(m)]';
disp(table(mm,v,minIdx,minVal,'VariableNames',{'uniqueModes_index','uniqueModes_volFrac','idealOrN_index','min_misoAngle'}));
%---



%---
% Plot which ideal orientations the unique modes correspond to
[m,~,id2] = unique(modes,'tolerance',2*psi.halfwidth);
v = accumarray(id2,vol);

cmap = jet(length(m));
figure(3);
hold all;
for ii = 1:length(m)
    [keyCode,~] = getKey(1); % wait for user input
    if keyCode == 27 % ascii code if the escape key is presssed
        return % exit the loop
    else % continue the loop
        annotate(m(ii),...
            'marker','s','MarkerSize',12,'MarkerFaceColor',cmap(ii,:));
    end
end
hold off;
%---
