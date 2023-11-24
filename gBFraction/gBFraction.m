function outGrains = gBFraction(inGrains,varargin)
%% Function description:
% This function calculates the fraction of indexed boundary segments that
% are below and above user-specified threshold angle(s) for each grain.
%
%% Notes to users:
% This function is currently restricted to single phase maps only.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgement(s):
% Dr. Håkon Wiik Ånes (hakon.w.anes@ntnu.no) for the original script
% describing such functionality posted in:
% https://github.com/hakonanes/mtex-snippets/blob/master/ebsd_fraction_hab.m
%
%% Syntax:
%  gBFraction(grains,varargin)
%
%% Input:
%  grains              - @grain2d
%
%% Output:
%  none
%
%% Options:
%  thresholdAngle      -  @numeric, define the threshold angle
%%


thresholdAngle = get_option(varargin,'threshold',15*degree);
flagAbsolute = check_option(varargin,'absolute');

% Check if any threshold angles are greater than the maximum allowable
% misorientation angle for a given crystal symmetry
fR = fundamentalRegion(inGrains.CS,inGrains.CS);
if any(gt(thresholdAngle, fR.maxAngle))
    thresholdAngle(thresholdAngle > fR.maxAngle) = [];
    warning(['Threshold angles > maximum permissiable angle of ',num2str(fR.maxAngle./degree),'° deleted.']);
end

% Check if threshold angles are specified
if isempty(thresholdAngle)
    error('Threshold angles not specified.');
end

% Restrict the calculation to indexed grains only
outGrains = inGrains('indexed');

% Pre-allocate the arrays
if flagAbsolute
    outGrains.prop.gBThreshold = zeros(length(outGrains),length(thresholdAngle));
    outGrains.prop.gBTotal = zeros(length(outGrains),length(thresholdAngle));
else
    outGrains.prop.gBFraction = zeros(length(outGrains),length(thresholdAngle));
end

% Calculate the number of indexed boundary segments below and above the
% threshold angle for each grain
for ii = 1:length(thresholdAngle)
    for jj = 1:length(outGrains)
        try
            % get the grain id
            id = outGrains.id(jj);
            % create a logical array defining boundary segments below and
            % above the treshold angle
            isGreater = outGrains(id).boundary('indexed','indexed').misorientation.angle >= thresholdAngle(ii);

            if flagAbsolute
                % calculate the number of boundaries at or greater than the
                % threshold and total number of boundaries for each grain
                outGrains.prop.gBThreshold(jj,ii) = nnz(isGreater);
                outGrains.prop.gBTotal(jj,ii) = length(isGreater);
            else
                % calculate the boundary fraction at or greater than the
                % threshold by normalising for each grain
                outGrains.prop.gBFraction(jj,ii) = nnz(isGreater) / length(isGreater);
            end
        
        catch
        end
    end

end

end