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

% generate a linearly spaced [n x 1] vector of row indices based on:
% an interval = 1:maximum number of rows as the input colormap
% the spacing between the points = (length(incmap)-1)/(nbins-1)
out = [linspace(1,length(incmap),nbins)]';

% convert the row indices between 2:end-1 to integers
out(2:end-1,1) = round(out(2:end-1,1));

% re-assign the row indices to the colormap
outcmap = incmap(out,:);
end

