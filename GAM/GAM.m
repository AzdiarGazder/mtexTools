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
A_D = I_FD.' * I_FD;

% extract adjacent pairs
[Dl, Dr] = find(A_D);

% take only ordered pairs of same, indexed phase 
use = Dl > Dr & ebsd.phaseId(Dl) == ebsd.phaseId(Dr) & ebsd.isIndexed(Dl);
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
kam = reshape(full(sum(kam,2)./sum(kam>0,2)),size(ebsd));
%%



%% Commands by Rüdiger Killian to calculate the grain-based GAM
[~,~,eindex] = unique(ebsd.grainId);
tempGAM = accumarray(eindex,kam,[],@nanmean);
%%



%% Commands by Azdiar Gazder to re-assign the GAM value to map pixels
% gam = nan(size(ebsd.grainId));
% for ii = 1:max(eindex)
% gam(ebsd.grainId==ii) = tempGAM(ii);
% end
% Do the same more efficiently without a loop
gam = NaN(size(ebsd.grainId));
mask = ebsd.grainId <= max(eindex);
gam(mask) = tempGAM(ebsd.grainId(mask));