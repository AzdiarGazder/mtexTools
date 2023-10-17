function [normStrainMatrix] = calcXYStrainMatrix(varargin)

% Define the number of points
numPoints = get_option(varargin,'points',180);

angle = linspace(0,360,numPoints);
angle = angle(:);
eXX = sind(angle);
eYY = cosd(angle);
eZZ = -eXX - eYY;
strainMatrix = [eXX, eYY, eZZ];
normFactor = max(abs(strainMatrix),[],2);%'rows');
normStrainMatrix = strainMatrix./ normFactor;

end

% slope = -eXX / eYY;
% slope = -sind(angle) / cosd(angle);