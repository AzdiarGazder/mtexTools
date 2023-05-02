function imageTransform
%% Function description:
% Interactively projective or affine transform an image. This function is
% to be used in conjunction with ebsd map data to correct for drift during
% map acquisition.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  imageTransform
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

clear all; clear hidden; close all; clc;

% Step 1: Input an image and convert to grayscale
img = imread('Zircon-grain-FSEI.tif');
img = rgb2gray(img(:,:,1:3));

% Step 2: Create a figure
figure
% plot(ebsd,ebsd.bc,'micronbar','off');
hold all

while true
    % Step 3: Show the image
    im = imshow(img);
    %     im.AlphaData = 0.33;

    % Step 4: Find the coordinates of the 4 corners of the image
    [rows,cols,~] = size(img);
    cornerCoords = [1, 1;...
        1, rows;...
        cols, rows;...
        cols, 1];

    % Step 5: Overlay 4 blue circles at the coordinates of the 4 corners
    % of the image
    hold all;
    for ii = 1:4
        plot(cornerCoords(ii,1),cornerCoords(ii,2),...
            'bo','MarkerSize',8,'LineWidth',1.5);
    end

    % Step 6: Overlay a blue line going clockwise from one blue circle to
    % the next around all 4 blue circles
    for ii = 1:4
        if ii ~= 4
            line([cornerCoords(ii, 1),cornerCoords(ii+1, 1)],...
                [cornerCoords(ii, 2),cornerCoords(ii+1, 2)],...
                'Color','b','LineWidth',1.5);
        else
            line([cornerCoords(ii, 1),cornerCoords(1, 1)],...
                [cornerCoords(ii, 2),cornerCoords(1, 2)],...
                'Color','b','LineWidth',1.5);
        end
    end

    % Step 7: Wait for the user to click on any of the 4 blue circles and
    % drag each of them independently anywhere inside the image bounds
    [x, y] = ginput(1);
    [x_coords, y_coords] = deal(cornerCoords(:, 1),cornerCoords(:, 2));

    while true
        if norm([x, y] - [x_coords(1), y_coords(1)]) <= 20 % Check if user clicked on first blue circle
            [x_coords(1), y_coords(1)] = ginput(1);
        elseif norm([x, y] - [x_coords(2), y_coords(2)]) <= 20 % Check if user clicked on second blue circle
            [x_coords(2), y_coords(2)] = ginput(1);
        elseif norm([x, y] - [x_coords(3), y_coords(3)]) <= 20 % Check if user clicked on third blue circle
            [x_coords(3), y_coords(3)] = ginput(1);
        elseif norm([x, y] - [x_coords(4), y_coords(4)]) <= 20 % Check if user clicked on fourth blue circle
            [x_coords(4), y_coords(4)] = ginput(1);
        else % User clicked outside of blue circles, exit loop
            break;
        end

        % Step 8: Clear the image from Step 3
        delete(im);

        % Step 9: Projective or affine transform the image using the
        % coordinates in Step 4 as initial coordinates and the coordinates
        % in Step 7 as final coordinates
        tform = fitgeotrans(cornerCoords,[x_coords, y_coords],'projective'); % 'affine');
        transfImg = imwarp(img, tform,'OutputView',imref2d(size(img)));
    end
    
    % Step 10: Go to Step 3
    img = transfImg;
end
end