function [Dl, Dr] = findNeighbours(ebsd,varargin)
% This function returns the indices of pixels immediately surrounding
% a pixel of interest for the full map.
%
%% Input:
% ebsd - @EBSD
%
%% Output:
% Dl   - @double, an [n,1] vector of pixel indices above and below the
%        pixel index in Dr.
% Dr   - @double, an [n,1] vector of pixel indices of interest.
%
%% Options:
% type - The pixel indices of immediate neighbours to the pixel of 
%        interest. The options are:
%        'vertical'  = for pixel indices to the top and bottom  (default), 
%        'horizontal'= for pixel indices to the left and right, or
%        'diagonal'  = for pixel indices to the NE, NW, SW, and SE
%
%%

type = get_option(varargin,'type','vertical');

% Get the size of the ebsd map grid
[ro, co] = size(ebsd.gridify);

% Generate all pixel indices
idx = (1:(ro * co))';

if strcmpi(type,'vertical')
    % Find the top neighbours of all pixels
    topNeighbours = [(idx(co + 1:end) - co), idx(co + 1:end)];

    % Find the bottom neighbours of all pixels
    bottomNeighbours = [(idx(1:end - co) + co), idx(1:end - co)];

    % Combine the top and bottom neighbours
    tbNeighbours = [topNeighbours; bottomNeighbours];
    tbNeighbours = sortrows(tbNeighbours, 2);

    Dl = tbNeighbours(:,1);
    Dr = tbNeighbours(:,2);


elseif strcmpi(type,'horizontal')
    % Find the left neighbours: pixels that are not in the first column
    leftIdx = idx(mod(idx-1, co) ~= 0);
    leftNeighbours = [leftIdx - 1, leftIdx];

    % Find the right neighbours: pixels that are not in the last column
    rightIdx = idx(mod(idx, co) ~= 0);
    rightNeighbours = [rightIdx + 1, rightIdx];

    % Combine the left and right neighbours
    lrNeighbours = [leftNeighbours; rightNeighbours];
    lrNeighbours = sortrows(lrNeighbours, 2);

    Dl = lrNeighbours(:,1);
    Dr = lrNeighbours(:,2);


elseif strcmpi(type,'diagonal')
    % Get row and column positions for each pixel
    [r, c] = ind2sub([ro, co], idx);

    % North-East neighbours (r-1, c+1): valid if not in first row and 
    % not in last column
    validNE = (r > 1) & (c < co);
    neNeighbours = [ sub2ind([ro, co], r(validNE)-1, c(validNE)+1), idx(validNE) ];
    typeNE = ones(size(neNeighbours,1),1);

    % North-West neighbours (r-1, c-1): valid if not in first row and 
    % not in first column
    validNW = (r > 1) & (c > 1);
    nwNeighbours = [ sub2ind([ro, co], r(validNW)-1, c(validNW)-1), idx(validNW) ];
    typeNW = 2*ones(size(nwNeighbours,1),1);

    % South-West neighbours (r+1, c-1): valid if not in last row and 
    % not in first column
    validSW = (r < ro) & (c > 1);
    swNeighbours = [ sub2ind([ro, co], r(validSW)+1, c(validSW)-1), idx(validSW) ];
    typeSW = 3*ones(size(swNeighbours,1),1);

    % South-East neighbours (r+1, c+1): valid if not in last row and 
    % not in last column
    validSE = (r < ro) & (c < co);
    seNeighbours = [ sub2ind([ro, co], r(validSE)+1, c(validSE)+1), idx(validSE) ];
    typeSE = 4*ones(size(seNeighbours,1),1);

    % Combine all diagonal neighbour pairs with an extra type column
    diagNeighbours = [neNeighbours, typeNE;...
        nwNeighbours, typeNW;...
        swNeighbours, typeSW;...
        seNeighbours, typeSE];

    % Sort rows by the pixel index of interest (second column) and 
    % then by type to enforce the order north-east, north-west, 
    % south-west, and south-east
    diagNeighbours = sortrows(diagNeighbours, [2, 3]);

    Dl = diagNeighbours(:,1);
    Dr = diagNeighbours(:,2);

end

end
