function fibreMaker(crystalDirection,sampleDirection,sampleSymmetry,varargin)
%% Function description:
% This function creates an ideal crystallographic fibre with a user 
% specified half-width and exports the data as a lossless MATLAB *.mat 
% file object for later use.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
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
%  export       - (optional path and) name of the file


hwidth = get_option(varargin,'halfwidth',2.5*degree);
pfName_Out = get_option(varargin,'export','inputFibre.mat');

%% define the specimen symmetry to compute ODF
ss = specimenSymmetry('triclinic');

% check for MTEX version
chkVersion = '5.9.0';
chkVerParts = getVersionParts(chkVersion);
fid = fopen('VERSION','r');
curVersion = fgetl(fid);
fclose(fid);
curVersion = erase(curVersion, 'MTEX ');
curVerParts = getVersionParts(curVersion);

if curVerParts(1) ~= chkVerParts(1)     % major version
    flagVersion = curVerParts(1) < chkVerParts(1);
elseif curVerParts(2) ~= chkVerParts(2) % minor version
    flagVersion = curVerParts(2) < chkVerParts(2);
else                                    % revision version
    flagVersion = curVerParts(3) < chkVerParts(3);
end


%%
if flagVersion == 0 % for MTEX versions 5.9.0 and above
    % pre-define the fibre
    f = fibre(crystalDirection,sampleDirection,ss,'full');
    % calculate a fibre ODF
    odf = fibreODF(f,'halfwidth',hwidth);

    %%
elseif flagVersion == 1 % for MTEX versions 5.8.2 and below
    % calculate a fibre ODF
    odf = fibreODF(symmetrise(crystalDirection),sampleDirection,ss,'de la Vallee Poussin',...
        'halfwidth',hwidth,'Fourier',22);
end

% re-define the ODF specimen symmetry based on user specification
odf.SS = sampleSymmetry;

%% save the odf as a *.mat file object (lossless format)
fiberODF = odf;
save(pfName_Out,"fiberODF");

end


function parts = getVersionParts(V)

parts = sscanf(V, '%d.%d.%d')';

if length(parts) < 3
    parts(3) = 0; % zero-fills to 3 elements
end

end
