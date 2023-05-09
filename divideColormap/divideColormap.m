function outcmap = divideColormap(incmap,nbins)
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


% make a numeric array with the same number of rows as the input colormap
sortedVals = [1:length(incmap)]';
% compute the bin width based on the number of rows and user specified bins
binWidth = floor(length(sortedVals)/nbins);
% find out the remainder number of rows
remainderRows = length(sortedVals) - (binWidth*nbins);
% divide numeric array into a cell array such that:
% (1:end-1) bins are equal in size, and
% the end bin contains the remainder rows as well
binContents = mat2cell(sortedVals,[binWidth*ones(1,nbins-1), binWidth*ones(1,1)+remainderRows]);
% find the value in the last row of every cell
out = cellfun(@(x) x(end,:),binContents,'UniformOutput',false);
out = vertcat(out{:});
% re-assign the rows to the colormap
outcmap = incmap(out,:);
end

