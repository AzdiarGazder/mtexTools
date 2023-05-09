function outcmap = discreteColormap(incmap,nbins)
%% Function description:
% Sub-divides a default colormap palette into a user specified number of 
% discrete colors to improve on the visual distinction between bins/levels.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  [outcmap] = divideColormap(incmap,nbins)
%
%% Input:
%  incmap     - @numeric
%  nbins      - @numeric
%
%% Output:
%  outcmap    - @numeric
%%

% check for input bin size
if length(incmap) < nbins
    error('Maximum number of bins exceeded.');
    return;
end


% make a numeric array with the same number of rows as the input colormap
sortedVals = [1:length(incmap)]';

% compute the bin width based on the number of rows and user specified bins
binWidth = floor(length(sortedVals)/(nbins-1));

% find out the remainder number of rows
remainderRows = length(sortedVals) - (binWidth*(nbins-1)) - 1;

% divide numeric array into a cell array such that:
% the first bin contains the first value
% (2:end-2) bins are equal in size, and
% the end bin contains the remainder rows as well
binContents = mat2cell(sortedVals,[ones(1,1), binWidth*ones(1,nbins-2), binWidth*ones(1,1)+remainderRows]);

% find the value in the last row of every cell
out = cellfun(@(x) x(end,:),binContents,'UniformOutput',false);
out = vertcat(out{:});

% re-assign the rows to the colormap
outcmap = incmap(out,:);
end

