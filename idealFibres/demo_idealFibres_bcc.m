%% Demonstration description:
% This script demonstrates how to plot user-defined pole figures and 
% orientation distribution function sections of common ideal fibres 
% for bcc materials.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  demo_idealFibres_bcc
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
SS = specimenSymmetry('triclinic');


%% Define pole figures and ODF sections 
h = Miller({1,1,0},{2,0,0},{2,1,1},CS);
phi2Sections = [0,45,90].*degree;


%% Define the color list using a colormap
colorList = jet(8);


%% List of common ideal fibers for fcc materials
pfOptions = {'points','all','MarkerEdgeColor','none','MarkerSize',5,'silent'};
odfOptions = {'phi2',phi2Sections,'add2all','MarkerEdgeColor','none','MarkerSize',5,'silent'};

%% Alpha fibre = <1 1 0> || RD
% % Define a crystal direction
crystalDir = Miller({1,1,0},CS,'uvw');
% % Define a specimen direction 
specimenDir = RD;
ori = orientation(fibre(crystalDir,specimenDir,SS,'full'));

figure(1)
plotPDF(ori,h,'antipodal','MarkerColor',[colorList(1,:)],'Marker','o',pfOptions{:},'DisplayName','Alpha');
hold all;

figure(2)
ori.SS = specimenSymmetry('orthorhombic');
plotSection(ori,'MarkerColor',[colorList(1,:)],'Marker','o',odfOptions{:});
hold all;


%% Eta fibre = <1 0 0> || RD
% % Define a crystal direction
crystalDir = Miller({1,0,0},CS,'uvw');
% % Define a specimen direction 
specimenDir = RD;
ori = orientation(fibre(symmetrise(crystalDir),specimenDir,SS,'full'));

figure(1)
plotPDF(ori,h,'antipodal','MarkerColor',[colorList(2,:)],'Marker','o',pfOptions{:},'DisplayName','Eta');

figure(2)
ori.SS = specimenSymmetry('orthorhombic');
plotSection(ori,'MarkerColor',[colorList(2,:)],'Marker','o',odfOptions{:});


%% Epsilon fibre = <1 1 0> || TD
% % Define a crystal direction
crystalDir = Miller({1,1,0},CS,'uvw');
% % Define a specimen direction 
specimenDir = TD;
ori = orientation(fibre(crystalDir,specimenDir,SS,'full'));
figure(1)
plotPDF(ori,h,'antipodal','MarkerColor',[colorList(3,:)],'Marker','o',pfOptions{:},'DisplayName','Epsilon');

figure(2)
ori.SS = specimenSymmetry('orthorhombic');
plotSection(ori,'MarkerColor',[colorList(3,:)],'Marker','o',odfOptions{:});


%% Gamma fibre = <1 1 1> || ND
% % Define a crystal direction
crystalDir = Miller({1,1,1},CS,'uvw');
% % Define a specimen direction 
specimenDir = ND;
ori = orientation(fibre(crystalDir,specimenDir,SS,'full'));
figure(1)
plotPDF(ori,h,'antipodal','MarkerColor',[colorList(4,:)],'Marker','o',pfOptions{:},'DisplayName','Gamma');

figure(2)
ori.SS = specimenSymmetry('orthorhombic');
plotSection(ori,'MarkerColor',[colorList(4,:)],'Marker','o',odfOptions{:});


%% Gamma Prime fibre = <2 2 3> || ND
% % Define a crystal direction
crystalDir = Miller({2,2,3},CS,'uvw');
% % Define a specimen direction 
specimenDir = ND;
ori = orientation(fibre(crystalDir,specimenDir,SS,'full'));
figure(1)
plotPDF(ori,h,'antipodal','MarkerColor',[colorList(5,:)],'Marker','o',pfOptions{:},'DisplayName','Gamma''');

figure(2)
ori.SS = specimenSymmetry('orthorhombic');
plotSection(ori,'MarkerColor',[colorList(5,:)],'Marker','o',odfOptions{:});


%% Theta fibre = <1 0 0> || ND
% % Define a crystal direction
crystalDir = Miller({1,0,0},CS,'uvw');
% % Define a specimen direction 
specimenDir = ND;
ori = orientation(fibre(crystalDir,specimenDir,SS,'full'));
figure(1)
plotPDF(ori,h,'antipodal','MarkerColor',[colorList(6,:)],'Marker','o',pfOptions{:},'DisplayName','Theta');

figure(2)
ori.SS = specimenSymmetry('orthorhombic');
plotSection(ori,'MarkerColor',[colorList(6,:)],'Marker','o',odfOptions{:});


%% Zeta fibre = <1 1 0> || ND
% % Define a crystal direction
crystalDir = Miller({1,1,0},CS,'uvw');
% % Define a specimen direction 
specimenDir = ND;
ori = orientation(fibre(crystalDir,specimenDir,SS,'full'));
figure(1)
plotPDF(ori,h,'antipodal','MarkerColor',[colorList(7,:)],'Marker','o',pfOptions{:},'DisplayName','Zeta');

figure(2)
ori.SS = specimenSymmetry('orthorhombic');
plotSection(ori,'MarkerColor',[colorList(7,:)],'Marker','o',odfOptions{:});


%% {h 1 1} <1/h 1 2> -fibre
% % REF:  https://doi.org/10.1002/adem.201000075
% % Define a crystal direction
crystalDir = Miller({1,1,0},CS,'uvw');
% % Define a <110> sample direction tilted 20° from RD towards ND
rot = rotation('Euler',-20*degree,0*degree,0*degree);
specimenDir = rot * RD;
ori = orientation(fibre(symmetrise(crystalDir),specimenDir,SS,'full'));
figure(1)
plotPDF(ori,h,'antipodal','MarkerColor',[colorList(8,:)],'Marker','o',pfOptions{:},'DisplayName','Beta');

figure(2)
ori.SS = specimenSymmetry('orthorhombic');
plotSection(ori,'MarkerColor',[colorList(8,:)],'Marker','o',odfOptions{:});



figure(1); legend('Location','best');
figure(1); hold off;
figure(2); hold off;
setInterp2Tex;