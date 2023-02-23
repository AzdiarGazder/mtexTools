function [outebsd] = euclideanDistance(inebsd,varargin)
%% Function description:
% Calculates the 2D Euclidean distance in pixels (default) or map scan 
% units for supported distance methods for each pixel within a grain.
% The default 2D Euclidean distance measurement is from the grain center to
% the grain boundary or when specified by the user, vice-versa. 
% Additional outputs include the 2D Euclidean distance in pixels or map 
% scan units as a function of normalised grain diameter (ECD) and grain 
% area.
% The values are returned within the 'ebsd.prop.euclid', 
% 'ebsd.prop.euclidDiameter' and 'ebsd.prop.euclidArea' structure 
% variables.
%
%% Note to users:
% This function uses the function "bwdist" from the MATLAB Image Processing
% Toolbox.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements: 
% Dr. Håkon Wiik Ånes, NTNU
% For the original grain boundary distance script uploaded to:
% https://github.com/hakonanes/mtex-snippets/blob/master/distance_from_grain_boundary.m
%
%% Syntax:
%  [ebsd] = euclideanDistance(ebsd)
%
%% Input:
%  ebsd       - @EBSD
%
%% Output:
%  ebsd       - @EBSD
%
%% Options:
%  'angle'            -  @numeric, define the critical misorientation angle
%                        of a grain boundary
%  'euclidean', or
%  'cityblock', or
%  'chessboard', or
%  'quasi-euclidean'  -  @char, defines the supported 2D Euclidean distance
%                        transform method.
%  'scanUnit'         -  @char, return the 2D Euclidean distances in map 
%                        scanUnits instead of pixels.
%  'invert'           -  @char, invert the 2D Euclidean distance values.
%%

gebsd = gridify(inebsd);
if size(gebsd,1)*size(gebsd,2) ~= size(inebsd,1)
    error(sprintf('\nNon-indexed pixels missing from the ebsd variable.'));
    return;
end

% check for the inputted default critical angle of a grain boundary in 
% degrees or radians
if check_option(varargin,'angle')
    criticalAngle = get_option(varargin,'angle');
    if criticalAngle < -((pi()/180) * 360) || criticalAngle > ((pi()/180) * 360)
         warning(sprintf('\nCritical misorientation angle defining a grain boundary is very large.\nConverting it from degrees to radians.'));
        criticalAngle = (pi()/180) * criticalAngle;
    end
else
    % set the default critical angle of a grain boundary
    warning(sprintf('\nCritical misorientation angle defining a grain boundary not specified.\nDefault angle = 2°.'));
    criticalAngle = 2*degree;
end


outebsd = inebsd;
% calculate grains based on the critical angle
disp('- Calculating grains.')
[grains,outebsd.grainId] = calcGrains(outebsd,'angle',criticalAngle);

% extract all grain boundaries
disp('- Calculating grain boundaries.')
gB = grains.boundary;
% ensure all boundary misorientations conform to the critical angle
% of a grain boundary
disp('- Thresholding grain boundaries to >= the critical grain angle.')
gB = gB(gB.misorientation.angle >= criticalAngle);
% exclude edge boundaries
disp('- Excluding grain boundaries located at map edges.')
edgeB_id = any(gB.grainId == 0,2); % find row-wise
gB(edgeB_id) = [];



% define a zero array within the ebsd variable the same size as the map
outebsd.prop.isBoundary = zeros(outebsd.size);
% identify the pixels at grain boundary segments
outebsd(gB.midPoint(:,1),gB.midPoint(:,2)).prop.isBoundary = 1;

% Calculate the distance transforms in pixels from the grain boundary
% segments based on the chosen or default method
bw = outebsd.prop.isBoundary;
bw = reshape(bw,[size(gebsd,1),size(gebsd,2)]);


if ~isempty(varargin) && check_option(varargin,'euclidean')
    outebsd.prop.euclid = double(bwdist(bw,'euclidean'));
elseif ~isempty(varargin) && check_option(varargin,'cityblock')
    outebsd.prop.euclid = double(bwdist(bw,'cityblock'));
elseif ~isempty(varargin) && check_option(varargin,'chessboard')
    outebsd.prop.euclid = double(bwdist(bw,'chessboard'));
elseif ~isempty(varargin) && check_option(varargin,'quasi-euclidean')
    outebsd.prop.euclid = double(bwdist(bw,'quasi-euclidean'));
elseif ~isempty(varargin) && (~check_option(varargin,'euclidean') || ~check_option(varargin,'cityblock') || ~check_option(varargin,'chessboard') || ~check_option(varargin,'quasi-euclidean'))
    warning(sprintf('\nDistance transform type not specified.\nDefault method = euclidean.'));
    outebsd.prop.euclid = double(bwdist(bw,'euclidean'));
elseif isempty(varargin)
    warning(sprintf('\nDistance transform type not specified.\nDefault method = euclidean.'));
    outebsd.prop.euclid = double(bwdist(bw,'euclidean'));
end

% reshape array row-wise into a single column array 
outebsd.prop.euclid = reshape(outebsd.prop.euclid,[],1);

% calculate the normalised grain diameter and area
grainDiameter = grains.diameter; % ECD
grainArea = grains.area;
normgrainDiameter = grainArea./max(grainDiameter);
normgrainArea = grainArea./max(grainArea);

% check if the 2D Euclidean distance is to be outputted for: 
% Case 1: grain boundaries to grain centers, or
% Case 2: grain centers to grain boundaries. 
% For Case 1, the output is as-calculated from bwdist (above).
% For Case 2, the loop given below is needed. 
% NOTE: Case 2 = default unless specified otherwise.
if ~isempty(varargin) && check_option(varargin,'invert')
    disp('- Inverting 2D Euclidean distances. [Min = at grain boundaries. Max = at grain centers.]')

elseif isempty(varargin) || (~isempty(varargin) && ~check_option(varargin,'invert'))
    disp('- Calculating 2D Euclidean distances. [Min = at grain centers. Max = at grain boundaries.]')
    for ii = 1:length(grains)
        [idx,~] = find(outebsd.grainId == ii);
        euclidDistance = outebsd.prop.euclid(idx,1);
        maxEuclid = max(euclidDistance);
        % minEuclid = min(euclidDistance(euclidDistance > 0));
        % euclidDistance = (1 - ((minEuclid / maxEuclid).*euclidDistance)) * maxEuclid
        % Since minEuclid is always 1, the equation is simplified to:
        euclidDistance = maxEuclid - euclidDistance; 
        outebsd.prop.euclid(idx,1) = euclidDistance;
        outebsd.prop.euclidDiameter(idx,1) = euclidDistance./normgrainDiameter(ii);
        outebsd.prop.euclidArea(idx,1) = euclidDistance./normgrainArea(ii);
    end
end


% check for the unit to return the 2D distance transform
if ~isempty(varargin) && check_option(varargin,'scanUnit')
    disp('- Calculating the 2D Euclidean distances in map scan units.')
    % calculate the map step size
    xx = [outebsd.unitCell(:,1); outebsd.unitCell(1,1)]; % repeat the 1st x co-ordinate to close the unit pixel shape
    yy = [outebsd.unitCell(:,2); outebsd.unitCell(1,2)]; % repeat the 1st y co-ordinate to close the unit pixel shape
    unitPixelArea = polyarea(xx,yy);
    if size(outebsd.unitCell,1) == 6 % hexGrid
        stepSize = sqrt(unitPixelArea/sind(60));
    else % squareGrid
        stepSize = sqrt(unitPixelArea);
    end
    outebsd.prop.euclid = outebsd.prop.euclid.*stepSize;
    outebsd.prop.euclidDiameter = outebsd.prop.euclidDiameter.*stepSize;
    outebsd.prop.euclidArea = outebsd.prop.euclidArea.*stepSize;
end


% check if the user has not specified an output variable
if nargout == 0
    assignin('base','ebsd',outebsd);
end
end
