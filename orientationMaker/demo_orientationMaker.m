close all; clc; clear all; clear hidden;
startup_mtex

%% -----------------
% NOTES TO USERS
% % Common ideal orientations for fcc materials:
% % Cube-RD (C_RD):        phi1 = 22; PHI = 0;  phi2 = 0;
% % Cube-ND (C_ND):        phi1 = 0;  PHI = 22; phi2 = 0;
% % Cube (C):              phi1 = 45; PHI = 0;  phi2 = 45;
% % Cube Twin (CT):        phi1 = 27; PHI = 48; phi2 = 27;
% % Rotated Cube (RtC):    phi1 = 0;  PHI = 0;  phi2 = 45;
% % Goss Twin (GT):        phi1 = 90; PHI = 25; phi2 = 45;
% % Rotated Copper (RtCu): phi1 = 0;  PHI = 35; phi2 = 45;
% % Copper (Cu):           phi1 = 90; PHI = 35; phi2 = 45;
% % E:                     phi1 = 0;  PHI = 55; phi2 = 45;
% % F:                     phi1 = 30; PHI = 55; phi2 = 45;
% % Rotated Goss (RtG):    phi1 = 0;  PHI = 90; phi2 = 45;
% % A:                     phi1 = 35; PHI = 90; phi2 = 45;
% % Goss-Brass (GBr):      phi1 = 74; PHI = 90; phi2 = 45;
% % Brass (Br):            phi1 = 55; PHI = 90; phi2 = 45;
% % Goss (G):              phi1 = 90; PHI = 90; phi2 = 45;
% % Copper Twin (CuT):     phi1 = 90; PHI = 74; phi2 = 45;
% % S:                     phi1 = 59; PHI = 37; phi2 = 63;




% % Common ideal orientations for bcc materials:
% % (0 0 1)[1-1 0]:        phi1 = 0;  PHI = 0;  phi2 = 45;
% % (0 0 1)[0-1 0]:        phi1 = 45; PHI = 0;  phi2 = 45;
% % (0 0 1)[-1-1 0]:       phi1 = 90; PHI = 0;  phi2 = 45;
% % (1 1 4)[1-1 0]:        phi1 = 0;  PHI = 19; phi2 = 45;
% % (1 1 3)[4-7 1]:        phi1 = 17; PHI = 25; phi2 = 45;
% % (1 1 2)[1-1 0]:        phi1 = 0;  PHI = 35; phi2 = 45;
% % (2 2 3)[1-1 0]:        phi1 = 0;  PHI = 43; phi2 = 45;
% % (1 1 1)[1-1 0]:        phi1 = 0;  PHI = 55; phi2 = 45;
% % (3 3 2)[1-1 0]:        phi1 = 0;  PHI = 65; phi2 = 45;
% % (2 2 1)[1-1 0]:        phi1 = 0;  PHI = 71; phi2 = 45;
% % (1 1 0)[1-1 0]:        phi1 = 0;  PHI = 90; phi2 = 45;
% % (1 1 1)[1-2 1]:        phi1 = 30; PHI = 55; phi2 = 45;
% % (1 1 1)[0-1 1]:        phi1 = 60; PHI = 55; phi2 = 45;
% % (1 1 1)[-1-1 2]:       phi1 = 90; PHI = 55; phi2 = 45;
% % (5 5 4)[-2-2 5]:       phi1 = 90; PHI = 61; phi2 = 45;
% % (1 1 0)[0 0 1]:        phi1 = 90; PHI = 90; phi2 = 45;
%% ---------




%% UN-REMARK EACH SECTION AND RUN SEPARATELY
% %-----------------
% Example 1: Calculate the fcc Brass (Br) orientation
% phi1 = 55; PHI = 90; phi2 = 45;
%
% step 1: Define a nominal fcc crystal system
CS = crystalSymmetry('SpaceId', 225, [3.6 3.6 3.6], [90 90 90]*degree, 'mineral', 'copper');
% step 2: Define an orientation
ori = orientation.byEuler(35*degree,90*degree,45*degree,CS);
% step 3: Define the sample symmetry
sS = specimenSymmetry('orthorhombic');
% step 4: Define a half-width
hwidth = 2.5*degree;
% step 5: Define a file name
pfName = 'fcc_A.txt';
% step 6: Call the orientationMaker function
orientationMaker(ori,sS,'halfwidth',hwidth,'export',pfName);
% %-----------------



% % %-----------------
% % Example 2: Calculate the bcc (5 5 4)[-2-2 5] orientation
% % phi1 = 90; PHI = 61; phi2 = 45;
% %
% % step 1: Define a nominal bcc crystal system
% CS = crystalSymmetry('SpaceId', 229, [2.86 2.86 2.86], [90 90 90]*degree, 'mineral', 'iron'); 
% % step 2: Define an orientation
% ori = orientation.byEuler(90*degree,61*degree,45*degree,CS);
% % step 3: Define the sample symmetry
% sS = specimenSymmetry('orthorhombic');
% % step 4: Define a half-width
% hwidth = 2.5*degree;
% % step 5: Define a file name
% pfName = 'bcc_554_-2-25.txt';
% % step 6: Call the orientationMaker function
% orientationMaker(ori,sS,'halfwidth',hwidth,'export',pfName);
% % %-----------------
%%





%% DO NOT EDIT/MODIFY BELOW THIS LINE
setInterp2Latex;

% % This is code common to Example 1 and 2 to visualise the *.txt or *.Tex 
% % file data
% Load the texture file
[ori,~] = orientation.load(pfName,CS,sS,'interface','generic',...
    'ColumnNames', {'phi1' 'Phi' 'phi2'}, 'Columns', [1 2 3], 'Bunge');

% Calculate the orientation distribution function and define the specimen symmetry of the parent
odf = calcDensity(ori,'halfwidth',hwidth,'points','all');
% [maxodf_value,~] = max(odf);
% odf = odf.*(100/maxodf_value); % scale ODF to maximum f(g) = 100

% Plot the pole figures
hpf = {Miller(1,1,1,odf.CS),Miller(2,0,0,odf.CS), Miller(2,2,0,odf.CS)};
% hpf = {Miller(1,1,0,odf.CS),Miller(2,0,0,odf.CS), Miller(2,1,1,odf.CS)};
plotHPF(odf,hpf,specimenSymmetry('triclinic'),'stepSize',10,'colormap',flipud(hot));

% Plot the orientation distribution function
plotHODF(odf,specimenSymmetry('orthorhombic'),'sections',[0 45 90]*degree,'stepSize',100,'colormap',flipud(hot));

setInterp2Tex;
%%