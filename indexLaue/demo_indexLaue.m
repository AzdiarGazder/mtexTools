%% Demonstration description:
% This script demonstrates how to index a Laue micro-diffraction pattern 
% in MTEX.
%
%% Modified by:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements:
% TBA
% 
%% Syntax:
%  demo_indexLaue
%
%% Input:
%  none
%
%% Output:
% Figure comprising the indexed Laue micro-diffraction pattern for a
% reflection
%
%% Options:
%  none
%
%%


% Clear variables
close all; clc; clear all; clear hidden;

% Initialise MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('FontSize', 16);

%% Define the hcp crystal symmetry
% In this example, alpha Titanium
CS = crystalSymmetry('6/mmm',[2.95, 2.95, 4.68],'X||a*', 'Y||b', 'Z||c*');

%% Define an orientation
ori = orientation.byEuler([0 0 0].*degree,CS);

%% Define the Miller indices of the reflection (or peak)
% In this example, (4, -5, 1, 4)
m = Miller(4,-5,1,4, 'hkil', CS);

%% Define the slip system(s)
sS = [slipSystem.basal(CS),...
    slipSystem.prismaticA(CS),...
    slipSystem.pyramidalA(CS),...
    slipSystem.pyramidalCA(CS)];





%% DO NOT EDIT BELOW THIS LINE
% Calculate the c/a ratio of the crystal symmetry
caRatio = CS.axes.z(3)/CS.axes.x(1);


% Convert the orientation to a rotation matrix
g = ori.matrix;


% Symmetrise the slip system(s)
for ii = 1: length(sS)
    sSLengths(ii) = length(symmetrise(sS(ii)));
end
sS = symmetrise(sS);


% Convert slip systems to cartesian coordinates
nsS = [sS.n.h, (2.*sS.n.k + sS.n.h)./ sqrt(3), sS.n.l./ caRatio];
msS = [1.5.* sS.b.U, (sqrt(3)/2).* (2.*sS.b.V + sS.b.U), sS.b.W.* caRatio];
mag_nsS = sqrt(nsS(:,1).^2 + nsS(:,2).^2 + nsS(:,3).^2);
mag_msS = sqrt(msS(:,1).^2 + msS(:,2).^2 + msS(:,3).^2);
nsS = nsS./mag_nsS; % normalised plane normal vector
msS = msS./mag_msS; % normalised slip direction vector


% Convert the peak to cartesian coordinates
% rot = vector3d(m);
rot = [m.h, (2*m.k + m.h) / sqrt(3), m.l/caRatio];
mag_rot = sqrt(rot(:,1).^2 + rot(:,2).^2 + rot(:,3).^2);
rot = rot./mag_rot;


% Define the lattice rotation tensor in the dislocation coordinate system
% x -> b, y -> n, z -> t
p = 1;
rotEdge = [0 -p 0;...
    p 0 0;...
    0 0 0];

rotScrew = [0 p/2 p/2;...
    -p/2 0 -p/2;...
    -p/2 p/2 0];

rotPeak = (g' * rot')';

for ii = 1:length(nsS)
    rot_b(ii,:) = (g' * [msS(ii,1); msS(ii,2); msS(ii,3)])'; % Burgers vector in the crystal coordinate system
    rot_n(ii,:) = (g' * [nsS(ii,1); nsS(ii,2); nsS(ii,3)])'; % Slip plane normal in the crystal coordinate system
    rot_t(ii,:) = cross(rot_b(ii,:), rot_n(ii,:)); % Dislocation line direction
    tMatrix(:,:) = [rot_b(ii,:); rot_n(ii,:); rot_t(ii,:)]; % Transformation matrix

    % Nye tensor for edge dislocations on ii'th slip system
    labEdge(:,:) = tMatrix' * rotEdge * tMatrix;
    % Nye tensor for screw dislocations on ii'th slip system
    labScrew(:,:) = tMatrix' * rotScrew * tMatrix;
    
    % Calculate the peak streak direction (?) for edge or screw dislocations
    ita(ii,:) = (labEdge(:,:) * rotPeak')';
    % ita(j,:) = (labScrew(:,:) * rotPeak')';
end


% Convert ? into the "CCD coordinate system" and plot
for ii = 1:length(nsS)
    ita(ii,:) = ita(ii,:) * [1 0 0;...
        0 1/sqrt(2) -1/sqrt(2);...
        0 1/sqrt(2) 1/sqrt(2)];
    Ita(ii,:) = cross(ita(ii,:), rot_n(length(nsS),:)); % project ? to the CCD screen
    xIta(ii) = Ita(ii,1); % x component of the streak
    yIta(ii) = Ita(ii,2); % y component of the streak

    if ii <= sSLengths(1) % for basal slip systems
        lineType = 'k-o';
    elseif ii > sSLengths(1) && ii <= sum(sSLengths(1:end-2)) % for prismatic slip systems
        lineType = 'r--o';
    elseif ii > sum(sSLengths(1:end-2)) && ii <= sum(sSLengths(1:end-1)) % for pyramidalA slip systems
        lineType = 'g-.o';
    elseif ii > sum(sSLengths(1:end-1)) && ii <= sum(sSLengths(1:end)) % for pyramidalCA slip systems
        lineType = 'b:o';
    end

    plot([0, xIta(ii)], [0, yIta(ii)],lineType,'lineWidth', 1.5);
    hold all;
    text(xIta(ii), yIta(ii), int2str(ii), 'fontSize', 16); % label slip system number
end

% axis ([-1,1,-1,1])
title(['Reflection (',...
    num2str(m.h),' '...
    num2str(m.k),' '...
    num2str(m.i),' '...
    num2str(m.l),')'], 'Fontsize', 16); % display the Miller indices of the reflection as the figure title
%%