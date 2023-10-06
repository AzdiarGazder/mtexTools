%% Demonstration description:
% This script demonstrates how to plot the 3D orientation distribution 
% function of common ideal fibres for bcc materials.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  demo_ideal3DFibres_bcc
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

%% Define specimen directions
% The definition of the commmon orientations and fibres is based on the 
% following fixed specimen coordinate system of sample directions
% parallel to the crystallographic directions:
RD = xvector; TD = yvector; ND = zvector;


%% Define the Mtex plotting convention
setInterp2Latex;
setMTEXpref('xAxisDirection','north');
setMTEXpref('zAxisDirection','intoPlane');
setMTEXpref('FontSize',20);
setMTEXpref('FontWeight', 'bold');
pfAnnotations = @(varargin) text([vector3d.X,vector3d.Y],{'RD','TD'},...
  'BackgroundColor','w','tag','axesLabels',varargin{:});
setMTEXpref('pfAnnotations',pfAnnotations);


%% Define the crystal and specimen symmetry
CS = crystalSymmetry('SpaceId',229);
SS = specimenSymmetry('orthorhombic');


%% Define the color list using a colormap
colorList = jet(8);


%% List of common ideal fibers for bcc materials
odfOptions = {'add2all','maxphi1',pi/2,'silent'};

%% Alpha fibre = <1 1 0> || RD
% % Define a crystal direction
crystalDir = Miller({1,1,0},CS,'uvw');
% % Define a specimen direction 
specimenDir = RD;
f = fibre(crystalDir,specimenDir,SS,'full');

figure(1)
plot(f,'LineColor',[colorList(1,:)],'LineWidth',5,odfOptions{:},'DisplayName','Alpha');
grid on;
box on;
hold all;


%% Eta fibre = <1 0 0> || RD
% % Define a crystal direction
crystalDir = Miller({1,0,0},CS,'uvw');
% % Define a specimen direction 
specimenDir = RD;
f = fibre(symmetrise(crystalDir),specimenDir,SS,'full');
plot(f,'LineColor',[colorList(2,:)],'LineWidth',5,odfOptions{:},'DisplayName','Eta');


%% Epsilon fibre = <1 1 0> || TD
% % Define a crystal direction
crystalDir = Miller({1,1,0},CS,'uvw');
% % Define a specimen direction 
specimenDir = TD;
f = fibre(crystalDir,specimenDir,SS,'full');
plot(f,'LineColor',[colorList(3,:)],'LineWidth',5,odfOptions{:},'DisplayName','Epsilon');


%% Gamma fibre = <1 1 1> || ND
% % Define a crystal direction
crystalDir = Miller({1,1,1},CS,'uvw');
% % Define a specimen direction 
specimenDir = ND;
f = fibre(crystalDir,specimenDir,SS,'full');
plot(f,'LineColor',[colorList(4,:)],'LineWidth',5,odfOptions{:},'DisplayName','Gamma');


%% Gamma Prime fibre = <2 2 3> || ND
% % Define a crystal direction
crystalDir = Miller({2,2,3},CS,'uvw');
% % Define a specimen direction 
specimenDir = ND;
f = fibre(crystalDir,specimenDir,SS,'full');
plot(f,'LineColor',[colorList(5,:)],'LineWidth',5,odfOptions{:},'DisplayName','Gamma''');


%% Theta fibre = <1 0 0> || ND
% % Define a crystal direction
crystalDir = Miller({1,0,0},CS,'uvw');
% % Define a specimen direction 
specimenDir = ND;
f = fibre(crystalDir,specimenDir,SS,'full');
plot(f,'LineColor',[colorList(6,:)],'LineWidth',5,odfOptions{:},'DisplayName','Theta');


%% Zeta fibre = <1 1 0> || ND
% % Define a crystal direction
crystalDir = Miller({1,1,0},CS,'uvw');
% % Define a specimen direction 
specimenDir = ND;
f = fibre(crystalDir,specimenDir,SS,'full');
plot(f,'LineColor',[colorList(7,:)],'LineWidth',5,odfOptions{:},'DisplayName','Zeta');


%% {h 1 1} <1/h 1 2> -fibre
% % REF:  https://doi.org/10.1002/adem.201000075
% % Define a crystal direction
crystalDir = Miller({1,1,0},CS,'uvw');
% % Define a <110> sample direction tilted 20° from RD towards ND
rot = rotation('Euler',-20*degree,0*degree,0*degree);
specimenDir = rot * RD;
f = fibre(symmetrise(crystalDir),specimenDir,SS,'full');
plot(f,'LineColor',[colorList(8,:)],'LineWidth',5,odfOptions{:},'DisplayName','Beta');
hold off;


legend('Location','best');
setInterp2Tex;
