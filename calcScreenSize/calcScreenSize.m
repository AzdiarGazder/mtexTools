function screenSize = calcScreenSize(varargin)
%% Function description:  
% This function calculates the screen size for all detected screens on 
% the system in various units such as pixels, inches, centimeters, 
% normalized units, points, or characters. 
% It accounts for system scaling factors specific to different platforms
% and can either include or exclude the taskbar size from the screen area. 
% The returned screen size can be specified in different units depending 
% on user input.  
%  
%% Note to users:  
% The function uses Java's GraphicsEnvironment and Toolkit to retrieve 
% screen and taskbar dimensions.  
%  
%% Author:
% Dr. Azdiar Gazder, 2024, azdiaratuowdotedudotau
%
%% Acknowledgements:    
% Based on a MathWorks MATLAB community post located at:
% https://au.mathworks.com/matlabcentral/answers/312738-how-to-get-real-screen-size
%    
%% Syntax:  
%  screenSize = calcScreenSize()  
%  screenSize = calcScreenSize('unit', 'inches', 'type', 'include')  
%  
%% Input:
% 
%  
%% Output:  
%  screenSize    -  Screen size in the specified units or a structure 
%                   containing the screen size in all supported units 
%                   if no unit is specified.  
%  
%% Options:  
%  'unit'        -  @char, optional, specifies the unit for the returned 
%                   screen size. Supported units include:  
%                       - 'pixels' 
%                       - 'scaled' (default, system-scaled pixels)  
%                       - 'inches'  
%                       - 'centimeters'  
%                       - 'normalized' or 'normalised' (relative to 
%                         the main screen size)  
%                       - 'points'  
%                       - 'characters' (approximates the number of 
%                         characters fitting on the screen)  
%  'type'        -  @char, optional, specifies whether to include or 
%                   exclude the taskbar in the screen size calculation. 
%                   Supported types:  
%                       - 'include' (default)  
%                       - 'exclude'
%
%%

units = get_option(varargin,'unit',[]);
type = get_option(varargin,'type','include');

% Get the screen resolution (pixels per inch)
screenPixelsPerInch = java.awt.Toolkit.getDefaultToolkit().getScreenResolution();

% Calculate system scaling
if ispc
    scalingFactor = screenPixelsPerInch / 96;
elseif ismac
    scalingFactor = screenPixelsPerInch / 72;
elseif isunix
    scalingFactor = 1;
else
    error('Unsupported operating system');
end

% Get screen devices
screenDevices = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment().getScreenDevices();

% Get main screen information for position reference
mainScreen = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice().getScreen() + 1;
mainBounds = screenDevices(mainScreen).getDefaultConfiguration().getBounds();

% Initialise output arrays
numScreens = numel(screenDevices);
screensInPixels = zeros(numScreens, 4);
screensInScaledPixels = zeros(numScreens,4);
screensInInches = zeros(numScreens, 4);
screensInCentimeters = zeros(numScreens, 4);
screensInNormalized = zeros(numScreens, 4);
screensInPoints = zeros(numScreens, 4);
screensInChars = zeros(numScreens, 4);

% Dynamically compute default character size
tempFig = figure('Visible', 'off'); % create a hidden figure to avoid showing it
tempText = uicontrol('Style', 'text', 'String', 'A', 'FontUnits', 'pixels'); % create a text control with a single character
textExtent = get(tempText, 'Extent'); % get the extent of the character "A" in pixels
defaultCharWidth = textExtent(3);  % width of the character in pixels
defaultCharHeight = textExtent(4); % height of the character in pixels
close(tempFig); % close the temporary figure

% Loop through all screen devices
for n = 1:numScreens
    bounds = screenDevices(n).getDefaultConfiguration().getBounds();
    % Screen size in pixels
    screensInPixels(n,:) = [bounds.getLocation().getX() + 1, ...  % x-position
        -bounds.getLocation().getY() + 1 - bounds.getHeight() + mainBounds.getHeight(), ... % y-position
        bounds.getWidth(), ...  % width in pixels
        bounds.getHeight()];    % height in pixels

    switch lower(type)
        case 'exclude'
            % Do nothing
        case 'include'
            screensInPixels(n,:) = getTaskbarOffset(screensInPixels(n,:),screenDevices(n));
    end

    % Screen size in scaled pixels
    % Apply scaling only to width and height
    screensInScaledPixels(n,:) = [screensInPixels(1:2), screensInPixels(:, 3:4) ./ scalingFactor];

    % Convert pixel values to inches
    screensInInches(n,:) = screensInPixels(n,:) / screenPixelsPerInch;

    % Convert pixel values to centimeters
    screensInCentimeters(n,:) = screensInInches(n,:) * 2.54;

    % Normalised values (relative to main screen size)
    screensInNormalized(n,:) = screensInPixels(n,:) ./ [mainBounds.getWidth(), ...  % x-position
        mainBounds.getHeight(), ... % y-position
        mainBounds.getWidth(), ...  % normalised width
        mainBounds.getHeight()];    % normalised height

    % Convert pixel values to points
    screensInPoints(n,:) = screensInInches(n,:) * 72;

    % Estimate screen size in characters
    screensInChars(n,:) = [screensInPixels(n,1) / defaultCharWidth, ...  % x-position
        screensInPixels(n,2) / defaultCharHeight, ... % y-position
        screensInPixels(n,3) / defaultCharWidth, ...  % width in characters
        screensInPixels(n,4) / defaultCharHeight];    % height in characters
end

% If specific units are requested, return only those units
% if nargin > 0
if ~isempty(units)
    switch lower(units)
        case 'pixels'
            screenSize = screensInPixels;
        case 'scaled'
            screenSize = screensInScaledPixels;
        case 'inches'
            screenSize = screensInInches;
        case 'centimeters'
            screenSize = screensInCentimeters;
        case {'normalized', 'normalised'}
            screenSize = screensInNormalized;
        case 'points'
            screenSize = screensInPoints;
        case 'characters'
            screenSize = screensInChars;
        otherwise
            warning('Unrecognized unit type. Returning scaled pixel values.');
            screenSize = screensInScaledPixels;
    end

else
    % Return all units by default if no unit type is specified
    screenSize = struct('pixels', screensInPixels,...
        'scaled', screensInScaledPixels,...
        'inches', screensInInches, ...
        'centimeters', screensInCentimeters,...
        'normalized', screensInNormalized, ...
        'points', screensInPoints,...
        'characters', screensInChars);
end

end




function currentScreenSize = getTaskbarOffset(currentFullScreenSize,currentScreenDevice)
% % Step 1: Get full screen size (including taskbar)
% currentFullScreenSize = get(0, 'ScreenSize'); % [x, y, width, height]

% Step 2: Use Java to get the available screen insets (for taskbar)
% currentScreenDevice = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment.getDefaultScreenDevice;
screenInsets = java.awt.Toolkit.getDefaultToolkit.getScreenInsets(currentScreenDevice.getDefaultConfiguration);

% Step 3: Check if the taskbar is hidden (all insets are zero)
if screenInsets.left == 0 && screenInsets.right == 0 && screenInsets.top == 0 && screenInsets.bottom == 0
    taskbarLocation = 'hidden';
    taskbarOffset = 0;

else
    % Step 4: Calculate available screen size by removing the taskbar insets
    availableScreenWidth = currentFullScreenSize(3) - (screenInsets.left + screenInsets.right);
    availableScreenHeight = currentFullScreenSize(4) - (screenInsets.top + screenInsets.bottom);

    % Step 5: Calculate the differences between full screen size and available screen size
    dx = currentFullScreenSize(3) - availableScreenWidth; % width difference (taskbar on the left or right)
    dy = currentFullScreenSize(4) - availableScreenHeight; % height difference (taskbar on the top or bottom)

    % Initialise taskbar variables
    taskbarLocation = 'unknown';
    taskbarOffset = 0;

    % Step 6: Infer taskbar location and calculate taskbar offset
    if screenInsets.left > 0
        taskbarLocation = 'left';
        taskbarOffset = screenInsets.left; % taskbar width on the left
    elseif screenInsets.right > 0
        taskbarLocation = 'right';
        taskbarOffset = screenInsets.right; % taskbar width on the right
    elseif screenInsets.top > 0
        taskbarLocation = 'top';
        taskbarOffset = screenInsets.top; % taskbar height on the top
    elseif screenInsets.bottom > 0
        taskbarLocation = 'bottom';
        taskbarOffset = screenInsets.bottom; % taskbar height on the bottom
    end

end
% % Display taskbar location and thickness
% disp('---');
% disp(['Taskbar location: ', taskbarLocation]);
% disp(['Taskbar thickness: ', num2str(taskbarOffset), ' pixels']);
% disp('---');


% Step 6: Adjust screenSize based on the taskbar location and offset
currentScreenSize = currentFullScreenSize;
switch lower(taskbarLocation)
    case 'hidden'
        % Do nothing

    case 'left'
        currentScreenSize(1) = currentScreenSize(1) + taskbarOffset;  % shift x-position
        currentScreenSize(3) = currentScreenSize(3) - taskbarOffset;  % reduce screen width

    case 'right'
        currentScreenSize(3) = currentScreenSize(3) - taskbarOffset;  % reduce screen width

    case 'top'
        currentScreenSize(2) = currentScreenSize(2) + taskbarOffset;  % shift y-position
        currentScreenSize(4) = currentScreenSize(4) - taskbarOffset;  % reduce screen height

    case 'bottom'
        currentScreenSize(4) = currentScreenSize(4) - taskbarOffset;  % reduce screen height

    otherwise
        % No taskbar or unknown location, no changes
        error('Taskbar location unknown.');

end
% % Display the adjusted values
% disp(['Adjusted x-position: ', num2str(screenSize(1))]);
% disp(['Adjusted y-position: ', num2str(screenSize(2))]);
% disp(['Adjusted screen width: ', num2str(screenSize(3)), ' pixels']);
% disp(['Adjusted screen height: ', num2str(screenSize(4)), ' pixels']);
% disp('---');
end