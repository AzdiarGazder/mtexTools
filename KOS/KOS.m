function kos = KOS(ebsd,varargin)
%% Function description:
% By modifying MTEX's in-built KAM script, this function calculates the 
% kernel orientation spread (KOS). The KOS is similar to GOS but done 
% within a user-defined kernel. The n-neighbour kernal average 
% misorientation is averaged to return a single value per grain.
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
% plot(ebsd,ebsd.KOS./degree)
%
% % ignore misorientation angles > threshold
% kos = KOS(ebsd,'order',3,'threshold',10*degree);
% plot(ebsd,kos./degree)
%
% % ignore grain boundary misorientations
% [grains, ebsd.grainId] = calcGrains(ebsd)
% plot(ebsd, ebsd.KOS./degree)
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

% compute the KAM value based on user inputs
kam = KAM(ebsd,varargin{:});

% calculate the KOS value for the grains by averaging the KAM value(s)
% within each grain
KOS = grainMean(ebsd, kam);

%% Commands by Rüdiger Killian to calculate the grain-based GAM
[~,~,grainId] = unique(ebsd.grainId);
%%

%% Commands by Azdiar Gazder to re-assign the KOS value to map pixels
% kos = nan(size(ebsd.grainId));
% for ii = 1:max(grainId)
% kos(ebsd.grainId==ii) = KOS(ii);
% end
% Do the same more efficiently without a loop
kos = nan(size(ebsd.grainId));
mask = ebsd.grainId <= max(grainId);
kos(mask) = KOS(ebsd.grainId(mask));

end
