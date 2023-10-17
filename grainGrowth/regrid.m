function outebsd = regrid(inebsd,stepSize)
%% Function description:
% Re-calculates the x and y grid values as multiples of the step size to 
% mitigate any rounding-off errors during subsequent gridding operations.
% This function can be used in conjunction with the calcStepSize.m script.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  ebsd = calcStepSize(ebsd)
%
%% Input:
%  ebsd        - @EBSD
%  stepSize    - @numeric
%
%% Output:
%  ebsd        - @EBSD
%
%%

outebsd = inebsd;

% Re-calculating the grid values as multiples of the calculated step size
% this step mitigates any rounding-off errors during subsequent gridding
% operations
outebsd.prop.x = stepSize.*floor(outebsd.prop.x./stepSize);
outebsd.prop.y = stepSize.*floor(outebsd.prop.y./stepSize);

end
