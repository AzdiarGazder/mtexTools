function h = plotMarker(xData,yData,varargin)
%% Function description:
% Plots a line plot using customised markers.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Version(s):
% The first version of this function was posted in:
% https://au.mathworks.com/matlabcentral/fileexchange/39487-custom-marker-plot?s_tid=prof_contriblnk
%
%% Syntax:
%  plotMarker(xData,yData,varargin) 
%
%% Input:
%  xData               - @double
%  yData               - @double
%
%% Options:
% lineStyle        - @char, Defines the line style
%                    '-'     = solid
%                    ':'     = dotted
%                    '-.'    = dashdot 
%                    '--'    = dashed   
%                    (none)  = no line
% lineColor        - @double, Defines the line [RGB] color
% lineWeight       - @double, Defines the line weight
% marker           - @char, Defines the marker type
%                    'c'     = circle
%                    'o'     = octagon
%                    'h'     = hexagon
%                    'p'     = pentagon
%                    'd'     = diamond
%                    's'     = square
%                    'e'     = equilateral triangle
%                    '^'     = isosceles triangle (up)
%                    'v'     = isosceles triangle (down)
%                    '<'     = isosceles triangle (left)
%                    '>'     = isosceles triangle (right)
%                    '*'     = star
%                    '+'     = cross
%                    'x'     = x-mark
% innermarker      - Flag for an inner marker
% sizeFactor       - Size of the inner marker
% markerStep       - Defines the angular step size by which the marker is
%                    rotated
% markerEdgeColor  - @double, Defines the marker edge [RGB] color
% markerFaceColor  - @double, Defines the marker face [RGB] color
% 
%%



%% Check for the input data
if ~isvector(xData) || ~isvector(yData) || length(xData) ~= length(yData)
    error('Error. xData and yData must be of the same length.');
    return;
end

%% Define the lineStyle
flagLineStyle = check_option(varargin,'lineStyle');
if flagLineStyle
    lineStyle = varargin{find_option(varargin,'lineStyle') + 1};
    if ~ischar(lineStyle)
        lineStyle = '-';
    end
end

%% Define the lineColor
flagLineColor = check_option(varargin,'lineColor');
if flagLineColor
    lineColor = varargin{find_option(varargin,'lineColor') + 1};
    if ~isnumeric(lineColor)
        lineColor = [0, 0.4470, 0.7410];
    end
end

%% Define the lineWidth
flagLineWidth = check_option(varargin,'lineWidth');
if flagLineWidth
    lineWidth = varargin{find_option(varargin,'lineWidth') + 1};
    if ~isnumeric(lineWidth)
        lineWidth = 1;
    end
end

%% Define the markerType
markerType = get_option(varargin,'marker','c');

%% Check for an inner marker and its sizeFactor
flagInnerMarker = check_option(varargin,'innerMarker');
if flagInnerMarker
    sizeFactor = varargin{find_option(varargin,'innerMarker') + 1};
    if ~isnumeric(sizeFactor)
        sizeFactor = 0.5;
    end
else
    sizeFactor = 0;
end

%% Check for markerStep
flagMarkerStep = check_option(varargin,'markerStep');
if flagMarkerStep
    markerStep = varargin{find_option(varargin,'markerStep') + 1};
    if ~isnumeric(markerStep)
        markerStep = 45*degree;
    end
end

%% Define the markerEdgeColor
markerEdgeColor = get_option(varargin,'markerEdgeColor',[0 0 0]);

%% Define the markerFaceColor
markerFaceColor = get_option(varargin,'markerFaceColor',[1 1 0]);

%% Define the markerSize
markerSize = get_option(varargin,'markerSize',1);


%% Make the marker shape
switch markerType
    case {'c'}
        [X,Y] = markerMaker(1*degree,0,flagInnerMarker,sizeFactor);

    case {'o'}
        [X,Y] = markerMaker(45*degree,0,flagInnerMarker,sizeFactor);

    case {'h'}
        [X,Y] = markerMaker(60*degree,0,flagInnerMarker,sizeFactor);

    case {'p'}
        [X,Y] = markerMaker(70*degree,0,flagInnerMarker,sizeFactor);

    case {'d'}
        [X,Y] = markerMaker(90*degree,0,flagInnerMarker,sizeFactor);

    case {'s'}
        [X,Y] = markerMaker(90*degree,0,flagInnerMarker,sizeFactor);
        XY = [X(:),Y(:)];
        rot = 45*degree;
        R = [cos(rot) -sin(rot); sin(rot) cos(rot)];
        % rotate point(s) counterclockwise
        temp = (R*XY')';
        X = temp(:,1);
        Y = temp(:,2);

    case {'e'}
        [X,Y] = markerMaker(120*degree,0,flagInnerMarker,sizeFactor);

    case {'^'}
        [X,Y] = markerMaker(120*degree,0,flagInnerMarker,sizeFactor);
        Y = 1./Y;

    case {'v'}
        [X,Y] = markerMaker(120*degree,0,flagInnerMarker,sizeFactor);
        X = -X; Y = -1./Y;

    case {'<'}
        [X,Y] = markerMaker(120*degree,1,flagInnerMarker,sizeFactor);
        X= -1./X; Y = -Y;

    case {'>'}
        [X,Y] = markerMaker(120*degree,1,flagInnerMarker,sizeFactor);
        X= 1./X;

    case {'s','*'}
        % for even indices
        ii = 1:10; idx = mod(ii, 2) == 0;
        X(idx) = 2/5 * cos(pi/2 + (ii(idx)-1) * pi/5);
        Y(idx) = 2/5 * sin(pi/2 + (ii(idx)-1) * pi/5);
        % for odd indices
        X(~idx) = cos(pi/2 + (ii(~idx)-1) * pi/5);
        Y(~idx) = sin(pi/2 + (ii(~idx)-1) * pi/5);

    case {'+'}
        X = [-0.5 +0.5 +0.5 +1.5 +1.5 +0.5 +0.5 -0.5 -0.5 -1.5 -1.5 -0.5 -0.5]';
        Y = [-1.5 -1.5 -0.5 -0.5 +0.5 +0.5 +1.5 +1.5 +0.5 +0.5 -0.5 -0.5 -1.5]';

    case {'x'}
        X = [-0.5 +0.5 +0.5 +1.5 +1.5 +0.5 +0.5 -0.5 -0.5 -1.5 -1.5 -0.5 -0.5]';
        Y = [-1.5 -1.5 -0.5 -0.5 +0.5 +0.5 +1.5 +1.5 +0.5 +0.5 -0.5 -0.5 -1.5]';
        XY = [X(:),Y(:)];
        rot = 45*degree;
        R = [cos(rot) -sin(rot); sin(rot) cos(rot)];
        % rotate point(s) counterclockwise
        temp = (R*XY')';
        X = temp(:,1);
        Y = temp(:,2);
end
XY = [X(:),Y(:)];

%% Rotate the marker as per user specification and normalize to unit size
if flagMarkerStep == 1
    rotXY = [];
    for rot = 0:markerStep:360*degree
        R = [cos(rot) -sin(rot); sin(rot) cos(rot)];
        % rotate point(s) counterclockwise
        temp = R*XY';
        rotXY = [rotXY, temp];
    end
    clear XY;
    XY = rotXY';
    XY = XY./norm(XY); % normalize to unit size
else
    XY = XY./norm(XY); % normalize to unit size
end


%% Plot the line and the markers
% ---
xData = reshape(xData,length(xData),1);
yData = reshape(yData,length(yData),1);
markerDataX = markerSize * reshape(XY(:,1),1,length(XY(:,1)));
markerDataY = markerSize * reshape(XY(:,2),1,length(XY(:,2)));
% ---
vertX = repmat(markerDataX,length(xData),1); vertX = vertX(:);
vertY = repmat(markerDataY,length(yData),1); vertY = vertY(:);
% ---
vertX = repmat(xData,length(markerDataX),1) + vertX;
vertY = repmat(yData,length(markerDataY),1) + vertY;
% ---
faces = 0:length(xData):length(xData)*(length(markerDataY)-1);
faces = repmat(faces,length(xData),1);
faces = repmat((1:length(xData))',1,length(markerDataY)) + faces;
% ------
h = figure; box on; 
plot(xData,yData,'lineStyle',lineStyle,'Color',lineColor,'LineWidth',lineWidth);
pHandle = patch('Faces',faces,'Vertices',[vertX vertY]);
set(pHandle,'FaceColor',markerFaceColor,'EdgeColor',markerEdgeColor) ;
axis equal;
box on; grid on;

end


function [X,Y] = markerMaker(thetaStep,flagFlip,flagInnerMarker,sizeFactor)
theta = 0:thetaStep:360*degree;

if flagFlip == 0
    X = sin(theta);
    Y = cos(theta);
elseif flagFlip == 1
    X = cos(theta);
    Y = sin(theta);
end

X = X(:); Y = Y(:);

if flagInnerMarker == 1
    Xi = sizeFactor.*X;
    Yi = sizeFactor.*Y;
    X = [X; Xi(:)];
    Y = [Y; Yi(:)];
end
end

