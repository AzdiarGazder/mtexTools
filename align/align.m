function outebsd = align(inebsd,varargin)
%% Function description:
% Align ebsd map data along a user-specified linear fiducial in case of 
% drift caused by the thermal cycling of scanning coil electronics during
% acquisition. The linear fiducial may correspond to a twin boundary, 
% stacking fault, or any linear-shaped deformation or phase transformation
% products.
% Instructions on script use are provided in the window titlebar.
%
%% Author:
% Dr. Azdiar Gazder, 2022, azdiaratuowdotedudotau
%
%% Acknowledgements: 
% Dr. David R.G. Mitchell, UOW 
% For the original DigitalMicrograph -based script in C for image 
% realignment along a user-defined linear fiducial
%
%% Syntax
%
%  [ebsd] = align(ebsd,numPixels)
%
% Input
%  ebsd      - @EBSD
%
% Output
%  ebsd      - @EBSD
%
% Options
%  pixels    - number of pixels defining the halfwidth on either side of 
%              the fiducial line
%%


numPixels = get_option(varargin,'pixels',15);


% Grid ebsd map data
% While MTex's default "gridify.m" can be used here, the command creates
% Nan pixels.
% It is recommended to use the modified "gridify2.m" instead.
[gebsd,~] = gridify2(inebsd);


mtexFig = newMtexFigure;
plot(gebsd,gebsd.bc)
colormap parula
ax = gca;
f = ancestor(ax,'figure');
set(f,'Name',...
    'Band contrast map: Left-click to select two points defining a line along a linear map feature.',...
    'NumberTitle','on');
% % https://au.mathworks.com/matlabcentral/answers/325754-how-to-stop-while-loop-by-right-mouse-button-click
xy1 = [];
hold(ax,'all');
while true
    in = ginput(1); % input using left-click
    selectType = get(f,'SelectionType');
    if strcmpi(selectType,'alt'); return; end % exit on right-click
    scatter(in(1),in(2),...
        'MarkerEdgeColor',[0 0 0],...
        'MarkerFaceColor',[0 0 0]); % plot the point
    xy1 = [xy1;in]; % add point to array
    if size(xy1,1) == 2; break; end % exit after 2 points have been inputted by the user
end

% Prevent further clicks by the user
disableDefaultInteractivity(ax);

% Check for start and end y-coordinates
% Ensure the end y-coordinate is always larger than the start y-coordinate
xy1 = sortrows(xy1,2);

% Check for xy coordinates within the map bounds
xy1((xy1(:,1)<=gebsd.xmin),1) = gebsd.xmin;
xy1((xy1(:,1)>=gebsd.xmax),1) = gebsd.xmax;
xy1((xy1(:,2)<=gebsd.ymin),2) = gebsd.ymin;
xy1((xy1(:,2)>=gebsd.ymax),2) = gebsd.ymax;

% Calculate the closest multiple of xy values based on the map step size
stepSize = calcStepSize(inebsd);
xy1 = stepSize.*round(xy1./stepSize);

% Plot the fiducial line
line(xy1(:,1),xy1(:,2),'color',[1 0 0 0.5],'linewidth',5)
hold all

% Calculate the equation of the fiducial line
deltaY = xy1(2,2)-xy1(1,2);
deltaX = xy1(2,1)-xy1(1,1);
slope = deltaY/deltaX;
perpSlope = -1/slope;
intercept = xy1(1,2)-(xy1(1,1)*slope);

% Define the start & end row indices of the fiducial line
startRowIdx = double(uint16(xy1(1,2)/stepSize));
endRowIdx = double(uint16(xy1(2,2)/stepSize));

% Define the half width for the line profile
halfWidth = numPixels*stepSize;

% Define the array containing the pixel shifts
pixelShift = zeros(fliplr(size(xy1(1,2):stepSize:xy1(2,2))));

for yy = xy1(1,2):stepSize:xy1(2,2)
    % Calculate the x-position on the line profile
    xx = (yy-intercept)/slope;
    left = xx - halfWidth;
    right = xx + halfWidth;
    
    % Check for left & right -most line profile coordinates within the map
    % bounds
    if left <= gebsd.xmin
        left = gebsd.xmin;
        right = halfWidth; %2*halfWidth;
    end
    if right >= gebsd.xmax
        right = gebsd.xmax;
        left = gebsd.xmax-halfWidth; %gebsd.xmax-(2*halfWidth);
    end
    
    % Define the start and end coordinates of the line profile
    xy2 = [left, yy;...
        right, yy];
    
    % Draw the line from which the line profile information is sought
    line(xy2(:,1),xy2(:,2),'color',[0.5 0.5 0.5 0.5],'linewidth',2.5);
    hold all;
    
    % Get the line profile information
    [gebsdLine2,~] = spatialProfile(gebsd,xy2);
    
    % Find the minimum band contrast value along the line profile
    % This corresponds to the linear boundary feature
    [~,minIdx] = min(gebsdLine2.bc);
    
    % Calculate current row index
    currentRowIdx = double(uint16(yy/stepSize))+1;
    
    % Calculate the number of pixels to shift the column data from the
    % center of the line profile
    arrayIdx = currentRowIdx-startRowIdx;
    midIdx = ceil(size(gebsdLine2.bc,1)/2);
    pixelShift(arrayIdx,1) = midIdx-minIdx;

    % Circularly shift columns left or right for each of the map elements
    % row-wise rotations
    gebsd.rotations(currentRowIdx,:) = circshift(gebsd.rotations(currentRowIdx,:),...
        [0,pixelShift(arrayIdx,1)]);
    % phase
    gebsd.phase(currentRowIdx,:) = circshift(gebsd.phase(currentRowIdx,:),...
        [0,pixelShift(arrayIdx,1)]);
%     % isIndexed
%     gebsd.isIndexed(currentRowIdx,:) = circshift(gebsd.isIndexed(currentRowIdx,:),...
%         [0,pixelShift(arrayIdx,1)]);
    % band contrast
    gebsd.prop.bc(currentRowIdx,:) = circshift(gebsd.prop.bc(currentRowIdx,:),...
        [0,pixelShift(arrayIdx,1)]);
    % band slope
    gebsd.prop.bs(currentRowIdx,:) = circshift(gebsd.prop.bs(currentRowIdx,:),...
        [0,pixelShift(arrayIdx,1)]);
    % error
    gebsd.prop.error(currentRowIdx,:) = circshift(gebsd.prop.error(currentRowIdx,:),...
        [0,pixelShift(arrayIdx,1)]);
    % mad
    gebsd.prop.mad(currentRowIdx,:) = circshift(gebsd.prop.mad(currentRowIdx,:),...
        [0,pixelShift(arrayIdx,1)]);

    progress(arrayIdx,(endRowIdx-startRowIdx+1));
    pause(0.0001);
end
hold off;

% phaseId
gebsd.phaseId = reshape((gebsd.phase+1),[numel(gebsd.phase),1]);

% f = figure;
% plot(gebsd,gebsd.bc)
% colormap parula
% set(f,'Name',...
% 'Band contrast map: Aligned along user-selected linear feature',...
% 'NumberTitle','on');

% Un-gridify the ebsd data
outebsd = EBSD(gebsd);

close all
end
% %---

