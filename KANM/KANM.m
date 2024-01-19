function kanm = KANM(ebsd,varargin)
%% Function description:
% By modifying MTEX's in-built KAM script, this function calculates the 
% kernel average neighbour misorientation. The n-neighbour kernal 
% average misorientation is averaged to return a single value per grain.
%
%% Modified by:
% Dr. Azdiar Gazder, 2024, azdiaratuowdotedudotau
%
%% Acknowledgements: 
% Dr. Rüdiger Killian
% For the commands to compute the grain-based KANM at:
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
% plot(ebsd,ebsd.KANM./degree)
%
% % ignore misorientation angles > threshold
% kanm = KANM(ebsd,'order',3,'threshold',10*degree);
% plot(ebsd,kanm./degree)
%
% % ignore grain boundary misorientations
% [grains, ebsd.grainId] = calcGrains(ebsd)
% plot(ebsd, ebsd.KANM./degree)
%
%% Input:
% ebsd - @EBSD
%
%% Options:
% threshold - ignore misorientation angles larger then threshold
% order     - consider neighbors of order n
% max       - instead of the mean, return the maximum misorientation angle
% min       - instead of the mean, return the minimum misorientation angle

%
% See also
% grain2d.GOS


% compute adjacent measurements
[~,~,I_FD] = spatialDecomposition([ebsd.prop.x(:), ebsd.prop.y(:)],ebsd.unitCell,'unitCell');
A_D = I_FD.' * I_FD;

% get the order of the kernel
n = get_option(varargin,'order',1);

% compute all neighbours based on the order of the kernel
A_D1 = A_D;
for i = 1:n-1  
  A_D = A_D + A_D*A_D1 + A_D1*A_D;
end
clear A_D1

% extract all adjacent pairs surrounding a pixel
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

if check_option(varargin,'max')
  kam = reshape(full(max(kam,[],2)),size(ebsd));
elseif check_option(varargin,'min')
  kam = reshape(full(min(kam,[],2)),size(ebsd));
else % mean
  kam = reshape(full(sum(kam,2)./sum(kam>0,2)),size(ebsd));
end


%% Commands by Rüdiger Killian to calculate the grain-based GAM
[~,~,grainId] = unique(ebsd.grainId);
tempKANM = accumarray(grainId,kam,[],@nanmean);
%%



%% Commands by Azdiar Gazder to re-assign the GAM value to map pixels
% gam = nan(size(ebsd.grainId));
% for ii = 1:max(eindex)
% gam(ebsd.grainId==ii) = tempGAM(ii);
% end
% Do the same more efficiently without a loop
kanm = nan(size(ebsd.grainId));
mask = ebsd.grainId <= max(grainId);
kanm(mask) = tempKANM(ebsd.grainId(mask));

end
