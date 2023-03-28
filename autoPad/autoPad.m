function outMap = autoPad(inMap,varargin)
%% Function description:
% Automatically pads a binary map with ones or zeros to prevent map data 
% from getting clipped during subsequent map rotation. 
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgments:
% The original image padding algorithm by Justin K. Romberg can be found at:
% https://www.clear.rice.edu/elec431/projects96/DSP/projections.html
%
%% Syntax:
%  [outMap] = autoPad(inMap)
%
%% Input:
%  inMap          - @logical
%  padFactor      - @numeric
%
%% Output:
%  outMap         - @logical
%
%% Options:
%  'ones'  or
%  'zeros'        -  @char, specifies what to pad binary map with
%%

% check for map padding option
if ~isempty(varargin) && any(strcmpi(varargin,'ones'))
    padLogic = true;
elseif ~isempty(varargin)&& any(strcmpi(varargin,'zeros'))
    padLogic = false;
elseif isempty(varargin)
    error('Specify if padding is with ones or zeros.');
    return;
end

% define the input map size
[mapRows,mapCols] = size(inMap);

% find the map diagonal
mapDiag = ceil(sqrt(mapRows^2 + mapCols^2));

% find the closest multiple
padRows = mapRows*ceil((mapDiag - mapRows)/mapRows);
padCols = mapCols*ceil((mapDiag - mapCols)/mapCols);

% define the padded map size as a matrix of ones or zeros
outRows = mapRows + (2*padRows);
outCols = mapCols + (2*padCols);

if padLogic == true
    outMap = ones(outRows,outCols);
elseif padLogic == false
    outMap = zeros(outRows,outCols);
end

% replace input map values in the middle of the padded map
outMap(1+padRows:(padRows+mapRows), ...
    1+padCols:(padCols+mapCols)) = inMap;

end

