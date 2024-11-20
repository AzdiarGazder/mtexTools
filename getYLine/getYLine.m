function varargout = getYLine(varargin)
%GETYLINE Select horizontal polyline with mouse.
%   [X,Y] = GETYLINE(FIG) lets you select a horizontal polyline 
%   in the current axes of figure FIG using the mouse. Coordinates of 
%   the polyline are returned in X and Y. Once the initial Y-coordinate 
%   is selected, all subsequent points will have the same Y-coordinate, 
%   restricting the polyline to be horizontal.
%
%   Example
%   --------
%       imshow('moon.tif')
%       [x,y] = getYLine
%
%   See also GETLINE.

%   Based on the original GETLINE function.

global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_X GETLINE_Y
global GETLINE_ISCLOSED FIXED_Y

varargin = matlab.images.internal.stringToChar(varargin);

xlimorigmode = xlim('mode');
ylimorigmode = ylim('mode');
xlim('manual');
ylim('manual');

if ((nargin >= 1) && (ischar(varargin{end})))
    str = varargin{end};
    if (str(1) == 'c')
        % getYLine(..., 'closed')
        GETLINE_ISCLOSED = 1;
        varargin = varargin(1:end-1);
    end
else
    GETLINE_ISCLOSED = 0;
end

if ((length(varargin) >= 1) && ischar(varargin{1}))
    % Callback invocation: 'KeyPress', 'FirstButtonDown',
    % 'NextButtonDown', or 'ButtonMotion'.
    feval(varargin{:});
    return;
end

GETLINE_X = [];
GETLINE_Y = [];
FIXED_Y = [];

if (length(varargin) < 1)
    GETLINE_AX = gca;
    GETLINE_FIG = ancestor(GETLINE_AX, 'figure');
else
    if (~ishghandle(varargin{1}))
        CleanUp(xlimorigmode, ylimorigmode);
        error(message('images:getYLine:expectedHandle'));
    end

    switch get(varargin{1}, 'Type')
        case 'figure'
            GETLINE_FIG = varargin{1};
            GETLINE_AX = get(GETLINE_FIG, 'CurrentAxes');
            if (isempty(GETLINE_AX))
                GETLINE_AX = axes('Parent', GETLINE_FIG);
            end

        case 'axes'
            GETLINE_AX = varargin{1};
            GETLINE_FIG = ancestor(GETLINE_AX, 'figure');

        otherwise
            CleanUp(xlimorigmode, ylimorigmode);
            error(message('images:getYLine:expectedFigureOrAxesHandle'));
    end
end

% Remember initial figure state
state = uisuspend(GETLINE_FIG);

% Set up initial callbacks for the first stage
set(GETLINE_FIG, ...
    'Pointer', 'crosshair', ...
    'WindowButtonDownFcn', 'getYLine(''FirstButtonDown'');', ...
    'KeyPressFcn', 'getYLine(''KeyPress'');');

% Bring target figure forward
GETLINE_FIG.Visible = 'on'; % make sure Live Editor figures are shown
figure(GETLINE_FIG);

% Initialize the lines to be used for the drag
GETLINE_H1 = line('Parent', GETLINE_AX, ...
                  'XData', GETLINE_X, ...
                  'YData', GETLINE_Y, ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', 'k', ...
                  'LineStyle', '-');

GETLINE_H2 = line('Parent', GETLINE_AX, ...
                  'XData', GETLINE_X, ...
                  'YData', GETLINE_Y, ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', 'w', ...
                  'LineStyle', ':');

% We're ready; wait for the user to do the drag
errCatch = 0;
try
    waitfor(GETLINE_H1, 'UserData', 'Completed');
catch
    errCatch = 1;
end

if (errCatch == 1)
    errStatus = 'trap';
elseif (~ishghandle(GETLINE_H1) || ...
            ~strcmp(get(GETLINE_H1, 'UserData'), 'Completed'))
    errStatus = 'unknown';
else
    errStatus = 'ok';
    x = GETLINE_X(:);
    y = GETLINE_Y(:);
    if (isempty(x))
        x = zeros(0, 1);
    end
    if (isempty(y))
        y = zeros(0, 1);
    end
end

% Delete the animation objects
if (ishghandle(GETLINE_H1))
    delete(GETLINE_H1);
end
if (ishghandle(GETLINE_H2))
    delete(GETLINE_H2);
end

% Restore the figure's initial state
if (ishghandle(GETLINE_FIG))
   uirestore(state);
end

CleanUp(xlimorigmode, ylimorigmode);

% Return the answer or generate an error message
switch errStatus
    case 'ok'
        if (nargout >= 2)
            varargout{1} = x;
            varargout{2} = y;
        else
            varargout{1} = [x(:) y(:)];
        end

    case 'trap'
        error(message('images:getYLine:interruptedMouseSelection'));

    case 'unknown'
        error(message('images:getYLine:interruptedMouseSelection'));
end

%--------------------------------------------------
% Subfunction FirstButtonDown
%--------------------------------------------------
function FirstButtonDown %#ok

global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_X GETLINE_Y FIXED_Y

[x, y] = getcurpt(GETLINE_AX);

% check if GETLINE_X, GETLINE_Y is inside of axis
xlim = get(GETLINE_AX, 'xlim');
ylim = get(GETLINE_AX, 'ylim');
% Clamp x to axis limits
x = max(min(x, xlim(2)), xlim(1));  % Clamp x between xlim(1) and xlim(2)
% Clamp y to axis limits
y = max(min(y, ylim(2)), ylim(1));  % Clamp y between ylim(1) and ylim(2)

GETLINE_X = x;
FIXED_Y = y;  % Set the fixed Y-coordinate
GETLINE_Y = FIXED_Y;

set([GETLINE_H1 GETLINE_H2], ...
    'XData', GETLINE_X, ...
    'YData', GETLINE_Y, ...
    'Visible', 'on');

if (~strcmp(get(GETLINE_FIG, 'SelectionType'), 'normal'))
    set(GETLINE_H1, 'UserData', 'Completed');
else
    set(GETLINE_FIG, 'WindowButtonMotionFcn', 'getYLine(''ButtonMotion'');', ...
        'WindowButtonDownFcn', 'getYLine(''NextButtonDown'');');
end

%--------------------------------------------------
% Subfunction NextButtonDown
%--------------------------------------------------
function NextButtonDown %#ok

global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_X GETLINE_Y FIXED_Y

selectionType = get(GETLINE_FIG, 'SelectionType');
if (~strcmp(selectionType, 'open'))
    [x, ~] = getcurpt(GETLINE_AX);  % Ignore new Y, keep FIXED_Y

    % Clamp x to axis limits
    xlim = get(GETLINE_AX, 'xlim');
    x = max(min(x, xlim(2)), xlim(1));

    GETLINE_X = [GETLINE_X x];
    GETLINE_Y = [GETLINE_Y FIXED_Y];  % Keep Y constant

    set([GETLINE_H1 GETLINE_H2], 'XData', GETLINE_X, 'YData', GETLINE_Y);
end

if (~strcmp(get(GETLINE_FIG, 'SelectionType'), 'normal'))
    set(GETLINE_H1, 'UserData', 'Completed');
end

%-------------------------------------------------
% Subfunction ButtonMotion
%-------------------------------------------------
function ButtonMotion %#ok

global GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_X GETLINE_Y FIXED_Y

[newx, ~] = getcurpt(GETLINE_AX);  % Ignore new Y, use FIXED_Y

% Clamp newx to axis limits
xlim = get(GETLINE_AX, 'xlim');
newx = max(min(newx, xlim(2)), xlim(1));

x = [GETLINE_X newx];
y = [GETLINE_Y FIXED_Y];  % Keep Y constant

set([GETLINE_H1 GETLINE_H2], 'XData', x, 'YData', y);

%---------------------------------------------------
% Subfunction CleanUp
%--------------------------------------------------
function CleanUp(xlimmode, ylimmode)

xlim(xlimmode);
ylim(ylimmode);
clear global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
clear global GETLINE_X GETLINE_Y FIXED_Y
clear global GETLINE_ISCLOSED
