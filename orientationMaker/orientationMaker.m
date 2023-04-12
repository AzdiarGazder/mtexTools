function orientationMaker2(oriIn,sampleSymmetry,varargin)
%% Function description:
% Creates an ideal crystallographic orientation from a unimodal ODF with a
% user specified half-width and exports the data as a lossless Mtex
% (version 5.9 onwards) or lossy VPSC (up to version 5.8.2) file for
% later use.
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
%  orientationMaker(ori,sampleSymmetry)
%
%% Input:
%  oriIn                - @orientation
%  sampleSymmetry       - @specimenSymmetry
%
%% Options:
%  halfwidth    - halfwidth for the ODF calculation
%  points       - number of points (discrete orientations) in the VPSC file
%  export       - (optional path) and name of the VPSC file
%%

hwidth = get_option(varargin,'halfwidth',2.5*degree);
numPoints = get_option(varargin,'points',1000);

% define the specimen symmetry to compute ODF
sS = specimenSymmetry('triclinic');

% calculate a single orientation ODF with all symmetries
pfName_Out = get_option(varargin,'export','inputOrN.txt');

% calculate a unimodal ODF
odf = unimodalODF(symmetrise(oriIn),'halfwidth',hwidth);

% re-define the ODF specimen symmetry based on the user specification
odf.SS = sampleSymmetry;

% generate the user specified number of orientations from the ODF
oriOut = odf.discreteSample(numPoints);

% save an MTEX ASCII File *.txt file (lossless format)
export(oriOut,pfName_Out,'Bunge','interface','mtex');

% % save a VPSC *.Tex file (lossy format)
% export_VPSC(odf,pfName_Out,'interface','VPSC','Bunge','points',numPoints);

end

