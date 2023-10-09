%% Demonstration description:
% This script demonstrates how to plot user-defined pole figures and 
% orientation distribution function sections of common ideal orientations 
% for bcc materials.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  demo_idealOrientations_bcc
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
setMTEXpref('FontWeight','bold');
pfAnnotations = @(varargin) text([-vector3d.X,vector3d.Y],{'RD','TD'},...
  'BackgroundColor','w','tag','axesLabels',varargin{:});
setMTEXpref('pfAnnotations',pfAnnotations);


%% Define the crystal and specimen symmetry
CS = crystalSymmetry('SpaceId',229);
SS = specimenSymmetry('triclinic');


%% Define pole figures and ODF sections 
h = Miller({1,1,0},{2,0,0},{2,1,1},CS);
phi2Sections = [0,45,90].*degree;


% % Common ideal orientations for bcc materials:
% % (0 0 1)[1 -1 0]:        phi1 = 0;  PHI = 0;  phi2 = 45;
% % (1 1 4)[1 -1 0]:        phi1 = 0;  PHI = 19; phi2 = 45;
% % (1 1 2)[1 -1 0]:        phi1 = 0;  PHI = 35; phi2 = 45;
% % (2 2 3)[1 -1 0]:        phi1 = 0;  PHI = 43; phi2 = 45;
% % (1 1 1)[1 -1 0]:        phi1 = 0;  PHI = 55; phi2 = 45;
% % (3 3 2)[1 -1 0]:        phi1 = 0;  PHI = 65; phi2 = 45;
% % (2 2 1)[1 -1 0]:        phi1 = 0;  PHI = 71; phi2 = 45;
% % (1 1 0)[1 -1 0]:        phi1 = 0;  PHI = 90; phi2 = 45;
% % (1 1 3)[4 -7 1]:        phi1 = 17; PHI = 25; phi2 = 45;
% % (1 1 1)[1 -2 1]:        phi1 = 30; PHI = 55; phi2 = 45;
% % (0 0 1)[0 -1 0]:        phi1 = 45; PHI = 0;  phi2 = 45;
% % (1 1 1)[0 -1 1]:        phi1 = 60; PHI = 55; phi2 = 45;
% % (0 0 1)[-1 -1 0]:       phi1 = 90; PHI = 0;  phi2 = 45;
% % (1 1 1)[-1 -1 2]:       phi1 = 90; PHI = 55; phi2 = 45;
% % (5 5 4)[-2 -2 5]:       phi1 = 90; PHI = 61; phi2 = 45;
% % (1 1 0)[0 0 1]:         phi1 = 90; PHI = 90; phi2 = 45;

ori = orientation.byEuler(...
    [     0     0    45
     0    19    45
     0    35    45
     0    43    45
     0    55    45
     0    65    45
     0    71    45
     0    90    45
    17    25    45
    30    55    45
    45     0    45
    60    55    45
    90     0    45
    90    55    45
    90    61    45
    90    90    45].*degree,...
    CS,SS);

oriName = {'(0 0 1)[1 -1 0]',...
    '(0 0 1)[0 -1 0]',...
    '(0 0 1)[-1 -1 0]',...
    '(1 1 4)[1 -1 0]',...
    '(1 1 3)[4 -7 1]',...
    '(1 1 2)[1 -1 0]',...
    '(2 2 3)[1 -1 0]',...
    '(1 1 1)[1 -1 0]',...
    '(3 3 2)[1 -1 0]',...
    '(2 2 1)[1 -1 0]',...
    '(1 1 0)[1 -1 0]',...
    '(1 1 1)[1 -2 1]',...
    '(1 1 1)[0 -1 1]',...
    '(1 1 1)[-1 -1 2]',...
    '(5 5 4)[-2 -2 5]',...
    '(1 1 0)[0 0 1]'};
%%


%% Define the marker list (16)
markerList = {'o',...
'+',...
'*',...	
'square',...	
'diamond',...	
'^',...	
'v',...
'>',...	
'<',...	
'pentagram',...
'hexagram',...
'.'	,...
'x',...
'_',...	
'|',...
'o'};


%% Define the color list using a colormap
colorList = jet(length(markerList));

%% Define pole figures and ODF section options
pfOptions = {'MarkerEdgeColor','black','MarkerSize',20};
odfOptions = {'phi2',phi2Sections,'add2all','MarkerEdgeColor','black','maxphi1',pi/2,'MarkerSize',20};

%% Plot the pole figures and ODF sections
for ii = 1:length(ori)
figure(1)
plotPDF(ori(ii),h,'antipodal','MarkerColor',[colorList(ii,:)],'Marker',markerList{ii},pfOptions{:},'DisplayName',oriName{ii});
hold all;

figure(2)
plotSection(ori(ii),'MarkerColor',[colorList(ii,:)],'Marker',markerList{ii}, odfOptions{:},'DisplayName',oriName{ii});
hold all; 

end
figure(1); legend('Location','best');
figure(2); legend('Location','best');
figure(1); hold off;
figure(2); hold off;
setInterp2Tex;
