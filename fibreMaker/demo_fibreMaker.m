close all; clc; clear all; clear hidden;
startup_mtex

%% -----------------
% NOTES TO USERS
% % List of common fibers for fcc materials:
% % alpha             -fibre = <1 1 0> || ND
% % beta              -fibre = <1 1 0> tilted 60° from ND towards TD
% % gamma             -fibre = <1 1 1> || ND
% % tau               -fibre = <1 1 0> || TD
% % REF: https://doi.org/10.1016/j.actamat.2011.05.050
% % theta-fibre = <001> || ND


% List of common fibers for bcc materials:
% % alpha             -fibre = <1 1 0> || RD
% % eta               -fibre = <1 0 0> || RD
% % epsilon           -fibre = <1 1 0> || TD
% % gamma             -fibre = <1 1 1> || ND
% % gammaPrime        -fibre = <2 2 3> || ND
% % theta             -fibre = <1 0 0> || ND
% % zeta              -fibre = <1 1 0> || ND
% % {h 1 1} <1/h 1 2> -fibre
% % REF:  https://doi.org/10.1002/adem.201000075
% %  Notes: This fibre can be simplified as a nominal bcc alpha-fibre
% % whose <110> is tilted 20° from RD towards ND


% List of common fibres for hcp materials:
% % <0 0 0 1>         -fibre = <0 0 0 1>  || ND
% % <1 1 -2 0>        -fibre = <1 1 -2 0> || RD
% % <1 0 -1 0>        -fibre = <1 0 -1 0> || ND
% % hkil              -fibre = <0 0 0 1> tilted 20° from ND towards RD
%% ---------

% step 1: The definition of the commmon fibres listed above is based on the
% following fixed specimen coordinate system of sample directions
% parallel to the crystallographic directions:
RD = xvector; TD = yvector; ND = zvector;



%% UN-REMARK EACH SECTION AND RUN SEPARATELY
% % %-----------------
% % Example 1: Calculate the fcc beta fibre
% %
% % This fibre can be simplified as <110> directions tilted 60° from ND
% % towards TD
% %
% % step 2: Define a nominal fcc crystal system
% CS = crystalSymmetry('SpaceId', 225, [3.6 3.6 3.6], [90 90 90]*degree, 'mineral', 'copper');
% % step 3: Define a crystallographic direction
% cD = Miller({1,1,0},CS,'uvw');
% % step 4: Define a sample direction tilted 60° from ND towards TD
% rotN = rotation('Euler',90*degree,60*degree,0*degree);
% sD = rotN * ND;
% % step 5: Define the sample symmetry
% sS = specimenSymmetry('orthorhombic');
% % step 6: Call the fibreMaker function
% fibreMaker(cD,sD,sS,'halfwidth',5*degree,'export','fcc_beta.txt')
% 
% % step 7: Pre-define settings to plot the pole figure(s) & ODF of the fibre
% pfName = 'fcc_beta.txt';
% hwidth = 5*degree;
% hpf = {Miller(1,1,1,CS),...
%     Miller(2,0,0,CS),...
%     Miller(2,2,0,CS)};
% pfColormap = flipud(colormap(hot));
% odfSections = [0 45 65]*degree;
% odfColormap = flipud(colormap(hot));
% % %-----------------



% %-----------------
% Example 2: Calculate the bcc {h 1 1} <1/h 1 2> fibre
%
% This fibre can be simplified as a nominal bcc alpha -fibre
% whose <110> is tilted 20° from RD towards ND
%
% step 2: Define a nominal bcc crystal system
CS = crystalSymmetry('SpaceId', 229, [2.86 2.86 2.86], [90 90 90]*degree, 'mineral', 'iron');
% step 3: Define a crystallographic direction
cD = Miller({1,1,1},CS,'uvw');
% cD = Miller({1,1,0},CS,'uvw');
% step 4: Define a tilt away a specimen co-ordinate system direction
% rotN = rotation('Euler',-20*degree,0*degree,0*degree);
% sD = rotN * RD;
sD = ND;
% step 5: Define the sample symmetry
sS = specimenSymmetry('orthorhombic');
% step 6: Call the fibreMaker function
% pfName = 'bcc_h11_1byh12.txt';
pfName = 'bcc_gammaFibre.txt';
fibreMaker(cD,sD,sS,'halfwidth',5*degree,'export',pfName)

% step 7: Pre-define settings to plot the pole figure(s) & ODF of the fibre
hwidth = 5*degree;
hpf = {Miller(1,1,0,CS),...
  Miller(2,0,0,CS),...
  Miller(2,1,1,CS)};
pfColormap = colormap(jet);
odfSections = [0 45 90]*degree;
odfColormap = colormap(jet);
% %-----------------
%%





%% DO NOT EDIT/MODIFY BELOW THIS LINE
setInterp2Latex;
% check for MTEX version
currentVersion = 5.9;
fid = fopen('VERSION','r');
MTEXversion = fgetl(fid);
fclose(fid);
MTEXversion = str2double(MTEXversion(5:end-2));

if MTEXversion >= currentVersion % for MTEX versions 5.9.0 and above
    %--- Load the texture file as an ODF
    odf = SO3Fun.load(pfName,'CS',CS,'resolution',hwidth,'Bunge',...
        'ColumnNames',{'Euler 1','Euler 2','Euler 3','weights'});

else % for MTEX versions 5.8.2 and below
    %--- Load the texture file as discrete orientations
    [ori,~] = orientation.load(pfName,CS,sS,'interface','generic',...
        'ColumnNames', {'phi1' 'Phi' 'phi2'}, 'Columns', [1 2 3], 'Bunge');
    ori = ori(:);
    %--- Calculate the orientation distribution function and define the specimen symmetry of the parent
    odf = calcDensity(ori,'halfwidth',hwidth,'points','all');
end

%--- Re-define the specimen symmetry
odf.SS = specimenSymmetry('orthorhombic');
%--- Calculate the value and orientation of the maximum f(g) in the ODF
% [maxodf_value,~] = max(odf);
% odf = odf.*(100/maxodf_value); % scale ODF to maximum f(g) = 100
[maxodf_value,maxodf_ori] = max(odf);
maxodf_value = round(maxodf_value/5)*5;
%---

%--- Calculate the pole figures from the orientation distribution function
pf = calcPoleFigure(odf,hpf,regularS2Grid('resolution',hwidth),'antipodal');
%--- Calculate the value of the maximum f(g) in the PF
maxpf_value = max(max(pf));
maxpf_value = round(maxpf_value/5)*5;
%---

%--- Plot the pole figures
figH = figure(1);
odf.SS = specimenSymmetry('triclinic');
plotPDF(odf,...
    hpf,...
    'points','all',...
    'equal','antipodal',...
    'contourf',1:ceil(maxpf_value/10):maxpf_value);
colormap(pfColormap);
caxis([1 maxpf_value]);
colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
    'YTick', [1:ceil(maxpf_value/10):maxpf_value],...
    'YTickLabel',num2str([1:ceil(maxpf_value/10):maxpf_value]'), 'YLim', [1 maxpf_value],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
set(figH,'Name','Pole figure(s)','NumberTitle','on');
drawnow;
odf.SS = specimenSymmetry('orthorhombic');
%---

%--- Plot the orientation distribution function
figH = figure(2);
plotSection(odf,...
    'phi2',odfSections,...
    'points','all','equal',...
    'contourf',1:ceil(maxodf_value/10):maxodf_value);
colormap(odfColormap);
caxis([1 maxodf_value]);
colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
    'YTick', [1:ceil(maxodf_value/10):maxodf_value],...
    'YTickLabel',num2str([1:ceil(maxodf_value/10):maxodf_value]'), 'YLim', [1 maxodf_value],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
setColorRange('equal') % set equal color range for all subplots
set(figH,'Name','Orientation distribution function (ODF)','NumberTitle','on');
odf.SS = specimenSymmetry('triclinic');
drawnow;
%---
% setInterp2Tex;
%%