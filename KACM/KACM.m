function kacm = KACM(ebsd,varargin)
%% Function description:
% By modifying MTEX's in-built KAM script, this function calculates the 
% kernel average center misorientation (KACM). KACM is equivalent to KAM
% for first nearest-neighbours. When the kernel is larger than the first 
% nearest-neighbors, then KACM is calculated by averaging the 
% misorientations between the center point of the kernel and the points
% at the perimeter of the kernel. 
%
%% Modified by:
% Dr. Azdiar Gazder, 2024, azdiaratuowdotedudotau
%
%% Acknowledgements: 
% Dr. Rüdiger Killian
% For the commands to compute the grain-based KOS at:
% https://groups.google.com/g/mtexmail/c/x1oFYjh0Des
%
%% Syntax:
% plot(ebsd,ebsd.KACM./degree)
%
% % ignore misorientation angles > threshold
% kacm = KACM(ebsd,'order',3,'threshold',10*degree);
% plot(ebsd,kacm./degree)
%
% % ignore grain boundary misorientations
% [grains, ebsd.grainId] = calcGrains(ebsd)
% plot(ebsd, ebsd.KACM./degree)
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

n = get_option(varargin,'order',2);

% find the 1st, ..., nth order neighbors for each element
A_D1 = A_D;
AA_DD = A_D;
for i = 1:n-1
    A_D = A_D + A_D*A_D1 + A_D1*A_D;
end
clear A_D1
% extract adjacent pairs
[Dl, Dr] = find(A_D);

% find and delete the 1st, ..., (n-1)th order neighbors for each element
if n > 1
    % find
    A_D2 = AA_DD;
    for i = 1:n-2
        AA_DD = AA_DD + AA_DD*A_D2 + A_D2*AA_DD;
    end
    clear A_D2
    % extract adjacent pairs
    [rDl,~] = find(AA_DD);


    % delete
    lMat = false(size(Dl));
    cnt = 1;
    for ii = 1:size(Dl,1)
        if Dl(ii,1) ~= rDl(cnt,1)
            lMat(ii) = true;
        else
            cnt = cnt + 1;
        end
    end
    Dl = Dl(lMat);
    Dr = Dr(lMat);
end

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

% compute kernel average center misorientation
kacm = sparse(Dl(ind),Dr(ind),omega(ind)+0.00001,length(ebsd),length(ebsd));
kacm = kacm+kacm';

if check_option(varargin,'max')
  kacm = reshape(full(max(kacm,[],2)),size(ebsd));
elseif check_option(varargin,'min')
  kacm = reshape(full(min(kacm,[],2)),size(ebsd));
else % mean
  kacm = reshape(full(sum(kacm,2)./sum(kacm>0,2)),size(ebsd));
end
