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
% gos = GOS(ebsd,grains);
% plot(ebsd,gos./degree);
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
[~,~,gId] = unique(ebsd.grainId);
%%



%% Commands by Azdiar Gazder to re-assign the GOS value to map pixels without a loop
gos = nan(size(ebsd.grainId));
gos(:) = GOS(gId);

end
