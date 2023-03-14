close all; clc; clear all; clear hidden;
startup_mtex

%% -----------------
% NOTES TO USERS
%% Common ideal orientations for fcc materials
% % Cube (C):              phi1 = 45; PHI = 0;  phi2 = 45;
% % Cube-RD (C_RD):        phi1 = 22; PHI = 0;  phi2 = 0;
% % Cube-ND (C_ND):        phi1 = 0;  PHI = 22; phi2 = 0;
% % Cube Twin (CT):        phi1 = 27; PHI = 48; phi2 = 27;
% % Rotated Cube (RtC):    phi1 = 0;  PHI = 0;  phi2 = 45;
% % Goss (G):              phi1 = 90; PHI = 90; phi2 = 45;
% % Rotated Goss (RtG):    phi1 = 0;  PHI = 90; phi2 = 45;
% % Goss Twin (GT):        phi1 = 90; PHI = 25; phi2 = 45;
% % Goss-Brass (GBr):      phi1 = 74; PHI = 90; phi2 = 45;
% % Brass (Br):            phi1 = 55; PHI = 90; phi2 = 45;
% % Copper (Cu):           phi1 = 90; PHI = 35; phi2 = 45;
% % Copper Twin (CuT):     phi1 = 90; PHI = 74; phi2 = 45;
% % Rotated Copper (RtCu): phi1 = 0;  PHI = 35; phi2 = 45;
% % A:                     phi1 = 35; PHI = 90; phi2 = 45;
% % S:                     phi1 = 59; PHI = 37; phi2 = 63;
% % F:                     phi1 = 30; PHI = 55; phi2 = 45;
% % E:                     phi1 = 0;  PHI = 55; phi2 = 45;


%% Common ideal orientations for bcc materials
% % (0 0 1)[1-1 0]:        phi1 = 0;  PHI = 0;  phi2 = 45;
% % (1 1 4)[1-1 0]:        phi1 = 0;  PHI = 19; phi2 = 45;
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
% % (0 0 1)[0-1 0]:        phi1 = 45; PHI = 0;  phi2 = 45;
% % (0 0 1)[-1-1 0]:       phi1 = 90; PHI = 0;  phi2 = 45;
% % (1 1 3)[4-7 1]:        phi1 = 17; PHI = 25; phi2 = 45;
%% ---------




%% UN-REMARK EACH SECTION AND RUN SEPARATELY
% % %-----------------
% % Example 1: Calculate the fcc Brass (Br) orientation
% % phi1 = 55; PHI = 90; phi2 = 45;
% %
% % step 1: Define a nominal fcc crystal system
% CS = crystalSymmetry('SpaceId', 225, [3.6 3.6 3.6], [90 90 90]*degree, 'mineral', 'copper');
% % step 2: Define an orientation
% ori = orientation.byEuler(55*degree,90*degree,45*degree,CS);
% % step 3: Define the sample symmetry
% sS = specimenSymmetry('orthorhombic');
% % step 4: Call the orientationMaker function
% orientationMaker(ori,sS,'halfwidth',2.5*degree,'points',1000,'export','fcc_Br.Tex')
% % step 5: Pre-define settings to plot the pole figure(s) & ODF of the
% % orientation 
% pfName = 'fcc_Br.Tex';
% hwidth = 2.5*degree;
% hpf = {Miller(1,1,1,CS),...
%   Miller(2,0,0,CS),...
%   Miller(2,2,0,CS)};
% pfColormap = colormap(hot);
% odfSections = [0 45 65]*degree;
% odfColormap = colormap(hot);
% % %-----------------



% %-----------------
% Example 2: Calculate the bcc (5 5 4)[-2-2 5] orientation
% phi1 = 90; PHI = 61; phi2 = 45;
%
% step 1: Define a nominal bcc crystal system
CS = crystalSymmetry('SpaceId', 229, [2.86 2.86 2.86], [90 90 90]*degree, 'mineral', 'iron'); 
% step 2: Define an orientation
ori = orientation.byEuler(90*degree,61*degree,45*degree,CS);
% step 3: Define the sample symmetry
sS = specimenSymmetry('orthorhombic');
% step 4: Call the orientationMaker function
orientationMaker(ori,sS,'halfwidth',2.5*degree,'points',1000,'export','bcc_554_-2-25.Tex')
% step 5: Pre-define settings to plot the pole figure(s) & ODF of the fibre
% using the data in the VPSC file
pfName = 'bcc_554_-2-25.Tex';
hwidth = 2.5*degree;
hpf = {Miller(1,1,0,CS),...
  Miller(2,0,0,CS),...
  Miller(2,1,1,CS)};
pfColormap = colormap(jet);
odfSections = [0 45 90]*degree;
odfColormap = colormap(jet);
% %-----------------
%%





%% DO NOT EDIT/MODIFY BELOW THIS LINE
% This is code common to Example 1 and 2 to visualise the VPSC file data
%
%--- Import the VPSC ODF file into memory
[ori,fileProp] = orientation.load(pfName,CS,sS,'interface','generic',...
    'ColumnNames', {'phi1' 'Phi' 'phi2' 'weights'}, 'Columns', [1 2 3 4], 'Bunge'); 
ori = ori(:);
wts = fileProp.weights; 
wts = wts(:);
%---

%--- Calculate the orientation distribution function and define the specimen symmetry of the parent
odf = calcDensity(ori,'weights',wts,'halfwidth',hwidth,'points','all');
%--- Re-define the specimen symmetry
odf.SS = specimenSymmetry('orthorhombic');
%--- Calculate the value and orientation of the maximum f(g) in the ODF
[maxodf_value,maxodf_ori] = max(odf);
%---

%--- Calculate the pole figures from the orientation distribution function 
pf = calcPoleFigure(odf,hpf,regularS2Grid('resolution',hwidth),'antipodal');
%--- Calculate the value of the maximum f(g) in the PF
maxpf_value = max(max(pf));
%---

%--- Plot the pole figures
figH = figure(1);
odf.SS = specimenSymmetry('triclinic');
plotPDF(odf,...
    hpf,...
    'points','all',...
    'equal','antipodal',...
    'contourf',1:ceil(maxpf_value));
pfColormap;
% flipud(pfColormap); % option to flip the colorbar
caxis([1 ceil(maxpf_value)]);
% colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
%     'YTick', [0:1:ceil(maxpf_value)],...
%     'YTickLabel',num2str([0:1:ceil(maxpf_value)]'), 'YLim', [0 ceil(maxpf_value)],...
%     'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
set(figH,'Name','Pole figure(s)','NumberTitle','on');
drawnow;
odf.SS = specimenSymmetry('orthorhombic');
%---

%--- Plot the orientation distribution function
figH = figure(2);
plotSection(odf,...
    'phi2',odfSections,...
    'points','all','equal',...
    'contourf',1:ceil(maxodf_value));    
odfColormap;
% flipud(odfColormap); % option to flip the colorbar
caxis([1 ceil(maxodf_value)]);
% colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
%     'YTick', [0:5:ceil(maxodf_value)],...
%     'YTickLabel',num2str([0:5:ceil(maxodf_value)]'), 'YLim', [0 ceil(maxodf_value)],...
%     'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
set(figH,'Name','Orientation distribution function (ODF)','NumberTitle','on');
odf.SS = specimenSymmetry('triclinic');
drawnow;
%---
%%