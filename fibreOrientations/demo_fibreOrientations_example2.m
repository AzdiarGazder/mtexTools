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


%% Define the fcc beta fibre
fBeta = fibre.beta(CS,SS,'full');
oriBeta = orientation(fBeta,CS,SS,'points',73) % list of fibre orientations


%% Define the preferences for plotting crystallographic texture
% define the pole figures to display
hpf = {Miller(1,1,1,CS),...
    Miller(2,0,0,CS),...
    Miller(2,2,0,CS)};
% define the ODF sections to display
odfSections = [0 45 65]*degree;


%% Plot the pole figures
figH = figure(6);
oriBeta.SS = specimenSymmetry('triclinic');
plotPDF(oriBeta,...
    hpf,...
    'points','all',...
     'MarkerFaceColor','orange','MarkerSize',5);
hold all;
set(figH,'Name','Pole figure(s)','NumberTitle','on');
hold off;
drawnow;
oriBeta.SS = specimenSymmetry('orthorhombic');
%---


%% Plot the orientation distribution function
figH = figure(7);
plotSection(oriBeta,...
    'phi2',odfSections,...
     'MarkerFaceColor','orange','MarkerSize',5);
hold all;
set(figH,'Name','Orientation distribution function (ODF)','NumberTitle','on');
hold off;
drawnow;
%---


%% Plot the inverse pole figures
figH = figure(8);
r = [vector3d(1,0,0),vector3d(0,1,0),vector3d(0,0,1)];
plotIPDF(oriBeta,r,...
        'points','all',...
     'MarkerFaceColor','orange','MarkerSize',5);
hold all;
set(figH,'Name','Inverse pole figure(s) (IPF)','NumberTitle','on');
hold off;
drawnow;
%---