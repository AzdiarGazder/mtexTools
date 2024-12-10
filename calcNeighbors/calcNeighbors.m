function [neighbors] = calcNeighbors(grainId, pairs, varargin)
%% Function description:
% Calculate the user-defined order of neighbours of a given grain Id using 
% grain pairs.
%
%% Author:
% Dr. Azdiar Gazder, 2024, azdiaratuowdotedudotau
%
%% Acknowledgements: 
% Dr. Sergey Panpurin 
% For the original getNeighbors script located at:
% https://github.com/edwinofsakh/ebsdam/blob/master/func/getNeighbors.m
%
%% Syntax
%  [neighbors] = calcNeighbors(grainId, pairs, varargin)
%
% Input
%  grainId      - @double, index of the grain
%  pairs        - @double, pairs of grain indices [n, 2]
%
% Output
%  neighbors    - @double, indices of neighbours of the requested order
%
% Options
%   'order'     - the order of the neighbours (default = 1)
%   'include'   - include all lower-order neighbours up to the specified 
%                 order
%
%%


% Parse input options
if ~isequal(size(grainId),[1 1])
    error('Grain Id must be a @double array of [1 1] size.')
end
if ~isequal(size(pairs,2),2)
    error('Grain pairs must be a @double array of [n 2] size.')
end
order = get_option(varargin, 'order', 1);
includeLowerOrders = any(strcmpi(varargin, 'include'));


% First order neighbours
firstOrderNeighbors = getNeighbors(grainId, pairs);

if order == 1
    % Return only the first-order neighbours
    neighbors = firstOrderNeighbors;
else
    % Get higher-order neighbours up to the requested order
    if includeLowerOrders
        % Include neighbours from all orders up to the requested order
        neighbors = getAllOrderNeighbors(grainId, pairs, order);
    else
        % Only return neighbours of the exact requested order
        neighbors = getHigherOrderNeighbors(grainId, pairs, order);
    end
end

% Check if no neighbours were found for the requested order
if isempty(neighbors)
    neighbors = [];  % Return empty if no neighbours found
else
    % Sort the grain Ids of the neighbours in ascending order
    neighbors = sort(neighbors);
end

end



%%
function neighbors = getNeighbors(grainId, pairs)
% Find first-order neighbours of the given grainId from pairs
ind1 = pairs(pairs(:,1) == grainId, 2);
ind2 = pairs(pairs(:,2) == grainId, 1);
neighbors = [ind1; ind2];
end
%%



%%
function neighbors = getHigherOrderNeighbors(grainId, pairs, order)
% Find the neighbours of a given order
previousOrderNeighbors = getNeighbors(grainId, pairs);  % First-order neighbours
allNeighbors = previousOrderNeighbors;

% Loop to find each higher order
for currentOrder = 2:order
    newNeighbors = arrayfun(@(x) getNeighbors(x, pairs), previousOrderNeighbors, 'UniformOutput', false);
    newNeighbors = unique(cell2mat(newNeighbors));
    
    % Remove the original grainId and all previous order neighbours
    newNeighbors = setdiff(newNeighbors, [grainId; allNeighbors]);
    
    % Update the list of all found neighbours so far
    allNeighbors = unique([allNeighbors; newNeighbors]);
    
    % Set the current neighbours as the previous for the next iteration
    previousOrderNeighbors = newNeighbors;
end

% Return only the neighbours of the requested order
neighbors = previousOrderNeighbors;
end
%%



%%
function neighbors = getAllOrderNeighbors(grainId, pairs, maxOrder)
% Get all neighbours from first order up to the requested maxOrder

% Initialise with first-order neighbours
allNeighbors = getNeighbors(grainId, pairs);
currentNeighbors = allNeighbors;

% Loop to find each higher order
for currentOrder = 2:maxOrder
    newNeighbors = arrayfun(@(x) getNeighbors(x, pairs), currentNeighbors, 'UniformOutput', false);
    newNeighbors = unique(cell2mat(newNeighbors));
    
    % Remove the original grainId and already found neighbours
    newNeighbors = setdiff(newNeighbors, [grainId; allNeighbors]);
    
    % Update the list of all found neighbours so far
    allNeighbors = unique([allNeighbors; newNeighbors]);
    
    % Update current neighbours for the next order iteration
    currentNeighbors = newNeighbors;
end

% Return all neighbours from the first up to the maxOrder
neighbors = allNeighbors;
end
%%
