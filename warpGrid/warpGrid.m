function warpGrid
%% Demonstration description:
% This demonstration interactively warps a grid of X and Y co-ordinates. 
% When adapted as a function, it may be used in conjunction with ebsd map 
% data to correct for drift during map acquisition.
%
%% Author:
% Dr. Azdiar Gazder, 2024, azdiaratuowdotedudotau
%
%% Syntax:
%  warpGrid
%
%% Input:
%  none
%
%% Output:
%  none
%
%% Options:
%  none
%%

clear all; clear hidden; clc; close all

% Generate an initial equally spaced grid
[X, Y] = meshgrid(1:500, 1:250);

% Define the source grid
srcGrid = [X(:), Y(:)];

% Initialise the corner points of the source grid
srcSize = size(X);
srcPoints = [1, 1; srcSize(2), 1; srcSize(2), srcSize(1); 1, srcSize(1)];
wrpPoints = srcPoints;

% Initialise the figure
figure;
axis equal

hold on;
plot(srcGrid(:,1), srcGrid(:,2), 'b.');
hold off;

hold on;
h_src = plot(srcPoints(:,1), srcPoints(:,2), 'ro'); % Plot corner points
hold off;

% Initialise the transformation object and algorithm type
tform = [];
validTransStrings = {'projective','affine','similarity','nonreflectivesimilarity'};

% Loop until the user right-clicks
while true
    % Wait for user input
    [x, y, button] = ginput(2); % Get two mouse clicks

    % Check for a right-click
    if button(1) == 3 % 3 corresponds to right-click
        break; % Exit loop if right-click
    end

    % Check for a left-click
    if button(1) == 1 % 1 corresponds to left-click
        
        % Get the index of the closest corner point to the first click
        [~, idx] = min(pdist2(srcPoints, [x(1), y(1)]));

        % Update the selected corner point with the position of the second click
        wrpPoints(idx,:) = [x(2), y(2)];

        % Create a transformation object
        tform = fitgeotrans(srcPoints, wrpPoints, validTransStrings{1});

        % Apply the transformation to the initial grid points
        wrpGrid = transformPointsForward(tform, srcGrid);

        % Update srcGrid
        srcGrid = wrpGrid;

        % Update srcPoints
        srcPoints = wrpPoints;

        % Delete previously plotted srcGrid
        delete(findobj(gca, 'Type', 'scatter'));

        % Plot the new srcGrid
        plot(srcGrid(:, 1), srcGrid(:, 2), 'b.');
        axis equal
        
        % Delete and re-plot h_src
        delete(h_src);
        hold on;
        rotMat = [1 1; -1 1;-1 -1;  1 -1];
        [~, id] = min(srcGrid*rotMat.');
        kornerPoints = srcGrid(id,:);
        h_src = plot(kornerPoints(:,1), kornerPoints(:,2), 'ro'); % Plot corner points
        hold off;

    end
end

end