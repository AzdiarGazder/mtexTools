function outMap = pad(inMap,padArray,varargin)
%% Function description:
% Pad a binary map with ones or zeros based on a user specified padding 
% array. The padding array specifies the number of pixels to add on the top
% & bottom and left & right sides of the input map.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgments:
% The original image padding algorithm by Justin K. Romberg can be found at:
% https://www.clear.rice.edu/elec431/projects96/DSP/projections.html
%
%% Syntax:
%  [outMap] = dilate(ebsd,grain)
%
%% Input:
%  inMap          - @logical
%  padArray       - @double
%
%% Output:
%  outMap         - @logical
%%

% check for map padding array size
if ~isequal(size(padArray), [1 2])
    error('Padding is defined as a 1 x 2 array.');
    return;
end
padRows = padArray(1,1);
padCols = padArray(1,2);

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

% define the padded map size
if padLogic == true
    outMap = ones(mapRows+(2*padRows), mapCols+(2*padCols));
elseif padLogic == false
    outMap = zeros(mapRows+(2*padRows), mapCols+(2*padCols));
end

% replace input map values in the middle of the padded map
outMap((1+padRows):(mapRows+padRows), ...
    (1+padCols):(mapCols+padCols)) = inMap;

end
