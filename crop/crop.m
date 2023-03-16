function outebsd = crop(inebsd,varargin)
%% Function description:
% Crop, cut-out or make a subset of ebsd map data from within a 
% user-specified rectangular, circular,polygonal or freehand area-based 
% region of interest (ROI).
% Instructions on script use are provided in the window titlebar.
%
%% Note to users:
% Gridify the "outebsd" variable of irregularly cropped maps before saving
% as a *.ctf file.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  [ebsd] = crop(ebsd)
%
%% Input:
%  ebsd       - @EBSD
%
%% Output:
%  ebsd       - @EBSD
%
%% Options:
%  'rectangle', or
%  'circle', or
%  'polygon', or
%  'area'     -  @char,    define the ROI shape
%  polySides  -  @numeric, define the number of sides of a polygon
%  color      -  @numeric, define the colour of the ROI line
%  lineWidth  -  @numeric, define the width of the ROI line
%  lineStyle  -  @char,    define the style of the ROI line, types = '-','--',':', or '-.'
%
%%

if isempty(inebsd), return; end

if ~isa(inebsd,'EBSD')
    error('Map to crop must be an EBSD variable.');
    return;
end

polySides = [];
if ~isempty(varargin) && check_option(varargin,'rectangle')
    cropType = "rectangle";
elseif  ~isempty(varargin) && check_option(varargin,'circle')
    cropType = "circle";
elseif ~isempty(varargin) && check_option(varargin,'polygon')
    cropType = "polygon";
    polySides = get_option(varargin,'polygon');
    % check if polySides is a numeric variable and >= 3
    if ~isnumeric(polySides)
        error('Argument ''polygon'': Number of sides not specified.');
        return;
    elseif isnumeric(polySides) && polySides < 3
        error('Argument ''polygon'': Number of sides must be >= 3.');
        return;
    end
elseif  ~isempty(varargin) && check_option(varargin,'area')
    cropType = "area";
elseif isempty(varargin)
    warning('ROI shape not specified. Default ROI shape = rectangle.');
    cropType = "rectangle";
elseif ~isempty(varargin) && (~check_option(varargin,'rectangle') || ~check_option(varargin,'circle') || ~check_option(varargin,'polygon') || ~check_option(varargin,'area'))
    warning('ROI shape not specified. Default ROI shape = rectangle.');
    cropType = "rectangle";
end


% define shape line options
lineColor = get_option(varargin,'color',[1 0 0]);
lineWidth = get_option(varargin,'lineWidth',2);
lineStyle = get_option(varargin,'lineStyle','-');


% gridify ebsd map data
% While MTex's default "gridify.m" is used here, the command could result
% in Nan pixels. In such cases, it is recommended to use the modified
% "gridify2.m" instead. Click the link to find the "gridify2.m" script.
% % https://github.com/mtex-toolbox/mtex/issues/471
[gebsd,~] = gridify(inebsd);


% create a new user-defined plot
mtexFig = newMtexFigure;

if nargin>=1 && isa(varargin{1},'logical')
%     disp('logical');
    varargin{1} = double(varargin{1});
end

if nargin>=1 && isa(varargin{1},'orientation')
%     disp('orientation');
    plot(gebsd,gebsd.orientations);

elseif nargin>=1 && isa(varargin{1},'crystalShape')
%     disp('crystalShape');
    cS = varargin{1};
    plot(gebsd.prop.x,gebsd.prop.y,zUpDown * cS.diameter,gebsd.orientations * cS,varargin{2:end});

elseif nargin>=1 && isnumeric(varargin{1})
%     disp('numeric');
    % when map data input only contains information on 'indexed' pixels
    % reshape indices row-wise into a single column array
    if any(ismember(fields(gebsd.prop),'oldId'))
        idxMatrix = reshape(gebsd.prop.oldId',[],1); 
    elseif any(ismember(fields(gebsd.prop),'grainId'))
        idxMatrix = reshape(gebsd.prop.grainId',[],1); 
    elseif any(ismember(fields(gebsd.prop),'imagequality'))
        idxMatrix = reshape(gebsd.prop.imagequality',[],1);
    elseif any(ismember(fields(gebsd.prop),'iq'))
        idxMatrix = reshape(gebsd.prop.iq',[],1);
    elseif any(ismember(fields(gebsd.prop),'confidenceindex'))
        idxMatrix = reshape(gebsd.prop.confidenceindex',[],1);
    elseif any(ismember(fields(gebsd.prop),'ci'))
        idxMatrix = reshape(gebsd.prop.ci',[],1);
    elseif any(ismember(fields(gebsd.prop),'fit'))
        idxMatrix = reshape(gebsd.prop.fit',[],1);
    elseif any(ismember(fields(gebsd.prop),'semsignal'))
        idxMatrix = reshape(gebsd.prop.semsignal',[],1);
    elseif any(ismember(fields(gebsd.prop),'bc'))
        idxMatrix = reshape(gebsd.prop.bc',[],1);
    elseif any(ismember(fields(gebsd.prop),'bs'))
        idxMatrix = reshape(gebsd.prop.bs',[],1);
    elseif any(ismember(fields(gebsd.prop),'mad'))
        idxMatrix = reshape(gebsd.prop.mad',[],1);
    elseif any(ismember(fields(gebsd.prop),'error'))
        idxMatrix = reshape(gebsd.prop.error',[],1);
    end
    gebsdProperty = nan(size(idxMatrix)); % define an array of NaNs
    gebsdProperty(~isnan(idxMatrix)) = varargin{1}; % replace numeric values into the NaN array
    gebsdProperty = reshape(gebsdProperty,size(gebsd,2),size(gebsd,1)).'; % reshape NaN-numeric array row-wise
    plot(gebsd,gebsdProperty);

else
%     disp('phaseId');
    plot(gebsd,gebsd.phaseId)
end


% % https://au.mathworks.com/matlabcentral/answers/325754-how-to-stop-while-loop-by-right-mouse-button-click
ax = gca;
f = ancestor(ax,'figure');
if cropType == "rectangle"
    set(f,'Name',...
        'Band contrast map: Left-click to select two points defining the diagonal of a rectangular ROI to crop from the ebsd map.',...
        'NumberTitle','on');
elseif cropType == "circle"
    set(f,'Name',...
        'Band contrast map: Left-click to select two points defining the center & radius of a circular ROI to crop from the ebsd map.',...
        'NumberTitle','on');
elseif cropType == "polygon"
    set(f,'Name',...
        'Band contrast map: Left-click to select two points defining the center & extent of a polygonal ROI to crop from the ebsd map.',...
        'NumberTitle','on');
elseif cropType == "area"
    set(f,'Name',...
        'Band contrast map: Left-click to select points defining a polygonal ROI to crop from the ebsd map. Right-click to end selection.',...
        'NumberTitle','on');
end
xy = [];
hold(ax,'all');
while true
    in = ginput(1); % input using left-click
    selectType = get(f,'SelectionType');
    if strcmpi(selectType,'alt'); break; end % exit loop on right-click for freehand area ROIs
    scatter(in(1),in(2),...
        'MarkerEdgeColor',[0 0 0],...
        'MarkerFaceColor',[0 0 0],...
        'LineWidth',lineWidth); % plot the point
    xy = [xy;in]; % add point to array
    if size(xy,1) == 2 && (cropType == "rectangle" || cropType == "circle" || cropType == "polygon"); break; end % exit loop for rectangular, circlular or polygonal ROIs
end

% prevent further clicks by the user
disableDefaultInteractivity(ax);

% freeze the x and y axes to ensure the drawn shapes do not spill over
% the ebsd map boundaries
% ax.XLimMode = 'manual';
% ax.YLimMode = 'manual';
axis manual;

% check if xy coordinates are within the map bounds
if size(inebsd.unitCell,1) == 6 %hexGrid
    gebsd.opt.xmin = min(min(gebsd.prop.x));
    gebsd.opt.xmax = max(max(gebsd.prop.x));
    gebsd.opt.ymin = min(min(gebsd.prop.y));
    gebsd.opt.ymax = max(max(gebsd.prop.y));

    xy((xy(:,1)<=gebsd.opt.xmin),1) = gebsd.opt.xmin;
    xy((xy(:,1)>=gebsd.opt.xmax),1) = gebsd.opt.xmax;
    xy((xy(:,2)<=gebsd.opt.ymin),2) = gebsd.opt.ymin;
    xy((xy(:,2)>=gebsd.opt.ymax),2) = gebsd.opt.ymax;

    % calculate the closest multiple of xy values based on the map step size
    stepSizeX = gebsd.dx;
    stepSizeY = gebsd.dy;
    xy(:,1) = stepSizeX.*round(xy(:,1)./stepSizeX);
    xy(:,2) = stepSizeY.*round(xy(:,2)./stepSizeY);

else %squareGrid
    xy((xy(:,1)<=gebsd.xmin),1) = gebsd.xmin;
    xy((xy(:,1)>=gebsd.xmax),1) = gebsd.xmax;
    xy((xy(:,2)<=gebsd.ymin),2) = gebsd.ymin;
    xy((xy(:,2)>=gebsd.ymax),2) = gebsd.ymax;

    % calculate the closest multiple of xy values based on the map step size
    stepSize = gebsd.dx;
    xy = stepSize.*round(xy./stepSize);
end


% calculate the xy coordinates of the shape outline
if cropType == "rectangle"
    % check the start and end y-coordinates
    % ensure the end y-coordinate is always larger than the start y-coordinate
    xy = sortrows(xy,2);
    % define an array with all 5 points of the rectangle (ccw from top left)
    xy(3,:) = xy(2,:);
    xy(2,:) = [xy(3,1), xy(1,2)];
    xy(4,:) = [xy(1,1), xy(3,2)];
    xy(5,:) = xy(1,:); % repeat the first point to close the shape

elseif cropType == "circle" || cropType == "polygon"
    xc = xy(1,1); % circle x-center
    yc = xy(1,2); % circle y-center
    r = sqrt((xy(2,1)-xy(1,1))^2 + (xy(2,2)-xy(1,2))^2); % circle radius
    % calculate the coordinates of the circumference
    if cropType == "circle"
        theta = (0:(2*pi)/360:2*pi)'; % the first and last points are repeated to close the shape
    elseif cropType == "polygon"
        theta = (0:(2*pi)/polySides:2*pi)'; % the first and last points are repeated to close the shape
    end
    xyCircumference = [(r*cos(theta)+xc), (r*sin(theta)+yc)];
    % calculate the closest multiple of xyCircumference values based on
    % the map step size
    if size(inebsd.unitCell,1) == 6 %hexGrid
        xyCircumference(:,1) = stepSizeX.*round(xyCircumference(:,1)./stepSizeX);
        xyCircumference(:,2) = stepSizeY.*round(xyCircumference(:,2)./stepSizeY);
    else %squareGrid
        xyCircumference = stepSize.*round(xyCircumference./stepSize);
    end
    % define array with all points of the circle
    xy = [xy; xyCircumference];

elseif cropType == "area"
    % sort coordinates via the travelling salesman problem
    % the algorithm returns the area outline
    xy = tsp(xy); % the first and last points are repeated to close the shape
end

% plot the ROI shape
if cropType == "rectangle" || cropType == "area"
    % plot the rectangular or freehand ROI
    plot(xy(:,1),xy(:,2),'color',lineColor,'linewidth',lineWidth,'linestyle',lineStyle);
    % overlay the refined points
    scatter(xy(:,1),xy(:,2),...
        'MarkerEdgeColor',lineColor,...
        'MarkerFaceColor',lineColor,...
        'LineWidth',lineWidth);

elseif cropType == "circle" || cropType == "polygon"
    % plot the circular ROI
    if cropType == "circle"
        plot(xy(1:2,1),xy(1:2,2),'color',lineColor,'linewidth',lineWidth,'linestyle',lineStyle);
    end
    plot(xy(3:end,1),xy(3:end,2),'color',lineColor,'linewidth',lineWidth,'linestyle',lineStyle);
    % overlay the refined points
    if cropType == "circle"
        scatter(xy(1:2,1),xy(1:2,2),...
            'MarkerEdgeColor',lineColor,...
            'MarkerFaceColor',lineColor,...
            'LineWidth',lineWidth);
    elseif cropType == "polygon"
        scatter(xy(1,1),xy(1,2),...
            'MarkerEdgeColor',lineColor,...
            'MarkerFaceColor',lineColor,...
            'LineWidth',lineWidth);
    end
end
hold(ax,"off")

% logical check for ebsd map data inside/outside the rectangular,
% circular, polygonal or freehand area ROI
XX = gebsd.prop.x;
YY = gebsd.prop.y;
if cropType == "rectangle" || cropType == "area"
    [logChk,~] = inpolygon(XX(:),YY(:),xy(:,1),xy(:,2));

elseif cropType == "circle" || cropType == "polygon"
    [logChk,~] = inpolygon(XX(:),YY(:),xy(3:end,1),xy(3:end,2));
end

% define a new ebsd variable of cropped ebsd map data
temp_outebsd = gebsd(logChk);

% un-gridify the cropped ebsd map data
outebsd = EBSD(temp_outebsd);

% if nargout == 0 % check if the user has not specified an output variable
%     assignin('base','ebsdCrop',outebsd);
% end

end
%% ---


%% ---
function outXY = tsp(inXY)

%% Travelling salesman problem
% Copyright (c) 2009, Aleksandar Jevtic
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
% * Redistributions of source code must retain the above copyright 
% notice, this list of conditions and the following disclaimer.
% * Redistributions in binary form must reproduce the above copyright 
% notice, this list of conditions and the following disclaimer in 
% the documentation and/or other materials provided with the 
% distribution
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER AS IS AND ANY EXPRESS
% OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
% OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
% STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
% ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%%

numXY = size(inXY,1);
distXY = pdist(inXY);
distXY = squareform(distXY);
distXY(distXY==0) = realmax;
shortestPathLength = realmax;

for ii = 1:numXY
    startXY = ii;
    path = startXY;
    distanceTraveled = 0;
    distancesNew = distXY;
    currentXY = startXY;
    for jj = 1:numXY-1
        [~,nextXY] = min(distancesNew(:,currentXY));
        if (length(nextXY) > 1)
            nextXY = nextXY(1);
        end
        path(end+1,1) = nextXY;
        distanceTraveled = distanceTraveled +...
            distXY(currentXY,nextXY);
        distancesNew(currentXY,:) = realmax;
        currentXY = nextXY;
    end
    path(end+1,1) = startXY;
    distanceTraveled = distanceTraveled +...
        distXY(currentXY,startXY);
    if (distanceTraveled < shortestPathLength)
        shortestPathLength = distanceTraveled;
        shortestPath = path;
    end
end
xd = []; yd = [];
for ii = 1:(numXY+1)
    xd(ii) = inXY(shortestPath(ii),1);
    yd(ii) = inXY(shortestPath(ii),2);
end
outXY = [xd;yd]';
end
%% ---
