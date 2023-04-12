function fibreMaker(crystalDirection,sampleDirection,sampleSymmetry,varargin)
%% Function description:
% Creates an ideal crystallographic fibre with a user specified
% half-width and exports the data as a lossless Mtex file for later use.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Modified by:
% Dr. Frank Niessen to include varargin.
%
%% Version(s):
% The first version of this function was posted in:
% https://github.com/ORTools4MTEX/ORTools/blob/develop/fibreMaker.m
%
%% Syntax:
%  fibreMaker(crystalDirection,samplenDirection,,sampleSymmetry)
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

% define the specimen symmetry to compute ODF
ss = specimenSymmetry('triclinic');

pfName_Out = get_option(varargin,'export','inputFibre.txt');

% pre-define the fibre
f = fibre(symmetrise(crystalDirection),sampleDirection,ss,'full');

% calculate a fibre ODF
odf = fibreODF(f,'halfwidth',hwidth);

% re-define the ODF specimen symmetry based on user specification
odf.SS = sampleSymmetry;

% find the current working directory
dataPath = [pwd,'\'];

% define the path and file name
pfname = fullfile(dataPath,pfName_Out);

% save an MTEX ASCII File *.txt file (lossless format)
export(odf,pfname,'Bunge');

end
