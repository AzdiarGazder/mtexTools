function outMap = pad(inMap,varargin)
%% Function description:
% Pads a binary map with ones or zeros.
% Options include:
% (i) Padding to a size based on a user specified [1 x 2] padding array. 
% The padding array defines the number of rows and columns to add to
% the [(top & bottom) , (left & right)], respectively, of the input map.
% (ii) Paddding to the nearest square.
% (iii) Padding automatcially to a size that prevents map data from getting
% clipped during subsequent map rotation.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgments:
% For the original nearest 'square' image padding algorithm:
% https://au.mathworks.com/matlabcentral/answers/1853683-change-an-image-from-rectangular-to-square-by-adding-white-area
%
% Justin K. Romberg for the original 'auto' image padding algorithm:
% https://www.clear.rice.edu/elec431/projects96/DSP/projections.html
%
%% Syntax:
%  [outMap] = pad(inMap)
%
%% Input:
%  inMap          - @logical

%
%% Output:
%  outMap         - @logical
%
%% Options:
% 'size'           -  @char, option to pad with a user specified number of
%                     rows and columns.
%  padSize         -  @double, used with 'size'. Specifies the number of
%                     rows and columns to pad the map with.
%
% 'square'         -  @char, option to pad to nearest square.
%
% 'auto'           -  @char, option to automatcially pad to a size that
%                     prevents map data from getting clipped during
%                     subsequent map rotation.
%
% 'ones', 'zeros'  -  @char, specifies what to pad binary map with
%%


if ~isempty(varargin) && check_option(varargin,'size')
    padCase = 'size';
    padSize = get_option(varargin,'size');
    % check for map padSize array
    if ~isequal(size(padSize), [1 2])
        error('The ''size'' for padding is a [1 x 2] numeric array defining the number of rows and columns.');
        return;
    end
    padRows = padSize(1,1);
    padCols = padSize(1,2);

elseif check_option(varargin,'square')
    padCase = 'square';

elseif ~isempty(varargin) && check_option(varargin,'auto')
    padCase = 'auto';

elseif ~isempty(varargin) && (check_option(varargin,'size') || ~check_option(varargin,'square') || check_option(varargin,'auto'))
    error('Specify the padding type. Options = ''size'', ''square'', ''auto''');
    return;

elseif  isempty(varargin)
    error('Specify the padding type. Options = ''size'', ''square'', ''auto''');
    return;
end


% check for map padding option
if ~isempty(varargin) && any(strcmpi(varargin,'ones'))
    padLogic = true;

elseif ~isempty(varargin) && any(strcmpi(varargin,'zeros'))
    padLogic = false;

elseif ~isempty(varargin) && (~any(strcmpi(varargin,'ones')) || ~any(strcmpi(varargin,'zeros')))
    error('Specify if padding is with ones or zeros.');
    return;
end

% define the input map size
[mapRows,mapCols] = size(inMap);


switch padCase
    case 'size'
        % define the padded map size
        if padLogic == true
            outMap = ones(mapRows+(2*padRows), mapCols+(2*padCols));
        elseif padLogic == false
            outMap = zeros(mapRows+(2*padRows), mapCols+(2*padCols));
        end

        % replace input map values in the middle of the padded map
        outMap((1+padRows):(mapRows+padRows), ...
            (1+padCols):(mapCols+padCols)) = inMap;

    case 'square'
        d = abs(mapCols-mapRows); % find the difference between the columns and rows
        if(mod(d,2) == 1) % if the difference is an odd number
            if (mapCols > mapRows)   % add a row at the end
                if padLogic == true
                    inMap = [inMap; ones(1, mapCols)];
                elseif padLogic == false
                    inMap = [inMap; zeros(1, mapCols)];
                end
                mapRows = mapRows + 1;
            else                 % add a column at the end
                if padLogic == true
                    inMap = [inMap ones(mapRows, 1)];
                elseif padLogic == false
                    inMap = [inMap zeros(mapRows, 1)];
                end
                mapCols = mapCols + 1;
            end
        end
        if mapCols > mapRows
            padRows = (mapCols-mapRows)/2;
            padCols = 0;
%             outMap = padarray(inMap, [(mapCols-mapRows)/2 0]);
        else
            padRows = 0;
            padCols = (mapRows-mapCols)/2;
%             outMap = padarray(inMap, [0 (mapRows-mapCols)/2]);
        end
        
        if padLogic == true
            outMap = ones(mapRows+(2*padRows), mapCols+(2*padCols));
        elseif padLogic == false
            outMap = zeros(mapRows+(2*padRows), mapCols+(2*padCols));
        end
        % replace input map values in the middle of the padded map
        outMap((1+padRows):(mapRows+padRows), ...
            (1+padCols):(mapCols+padCols)) = inMap;

    
    
    case 'auto'
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

end
