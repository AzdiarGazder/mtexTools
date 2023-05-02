function imageResize
%% Function description:
% Interactively resize an image. This function may be used in conjunction
% with ebsd map data to correct for drift during map acquisition.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  imageResize
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

% Enable the user to interactively resize the image
while true
    % Step 3: Display the original (and subsequently resized) image
    im = imshow(img);

    % Step 4: Calculate the size of the original (and subsequently
    % resized) image
    imgSize = size(img);
    imgWidth = imgSize(2);
    imgHeight = imgSize(1);

    % Step 5: Create an interactive rectangular selection using imrect
    hRect = imrect(gca, [1, 1, imgWidth-1, imgHeight-1]);

    % Step 6: Wait for the user to finish adjusting the rectangle
    wait(hRect);

    % Step 7: Get the updated rectangle position
    rectPosition = hRect.getPosition();

    % Step 8: Calculate the new size of the image based on the selected
    % rectangle
    rectWidth = round(rectPosition(3));
    rectHeight = round(rectPosition(4));

    % Step 9: Resize the image
    % % This method does not maintain aspect ratio or avoid distortion
    % resizedImg = imresize(img, [rectHeight rectWidth]);
    % This method maintains aspect ratio or avoid distortion
    scaleFactor = min(rectWidth/imgWidth,rectHeight/imgHeight);
    resizedImg = imresize(img,scaleFactor);


%     % Step 9: Resize and transform the image
%     % Define the transformation matrix for the selected rectangle
%     T = [rectWidth/imgWidth       0                         0;...
%          0                        rectHeight/imgHeight      0;...
%          rectPosition(1)/imgWidth rectPosition(2)/imgHeight 1];
%     % Apply an affine transformation to the image
%     resizedImg = imwarp(img, affine2d(T), 'OutputView', imref2d(size(img)));
%     % Remove the blank space (black pixels)
%     cropUpper = max(find(diag(resizedImg) ~= 0));
%     cropLower = min(find(diag(resizedImg) ~= 0));
%     cropDiff = cropUpper - cropLower;
%     resizedImg = imcrop(resizedImg, [cropLower, cropLower, cropDiff, cropDiff]);


    % Step 10: Clear the image from Step 3
    delete(im);

    % Step 11: Update the original image matrix
    img = resizedImg;
    size(img)
end
end