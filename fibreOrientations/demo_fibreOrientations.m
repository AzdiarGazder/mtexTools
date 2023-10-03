%% Demonstration description:
% This script demonstrates how to obtain and plot orientations from a 
% crystallographic fibre.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  demo_fibreOrientations
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
setMTEXpref('xAxisDirection','north');
setMTEXpref('zAxisDirection','intoPlane');


%% Define the crystal system and specimen symmetry
CS = crystalSymmetry('SpaceId',225,[3.7 3.7 3.7],'mineral','Iron fcc','color',[0 0 1]);
SS = specimenSymmetry('orthorhombic');


%% Define the fcc alpha fibre
o1Alpha = orientation.byEuler([0 45 0].*degree,CS,SS);  % Goss
o2Alpha = orientation.byEuler([90 45 0].*degree,CS,SS); % Rt-Goss
fAlpha = fibre(o1Alpha,o2Alpha,CS,SS,'full');
oriAlpha = orientation(fAlpha,CS,SS); % list of fibre orientations


%% Define the preferences for plotting crystallographic texture
% define the pole figures to display
hpf = {Miller(1,1,1,CS),...
    Miller(2,0,0,CS),...
    Miller(2,2,0,CS)};
% define the ODF sections to display
odfSections = [0 45 65]*degree;


%% Plot the pole figures
figH = figure(1);
oriAlpha.SS = specimenSymmetry('triclinic');
plotPDF(oriAlpha,...
    hpf,...
    'points','all',...
     'MarkerFaceColor','orange','MarkerSize',5);
hold all;
plotPDF(o1Alpha.symmetrise,...
    hpf,...
    'points','all',...
     'MarkerFaceColor','red','MarkerSize',15);
plotPDF(o2Alpha.symmetrise,...
    hpf,...
    'points','all',...
     'MarkerFaceColor','blue','MarkerSize',15);
set(figH,'Name','Pole figure(s)','NumberTitle','on');
hold off;
drawnow;
oriAlpha.SS = specimenSymmetry('orthorhombic');
%---


%% Plot the orientation distribution function
figH = figure(2);
plotSection(oriAlpha,...
    'phi2',odfSections,...
     'MarkerFaceColor','orange','MarkerSize',5);
hold all;
plotSection(o1Alpha,...
    'phi2',odfSections,...
    'MarkerFaceColor','red','MarkerSize',15);
plotSection(o2Alpha,...
    'phi2',odfSections,...
    'MarkerFaceColor','blue','MarkerSize',15);
set(figH,'Name','Orientation distribution function (ODF)','NumberTitle','on');
hold off;
drawnow;
%---


%% Plot the inverse pole figures
figH = figure(3);
r = [vector3d(1,0,0),vector3d(0,1,0),vector3d(0,0,1)];
plotIPDF(oriAlpha,r,...
        'points','all',...
     'MarkerFaceColor','orange','MarkerSize',5);
hold all;
plotIPDF(o1Alpha.symmetrise,...
    'points','all',...
    'MarkerFaceColor','red','MarkerSize',15);
plotIPDF(o2Alpha.symmetrise,...
    'points','all',...
    'MarkerFaceColor','blue','MarkerSize',15);
set(figH,'Name','Inverse pole figure(s) (IPF)','NumberTitle','on');
hold off;
drawnow;
%---