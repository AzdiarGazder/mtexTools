function gos = GOS(ebsd,grains,varargin)
%% Function description:
% The grain orientation spread (GOS) is the average of the angular 
% deviation between the orientation of each pixel within a grain and the 
% average orientation of the grain. The averaging returns a single value 
% per grain.
%
%% Modified by:
% Dr. Azdiar Gazder, 2024, azdiaratuowdotedudotau
%
%% Acknowledgements: 
% Dr. Rüdiger Killian
% For the commands to compute the grain-based GOS at:
% https://groups.google.com/g/mtexmail/c/x1oFYjh0Des
%
%% Syntax:
% plot(ebsd,ebsd.GOS./degree)
%
% gos = GOS(ebsd,grains);
% plot(ebsd,gos./degree)
%
%% Input:
% ebsd   - @EBSD
% grains - @grain2d
%


% compute the grain reference orientation deviation by iterating over all 
% phases
phaseId = ebsd.phaseId;
GROD = rotation.nan(size(ebsd));
for p = 1:numel(ebsd.phaseMap)
    currentPhase = phaseId == p;
    oriRef = grains.meanRotation(ebsd.grainId(currentPhase));
    if ~isempty(oriRef)
        oriRef = project2FundamentalRegion(oriRef, ebsd.CSList{p}, ebsd.rotations(currentPhase));
        GROD(currentPhase) = inv(oriRef) .* ebsd.rotations(currentPhase);
    end
end
grod = GROD.angle;


% calculate the GOS value for the grains by averaging the GROD value(s)
% within each grain
GOS = grainMean(ebsd, grod);



%% Commands by Rüdiger Killian to calculate the grain-based GAM
[~,~,grainId] = unique(ebsd.grainId);
%%



%% Commands by Azdiar Gazder to re-assign the KOS value to map pixels
% gos = nan(size(ebsd.grainId));
% for ii = 1:max(grainId)
% gos(ebsd.grainId==ii) = GOS(ii);
% end
% Do the same more efficiently without a loop
gos = nan(size(ebsd.grainId));
mask = ebsd.grainId <= max(grainId);
gos(mask) = GOS(ebsd.grainId(mask));

end
