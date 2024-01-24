function stepSize = calcStepSize(inebsd)
%% Function description:
% Calculates the step size of the ebsd map. This function can also be used
% in conjunction with the regrid.m script.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  stepSize = calcStepSize(ebsd)
%
%% Input:
%  ebsd        - @EBSD
%
%% Output:
%  stepSize    - @numeric
% 
%%

% calculate the ebsd map step size
% For upto MTEX v5.10.0
xx = [inebsd.unitCell(:,1);inebsd.unitCell(1,1)]; % repeat the 1st x co-ordinate to close the unit pixel shape
yy = [inebsd.unitCell(:,2);inebsd.unitCell(1,2)]; % repeat the 1st y co-ordinate to close the unit pixel shape
% % For MTEX v6.0.0 
% xx = [inebsd.unitCell.x;inebsd.unitCell.x(1,1)]; % repeat the 1st x co-ordinate to close the unit pixel shape
% yy = [inebsd.unitCell.y;inebsd.unitCell.y(1,1)]; % repeat the 1st y co-ordinate to close the unit pixel shape

unitPixelArea = polyarea(xx,yy);
if size(inebsd.unitCell,1) == 6 % hexGrid
    stepSize = sqrt(unitPixelArea/sind(60));
else % squareGrid
    stepSize = sqrt(unitPixelArea);
end

end
