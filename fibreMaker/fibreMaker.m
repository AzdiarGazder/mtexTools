function fibreMaker(crystalDirection,sampleDirection,sampleSymmetry,varargin)
%% Function description:
% Creates an ideal crystallographic fibre with a user specified 
% half-width and exports the data as a VPSC file for later use.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Version(s):
% The first version of this function was posted in:
% https://github.com/ORTools4MTEX/ORTools/blob/develop/fibreMaker.m
%
%% Syntax:
%  fibreMaker(crystalDirection,specimenDirection)
%
%% Input:
%  crystalDirection     - @Miller
%  sampleDirection      - @vector3d
%  sampleSymmetry       - @specimenSymmetry
%  
%% Options:
%  halfwidth    - halfwidth for the ODF calculation
%  points       - number of points (discrete orientations) in the VPSC file
%  export       - (optional path) and name of the VPSC file
%%

hwidth = get_option(varargin,'halfwidth',2.5*degree);
numPoints = get_option(varargin,'points',1000);
pfName_Out = get_option(varargin,'export','inputVPSC.Tex');

% define the specimen symmetry to compute ODF
ss = specimenSymmetry('triclinic');

% calculate a fibre ODF
odf = fibreODF(crystalDirection,sampleDirection,ss,'de la Vallee Poussin',...
    'halfwidth',hwidth,'Fourier',22);

% re-define the ODF specimen symmetry based on the user's specification
odf.SS = sampleSymmetry;

% save a VPSC *.tex file
export_VPSC(odf,pfName_Out,'interface','VPSC','Bunge','points',numPoints);
end