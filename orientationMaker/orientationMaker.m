function orientationMaker(ori,sampleSymmetry,varargin)
%% Function description:
% Creates an ideal crystallographic orientation from a unimodal ODF with a
% user specified half-width and exports the data as a VPSC file for later
% use.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Modified by:
% Dr. Frank Niessen to include varargin.
%
%% Version(s):
% The first version of this function was posted in:
% https://github.com/ORTools4MTEX/ORTools/blob/develop/orientationMaker.m
%
%% Syntax:
%  fibreMaker(crystalDirection,specimenDirection)
%
%% Input:
%  ori                  - @orientation
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
sS = specimenSymmetry('triclinic');

% calculate a single orientation ODF with all symmetries
odf = unimodalODF(symmetrise(ori),'de la Vallee Poussin',...
    'halfwidth',hwidth,'Fourier',22);

% re-define the ODF specimen symmetry based on the user's specification
odf.SS = sampleSymmetry;

% save a VPSC *.tex file
export_VPSC(odf,pfName_Out,'interface','VPSC','Bunge','points',numPoints);
end

