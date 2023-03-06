function split(inebsd,varargin)
%% Function description:
% Divides an ebsd map into a matrix (with a user-specified number of rows
% and columns) of sub-maps. Additional inputs include the ability to
% overlap a length fraction along both, horizontal and vertical sub-map
% directions.
% The sub-maps are returned within a structure variable. The location of
% each sub-map is denoted by the row and column number. For example:
% ebsd23 = sub-map from row 2, column 3 of the ebsd map
%
%% Note to users:
% Gridify the sub-map variables before saving sub-maps as a *.ctf file.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements:
% Dr. Christopher Daniel
% For the original concept applied to a texture block analysis script uploaded to:
% https://github.com/LightForm-group/MTEX-texture-block-analysis/blob/main/texture_block_analysis.m
%
%% Syntax:
%  [str] = split(ebsd)
%
%% Input:
%  ebsd       - @EBSD
%
%% Output:
%  str        - structure variable containing @EBSD
%
%% Options:
%  'matrix'            -  @numeric, an array defining the number of rows
%                         and columns to split the ebsd map into sub-maps.
%  'overlap'           -  @numeric, an array defining the factor by which
%                         to overlap subsets along the susbet maps along
%                         the horizontal and vertical sub-map directions.
%%

% grid the ebsd map
gebsd = gridify(inebsd);
% define the ebsd map size (Y-axis = rows ; X-axis = columns)
mapSize_Y = size(gebsd,1); mapSize_X = size(gebsd,2);
% check for ebsd & gebsd map size match
if (mapSize_Y*mapSize_X) ~= size(inebsd,1)
    error(sprintf('\nNon-indexed pixels missing from the ebsd variable.'));
    return;
end


% check for the matrix values
if check_option(varargin,'matrix')
    splitMatrix = num2cell(get_option(varargin,'matrix'));
    [numRo,numCol] = deal(splitMatrix{:});
    if isInteger(numRo) ~=1 || isInteger(numCol) ~=1
        error(sprintf('\nThe matrix value(s) must be positive integer(s).'));
        return;
    end

else
    % if the user has not specified the matrix values
    error(sprintf('\nMatrix not specified by the user.'));
    return;
end


% check for the overlap values
if check_option(varargin,'overlap')
    overlapMatrix = num2cell(get_option(varargin,'overlap'));
    [overlapRo,overlapCol] = deal(overlapMatrix{:});
    if overlapCol < 0.01 || overlapCol > 0.99  || overlapRo < 0.01 || overlapRo > 0.99
        error(sprintf('\nThe overlap value(s) must range between 0.01 and 0.99.'));
        return;
    end

else
    % if the user has not specified the matrix values
    warning(sprintf('\nNo overlap specified by the user.'));
    overlapRo = 0; overlapCol = 0;
end

% check for the overlap value when user specifies only 1 row or column
if numRo == 1; overlapRo = 0; end
if numCol == 1; overlapCol = 0; end

% calculate the step size of the ebsd map
xx = [inebsd.unitCell(:,1);inebsd.unitCell(1,1)]; % repeat the 1st x co-ordinate to close the unit pixel shape
yy = [inebsd.unitCell(:,2);inebsd.unitCell(1,2)]; % repeat the 1st y co-ordinate to close the unit pixel shape
unitPixelArea = polyarea(xx,yy);
if size(inebsd.unitCell,1) == 6 % hexGrid
    stepSize = sqrt(unitPixelArea/sind(60));
else % squareGrid
    stepSize = sqrt(unitPixelArea);
end


% X & Y co-ordinates of the gridded ebsd map
XX = gebsd.prop.x;
YY = gebsd.prop.y;


%% Example of the logic used in the algorithm to split the map:
%
% Task =  Split 100 pixels into 4 columns such that:
% submap 1 = submap 1 + right overlap...
% submap 2 = left overlap + submap 2 + right overlap...
% submap 3 = left overlap + submap 3 + right overlap...
% submap 4 = left overlap + submap 4
%
% nominal column indices = [1 25 50 75 100]
% overlap = 5 pixels
%
% column indices defining the bounds for submap 1:
% left = 1
% right = 25 + 5 = 30
% size of submap 1 = 30 - 1 = 29 columns
%
% column indices defining the bounds for submap 2:
% left = 25 - 5 = 20
% right = 50 + 5 = 55
% size of submap 2 = 55 - 20 = 35 columns
%
% column indices defining the bounds for submap 3:
% left = 50 - 5 = 45
% right = 75 + 5 = 80
% size of submap 3 = 80 - 45 = 35 columns
%
% column indices defining the bounds for submap 4:
% left = 75 - 5 = 70
% right = 100
% size of submap 4 = 100 - 70 = 30 columns
%
% left array = [1st nominal column index,...
%              (2:(end-1) nominal column indices - overlap)]
% right array = [(2:(end-1) nominal column indices + overlap),...
%               end nominal column index]
%%


%% Split rows as per alogorithm logic
% nominal number of rows for a submap
% note: the number of rows for the first & last submap vary from those
% in-between as the former two only have one overlap each
submapSize_Y = round(mapSize_Y/numRo);
% nominal row start index for each submap + the last row index
submap_yy = round(linspace(0,mapSize_Y,(numRo+1)));
submap_yy = [1, submap_yy(2:end)]';
% compute overlap as a fraction of the nominal number of rows for a submap
submapOverlap_Y = round(overlapRo*submapSize_Y);
% define the top & bottom row indices for each submap
submap_yyTop = [submap_yy(1,1); (submap_yy(2:end-1,1)-submapOverlap_Y)];
submap_yyBottom = [(submap_yy(2:end-1,1)+submapOverlap_Y); submap_yy(end,1)];
%%


%% split columns as per alogorithm logic
% nominal number of columns for a submap
% note: the number of columns for the last submap may vary
submapSize_X = round(mapSize_X/numCol);
% nominal column start index for each submap + the last column index
submap_xx = round(linspace(0,mapSize_X,(numCol+1)));
submap_xx = [1, submap_xx(2:end)]';
% compute overlap as a fraction of the nominal number of columns for a submap
submapOverlap_X = round(overlapCol*submapSize_X);
% define the left & right column indices for each submap
submap_xxLeft = [submap_xx(1,1); (submap_xx(2:end-1,1)-submapOverlap_X)];
submap_xxRight = [(submap_xx(2:end-1,1)+submapOverlap_X); submap_xx(end,1)];
%%


%% Swap the variables based on the location of the map origin
xMapDir = getMTEXpref('xAxisDirection');
zMapDir = getMTEXpref('zAxisDirection');

tempTop = submap_yyTop;
tempBottom = submap_yyBottom;
tempLeft = submap_xxLeft;
tempRight = submap_xxRight;

if strcmpi(xMapDir,'north') && strcmpi(zMapDir,'intoPlane')
    warning(sprintf('\nMap origin = south-west corner.'));
    submap_yyTop = tempLeft;
    submap_yyBottom = tempRight;
    submap_xxLeft = tempTop;
    submap_xxRight = tempBottom;
    numberOrder = 0;
elseif strcmpi(xMapDir,'north') && strcmpi(zMapDir,'outofPlane')
    warning(sprintf('\nMap origin = south-east corner.'));
    submap_yyTop = tempLeft;
    submap_yyBottom = tempRight;
    submap_xxLeft = tempTop;
    submap_xxRight = tempBottom;
    numberOrder = 0;
elseif strcmpi(xMapDir,'east') && strcmpi(zMapDir,'intoPlane')
    warning(sprintf('\nMap origin = north-west corner.'));
    numberOrder = 1;
elseif strcmpi(xMapDir,'east') && strcmpi(zMapDir,'outofPlane')
    warning(sprintf('\nMap origin = south-west corner.'));
    numberOrder = 1;
end
%%



%% Loop over the map to split it into the user specified matrix
for ii = 1:length(submap_yyTop)
    for jj = 1:length(submap_xxLeft)
        
        xx = [submap_xxLeft(jj); submap_xxRight(jj)].*stepSize;
        yy = [submap_yyTop(ii); submap_yyBottom(ii)].*stepSize;
        
        % logical check for ebsd map data inside/outside a ROI
        [logChk,~] = inpolygon(XX(:),YY(:),xx(:,1),yy(:,1));

        % define a new ebsd variable of split ebsd map data
        temp_outebsd = gebsd(logChk);

        % un-gridify the split ebsd map data
        outebsd = EBSD(temp_outebsd);

        % define a variable name
        if numberOrder  %numberOrder == 1
            variableName_subMap = ['ebsd',num2str(ii,'%1.0f'),num2str(jj,'%1.0f')];
        else  %numberOrder == 0
            variableName_subMap = ['ebsd',num2str(jj,'%1.0f'),num2str(ii,'%1.0f')];
        end
        % assign the split map variable (and data) to the base MATLAB
        % workspace
        assignin('base',variableName_subMap,outebsd);
    end
end
%%
end




%% Greater than zero integer check
% https://au.mathworks.com/matlabcentral/answers/16390-integer-check
% https://au.mathworks.com/matlabcentral/answers/377094-how-to-check-the-input-from-user-is-positive-integer-number
function bool = isInteger(x)
% Inf and NaN are not integers
if ~isnumeric(x)
    error('Input must be a numeric, not a %s.',class(x));
end
bool1 = (mod(x,1) == 0); % (rem(x,1) == 0); % integer check
bool2 = (x > 0); % greater than zero check
bool = bool1 * bool2; % product of checks
end