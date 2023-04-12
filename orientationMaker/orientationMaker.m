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
%  orientationMaker(ori,sampleSymmetry)
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

% define the specimen symmetry to compute ODF
sS = specimenSymmetry('triclinic');

% calculate a single orientation ODF with all symmetries
% check for MTEX version
currentVersion = 5.9;
fid = fopen('VERSION','r');
MTEXversion = fgetl(fid);
fclose(fid);
MTEXversion = str2double(MTEXversion(5:end-2));

if MTEXversion >= currentVersion % for MTEX versions 5.9.0 and above
    pfName_Out = get_option(varargin,'export','inputOrN.txt');

    psi = SO3vonMisesFisherKernel('halfwidth',1.225*hwidth);
    % calculate a unimodal ODF
    odf = unimodalODF(symmetrise(oriIn),psi);
    % discretise the ODF based on user specification
    oriOut = discreteSample(odf,numPoints);
    % save an MTEX ASCII File *.txt file (lossless format)
    export(oriOut,pfName_Out,'Bunge','interface','mtex');

%     psi = SO3DeLaValleePoussinKernel('halfwidth',hwidth);
%     SO3F = SO3FunRBF(symmetrise(ori),psi);
%     % re-define the ODF specimen symmetry based on the user specification
%     SO3F.center.SS = sampleSymmetry;
%     % discretise the ODF based on user specification
%     ori = discreteSample(SO3F.center,numPoints);
%     % save an MTEX ASCII File *.txt file (lossless format)
%     export(ori,pfName_Out,'Bunge','interface','mtex');

%     % save a VPSC *.tex file
%     export_VPSC(SO3F.center,pfName_Out,'interface','VPSC','Bunge','points',numPoints);

else % for MTEX versions 5.8.2 and below
    pfName_Out = get_option(varargin,'export','inputOrN.Tex');

    % calculate a unimodal ODF
    odf = unimodalODF(symmetrise(ori),'de la Vallee Poussin',...
        'halfwidth',hwidth,'Fourier',22);
    % re-define the ODF specimen symmetry based on the user specification
    odf.SS = sampleSymmetry;
    % save a VPSC *.Tex file (lossy format)
    export_VPSC(odf,pfName_Out,'interface','VPSC','Bunge','points',numPoints);
end

end

