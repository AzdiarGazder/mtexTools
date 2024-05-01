function gam = GAM(ebsd,varargin)
%% Function description:
% By modifying MTEX's in-built KAM script, this function calculates the 
% intragranular grain average misorientation. The first neighbour kernal 
% average misorientation is averaged to return a single value per grain.
%
%% Modified by:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements: 
% Dr. Rüdiger Killian
% For the commands to compute the grain-based GAM at:
% https://groups.google.com/g/mtexmail/c/x1oFYjh0Des
%
%% Version(s):
% This is a modification of MTEX's in-built KAM scipt located at:
% ~\mtex\EBSDAnalysis\@EBSD
%
% This function also uses the following MTEX scripts in unmodified form:
% spatialDecomposition.m & generateUnitCells.m located at
% ~\mtex\EBSDAnalysis\@EBSD\private
%
%% Syntax:
% plot(ebsd,ebsd.GAM./degree)
%
% % ignore misorientation angles > threshold
% gam = GAM(ebsd,'threshold',10*degree);
% plot(ebsd,gam./degree)
%
% % ignore grain boundary misorientations
% [grains, ebsd.grainId] = calcGrains(ebsd)
% plot(ebsd, ebsd.GAM./degree)
%
%% Input:
% ebsd - @EBSD
%
%% Options:
% threshold - ignore misorientation angles larger then threshold
%
% See also
% grain2d.GOS



%% Modified MTex in-built KAM script
% % Modifications include:
% % - delete the consideration of neighbors of order n (default is 1).
% % - delete the option to return the maximum misorientation angle.
% % - include MTex's in-built spatialDecomposition.m & generateUnitCells.m 
%     scripts.
%
% compute adjacent measurements
[~,~,I_FD] = spatialDecomposition([ebsd.prop.x(:), ebsd.prop.y(:)],ebsd.unitCell,'unitCell');
% A_D = I_FD.' * I_FD; % Method 1
A_D = I_FD.' * I_FD == 1; % Method 2

% extract all adjacent pairs surrounding a pixel
% [Dl, Dr] = find(A_D); % Method 1
[Dl,Dr] = find(triu(A_D,1)); % Method 2

% row indices of neighbouring pixels
% matchingRows = find(Dl == Dr + 1); % Method 1
matchingRows = find(Dl == Dr - 1); % Method 2
Dl = Dl(matchingRows); Dr = Dr(matchingRows);
% calculate the row indices for Dl and Dr based on the row-size of the ebsd
% variable
rowDl = ceil(Dl / size(ebsd.gridify, 1));
rowDr = ceil(Dr / size(ebsd.gridify, 1));
% find the rows in Dl and Dr where the pixel positions do not share the 
% same row of the ebsd variable
invalidRows = rowDl ~= rowDr;
% get the row indices where the condition is true
[rowIdx, ~] = find(invalidRows);
% delete them from the calculation
Dl(rowIdx) = []; Dr(rowIdx) = [];

% take only ordered pairs of same, indexed phase 
% use = Dl > Dr & ebsd.phaseId(Dl) == ebsd.phaseId(Dr) & ebsd.isIndexed(Dl);  % Method 1
use = ebsd.phaseId(Dl) == ebsd.phaseId(Dr) & ebsd.isIndexed(Dl);  % Method 2
Dl = Dl(use); Dr = Dr(use);
phaseId = ebsd.phaseId(Dl);

% calculate misorientation angles
omega = zeros(size(Dl));

% iterate all phases
for p=1:numel(ebsd.phaseMap)
  
  currentPhase = phaseId == p;
  if any(currentPhase)
    
    o_Dl = orientation(ebsd.rotations(Dl(currentPhase)),ebsd.CSList{p});
    o_Dr = orientation(ebsd.rotations(Dr(currentPhase)),ebsd.CSList{p});
    omega(currentPhase) = angle(o_Dl,o_Dr);
  end
end

% decide which orientations to consider
if isfield(ebsd.prop,'grainId') && ~check_option(varargin,'threshold')  
  % ignore grain boundaries
  ind = ebsd.prop.grainId(Dl) == ebsd.prop.grainId(Dr);
else
  % ignore also internal grain boundaries
  ind = omega < get_option(varargin,'threshold',10*degree);
end

% compute kernel average misorientation
kam = sparse(Dl(ind),Dr(ind),omega(ind)+0.00001,length(ebsd),length(ebsd));
kam = kam+kam';
kam = reshape(full(sum(kam,2)./sum(kam>0,2)),size(ebsd)); % mean
%%



%% Commands by Rüdiger Killian to calculate the grain-based GAM
[~,~,gId] = unique(ebsd.grainId);
tempGAM = accumarray(gId,kam,[],@nanmean);
%%



%% Commands by Azdiar Gazder to re-assign the GAM value to map pixels without a loop
gam = nan(size(ebsd.grainId));
gam(:) = tempGAM(gId);

end
