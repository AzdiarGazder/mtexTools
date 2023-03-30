function [stepSize,outebsd] = calcStepSize(inebsd)
%% Function description:
% Calculates the step size of the ebsd map. This function also 
% re-calculates the x and y grid values as multiples of the step size to 
% mitigate any rounding-off errors during subsequent gridding operations.
% To enable the re-calculation of the x and y grid values, the ebsd 
% variable must be outputted from the function.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  [stepSize,ebsd] = calcStepSize(ebsd)
%
%% Input:
%  ebsd        - @EBSD
%
%% Output:
%  stepSize    - @numeric
%  ebsd        - @EBSD
%%

% calculate the ebsd map step size
xx = [inebsd.unitCell(:,1);inebsd.unitCell(1,1)]; % repeat the 1st x co-ordinate to close the unit pixel shape
yy = [inebsd.unitCell(:,2);inebsd.unitCell(1,2)]; % repeat the 1st y co-ordinate to close the unit pixel shape
unitPixelArea = polyarea(xx,yy);
if size(inebsd.unitCell,1) == 6 % hexGrid
    stepSize = sqrt(unitPixelArea/sind(60));
else % squareGrid
    stepSize = sqrt(unitPixelArea);
end

outebsd = inebsd;

% re-calculating the grid values as multiples of the calculated step size
% this step mitigates any rounding-off errors during subsequent gridding
% operations
outebsd.prop.x = stepSize.*floor(outebsd.prop.x./stepSize);
outebsd.prop.y = stepSize.*floor(outebsd.prop.y./stepSize);

end
