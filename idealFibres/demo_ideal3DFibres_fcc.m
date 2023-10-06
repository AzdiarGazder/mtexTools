%% Demonstration description:
% This script demonstrates how to plot the 3D orientation distribution 
% function of common ideal fibres for fcc materials.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  demo_ideal3DFibres_fcc
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
pfAnnotations = @(varargin) text([-vector3d.X,vector3d.Y],{'RD','TD'},...
  'BackgroundColor','w','tag','axesLabels',varargin{:});
setMTEXpref('pfAnnotations',pfAnnotations);


%% Define the crystal and specimen symmetry
CS = crystalSymmetry('SpaceId',225);
SS = specimenSymmetry('orthorhombic');


%% Define pole figures and ODF sections 
h = Miller({1,1,1},{2,0,0},{2,2,0},CS);
phi2Sections = [0,45,65].*degree;


%% Define the color list using a colormap
colorList = jet(5);


%% List of common ideal fibers for fcc materials
odfOptions = {'add2all','maxphi1',pi/2,'silent'};

%% Alpha fibre = <1 1 0> || ND
% % Define a crystal direction
crystalDir = Miller({1,1,0},CS,'uvw');
% % Define a specimen direction 
specimenDir = ND;
f = (fibre(crystalDir,specimenDir,SS,'full'));

% ori1 = orientation.byMiller([0 0 1],[1 1 0],CS,SS);
% ori2 = orientation.byMiller([1 1 1],[1 1 0],CS,SS);
% f = fibre(ori1,ori2,'full');

figure(1)
plot(f,'LineColor',[colorList(1,:)],'LineWidth',5,odfOptions{:},'DisplayName','Alpha');
grid on;
box on;
hold all;


%% Beta fibre = <1 1 0> tilted 60° from ND towards TD
% % % Define a crystal direction
% crystalDir = Miller({1,1,0},CS,'uvw');
% % % Define a sample direction tilted 60° from ND towards TD
% rot = rotation('Euler',90*degree,60*degree,0*degree);
% specimenDir = rot * ND;
% f = fibre(symmetrise(crystalDir),specimenDir,SS,'full');

ori1 = orientation.byMiller([1 1 2],[1 1 0],CS,SS);
ori2 = orientation.byMiller([11 11 8],[4 4 11],CS,SS);
f = fibre(ori1,ori2,'full');

plot(f,'LineColor',[colorList(2,:)],'LineWidth',5,odfOptions{:},'DisplayName','Beta');


%% Gamma fibre = <1 1 1> || ND
% % Define a crystal direction
crystalDir = Miller({1,1,1},CS,'uvw');
% % Define a specimen direction 
specimenDir = ND;
f = fibre(crystalDir,specimenDir,SS,'full');

plot(f,'LineColor',[colorList(3,:)],'LineWidth',5,odfOptions{:},'DisplayName','Gamma');


%% Tau fibre = <1 1 0> || TD
% % Define a crystal direction
crystalDir = Miller({1,1,0},CS,'uvw');
% % Define a specimen direction 
specimenDir = TD;
f = fibre(crystalDir,specimenDir,SS,'full');

plot(f,'LineColor',[colorList(4,:)],'LineWidth',5,odfOptions{:},'DisplayName','Tau');


%% Theta fibre = <0 0 1> || ND
% % REF: https://doi.org/10.1016/j.actamat.2011.05.050
% % Define a crystal direction
crystalDir = Miller({0,0,1},CS,'uvw');
% % Define a specimen direction 
specimenDir = ND;
f = fibre(crystalDir,specimenDir,SS,'full');

plot(f,'LineColor',[colorList(5,:)],'LineWidth',5,odfOptions{:},'DisplayName','Theta');
hold off;

legend('Location','best');
setInterp2Tex;