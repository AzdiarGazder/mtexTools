function outebsd = stitch(inebsd1,inebsd2,varargin)
%% Function description:
% Stitch, combine or merge two ebsd maps together into one map by defining
% a user-specified position and offset/overlay for map 2 relative to map 1.
%
%% Note to users:
% Gridify the "outebsd" variable before saving as a *.ctf file.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements:
% Based on Dr. Filippe Ferreira's issue #362 on the MTEX GitHub Issues
% webpage.
% https://github.com/mtex-toolbox/mtex/issues/362
%
%% Syntax:
%  [ebsd] = stitch(ebsd1,ebsd2,arg,array)
%
%% Input:
%  ebsd1       - @EBSD
%  ebsd2       - @EBSD
%  arg         - @char, defines the position of inebsd2 relative to inebsd1.
%                Options = 'north', 'south', 'east', 'west',
%                'northeast', 'southeast', 'northwest', 'southwest'
%  array       - @numeric, a 1 x 2 array defining an [x,y] offset and/or
%                overlay in pixels for ebsd2 relative to ebsd1.
%% Output:
%  ebsd        - @EBSD
%%


if any(strcmpi(varargin,'north')) ||...
        any(strcmpi(varargin,'south')) ||...
        any(strcmpi(varargin,'east')) ||...
        any(strcmpi(varargin,'west')) ||...
        any(strcmpi(varargin,'northeast')) ||...
        any(strcmpi(varargin,'southeast')) ||...
        any(strcmpi(varargin,'northwest')) ||...
        any(strcmpi(varargin,'southwest'))

    % find the map bounds
    %     bounds1 = inebsd1.extend; % [xmin, xmax, ymin, ymax]
    %     bounds2 = inebsd2.extend; % [xmin, xmax, ymin, ymax]
    % check for MTEX version
    chkVersion = '5.9.0';
    chkVerParts = getVersionParts(chkVersion);
    fid = fopen('VERSION','r');
    curVersion = fgetl(fid);
    fclose(fid);
    curVersion = erase(curVersion, 'MTEX ');
    curVerParts = getVersionParts(curVersion);

    if curVerParts(1) ~= chkVerParts(1)     % major version
        flagVersion = curVerParts(1) < chkVerParts(1);
    elseif curVerParts(2) ~= chkVerParts(2) % minor version
        flagVersion = curVerParts(2) < chkVerParts(2);
    else                                    % revision version
        flagVersion = curVerParts(3) < chkVerParts(3);
    end

    if flagVersion % for MTEX versions 5.8.2 and below
        bounds1 = inebsd1.extend; % [xmin, xmax, ymin, ymax]
        bounds2 = inebsd2.extend; % [xmin, xmax, ymin, ymax]
    else % for MTEX versions 5.9.0 and above
        bounds1 = inebsd1.extent; % [xmin, xmax, ymin, ymax]
        bounds2 = inebsd2.extent; % [xmin, xmax, ymin, ymax]
    end

    % find the map origin
    xMapDir = getMTEXpref('xAxisDirection');
    zMapDir = getMTEXpref('zAxisDirection');

    %% Define map2's bounds with respect to the map origin and user-specified offset/overlay
    if strcmpi(xMapDir,'north') && strcmpi(zMapDir,'intoPlane')
        warning(sprintf('\nMap 1 origin = south-west corner.\n+ve x-values = moves map 2 left relative to map 1.\n+ve y-values = moves map 2 down relative to map 1.'));

        if ~isempty(varargin) && check_option(varargin,'north')
            pixelShift = get_option(varargin,'north',[0,0]);
            arraySize(pixelShift);
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))];

        elseif ~isempty(varargin) && check_option(varargin,'south')
            pixelShift = get_option(varargin,'south',[0,0]);
            arraySize(pixelShift);
            if bounds1(2) <= bounds2(2)
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,2)), (0-pixelShift(1,1)) ];
            else
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'east')
            pixelShift = get_option(varargin,'east',[0,0]);
            arraySize(pixelShift);
            inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(bounds1(4)-pixelShift(1,1))];

        elseif ~isempty(varargin) && check_option(varargin,'west')
            pixelShift = get_option(varargin,'west',[0,0]);
            arraySize(pixelShift);
            if bounds1(4) <= bounds2(4)
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)), (-bounds1(4)-pixelShift(1,1))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)), (-bounds2(4)-pixelShift(1,1))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'northeast')
            pixelShift = get_option(varargin,'northeast',[0,0]);
            arraySize(pixelShift);
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))]; % north
            inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(bounds1(4)-pixelShift(1,1))]; % east

        elseif ~isempty(varargin) && check_option(varargin,'southeast')
            pixelShift = get_option(varargin,'southeast',[0,0]);
            arraySize(pixelShift);
            if bounds1(2) <= bounds2(2) % south
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,2)), (0-pixelShift(1,1)) ];
            else
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))];
            end
            inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(bounds1(4)-pixelShift(1,1))]; % east

        elseif ~isempty(varargin) && check_option(varargin,'northwest')
            pixelShift = get_option(varargin,'northwest',[0,0]);
            arraySize(pixelShift);
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))]; % north
            if bounds1(4) <= bounds2(4) % west
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)), (-bounds1(4)-pixelShift(1,1))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)), (-bounds2(4)-pixelShift(1,1))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'southwest')
            pixelShift = get_option(varargin,'southwest',[0,0]);
            arraySize(pixelShift);
            if bounds1(2) <= bounds2(2) % south
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,2)), (0-pixelShift(1,1)) ];
            else
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))];
            end
            if bounds1(4) <= bounds2(4) % west
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)), (-bounds1(4)-pixelShift(1,1))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)), (-bounds2(4)-pixelShift(1,1))];
            end
        end
    end



    if strcmpi(xMapDir,'north') && strcmpi(zMapDir,'outofPlane')
        warning(sprintf('\nMap 1 origin = south-east corner.\n+ve x-values = moves map 2 right relative to map 1.\n+ve y-values = moves map 2 down relative to map 1.'));

        if ~isempty(varargin) && check_option(varargin,'north')
            pixelShift = get_option(varargin,'north',[0,0]);
            arraySize(pixelShift);
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))];

        elseif ~isempty(varargin) && check_option(varargin,'south')
            pixelShift = get_option(varargin,'south',[0,0]);
            arraySize(pixelShift);
            if bounds1(2) <= bounds2(2)
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,2)), (0-pixelShift(1,1)) ];
            else
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'east')
            pixelShift = get_option(varargin,'east',[0,0]);
            arraySize(pixelShift);
            if bounds1(4) <= bounds2(4)
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(-bounds1(4)-pixelShift(1,1))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(-bounds2(4)-pixelShift(1,1))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'west')
            pixelShift = get_option(varargin,'west',[0,0]);
            arraySize(pixelShift);
            inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(bounds1(4)-pixelShift(1,1))];

        elseif ~isempty(varargin) && check_option(varargin,'northeast')
            pixelShift = get_option(varargin,'northeast',[0,0]);
            arraySize(pixelShift);
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))]; % north
            if bounds1(4) <= bounds2(4) % east
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(-bounds1(4)-pixelShift(1,1))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(-bounds2(4)-pixelShift(1,1))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'southeast')
            pixelShift = get_option(varargin,'southeast',[0,0]);
            arraySize(pixelShift);
            if bounds1(2) <= bounds2(2) % south
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,2)), (0-pixelShift(1,1)) ];
            else
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))];
            end
            if bounds1(4) <= bounds2(4) % east
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(-bounds1(4)-pixelShift(1,1))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(-bounds2(4)-pixelShift(1,1))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'northwest')
            pixelShift = get_option(varargin,'northwest',[0,0]);
            arraySize(pixelShift);
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))]; % north
            inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(bounds1(4)-pixelShift(1,1))]; % west

        elseif ~isempty(varargin) && check_option(varargin,'southwest')
            pixelShift = get_option(varargin,'southwest',[0,0]);
            arraySize(pixelShift);
            if bounds1(2) <= bounds2(2) % south
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,2)), (0-pixelShift(1,1)) ];
            else
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))];
            end
            inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(bounds1(4)-pixelShift(1,1))]; % west
        end
    end



    if strcmpi(xMapDir,'east') && strcmpi(zMapDir,'intoPlane')
        warning(sprintf('\nMap 1 origin = north-west corner.\n+ve x-values = moves map 2 left relative to map 1.\n+ve y-values = moves map 2 up relative to map 1.'));
        if ~isempty(varargin) && check_option(varargin,'north')
            pixelShift = get_option(varargin,'north',[0,0]);
            arraySize(pixelShift);
            if bounds1(4) >= bounds2(4)
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds2(4)-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds1(4)-pixelShift(1,2))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'south')
            pixelShift = get_option(varargin,'south',[0,0]);
            arraySize(pixelShift);
            inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (bounds1(4)-pixelShift(1,2))];

        elseif ~isempty(varargin) && check_option(varargin,'east')
            pixelShift = get_option(varargin,'east',[0,0]);
            arraySize(pixelShift);
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))];

        elseif ~isempty(varargin) && check_option(varargin,'west')
            pixelShift = get_option(varargin,'west',[0,0]);
            arraySize(pixelShift);
            if bounds1(2) >= bounds2(2)
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'northeast')
            pixelShift = get_option(varargin,'northeast',[0,0]);
            arraySize(pixelShift);
            if bounds1(4) >= bounds2(4) % north
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds2(4)-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds1(4)-pixelShift(1,2))];
            end
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))]; % east

        elseif ~isempty(varargin) && check_option(varargin,'southeast')
            pixelShift = get_option(varargin,'southeast',[0,0]);
            arraySize(pixelShift);
            inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (bounds1(4)-pixelShift(1,2))]; % south
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))]; % east

        elseif ~isempty(varargin) && check_option(varargin,'northwest')
            pixelShift = get_option(varargin,'northwest',[0,0]);
            arraySize(pixelShift);
            if bounds1(4) >= bounds2(4) % north
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds2(4)-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds1(4)-pixelShift(1,2))];
            end
            if bounds1(2) >= bounds2(2) % west
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'southwest')
            pixelShift = get_option(varargin,'southwest',[0,0]);
            arraySize(pixelShift);
            inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (bounds1(4)-pixelShift(1,2))]; % south
            if bounds1(2) >= bounds2(2) % west
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            end
        end
    end



    if strcmpi(xMapDir,'east') && strcmpi(zMapDir,'outofPlane')
        warning(sprintf('\nMap 1 origin = south-west corner.\n+ve x-values = moves map 2 left relative to map 1.\n+ve y-values = moves map 2 down relative to map 1.'));

        if ~isempty(varargin) && check_option(varargin,'north')
            pixelShift = get_option(varargin,'north',[0,0]);
            arraySize(pixelShift);
            inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (bounds1(4)-pixelShift(1,2))];

        elseif ~isempty(varargin) && check_option(varargin,'south')
            pixelShift = get_option(varargin,'south',[0,0]);
            arraySize(pixelShift);
            if bounds1(4) >= bounds2(4)
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds2(4)-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds1(4)-pixelShift(1,2))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'east')
            pixelShift = get_option(varargin,'east',[0,0]);
            arraySize(pixelShift);
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))];

        elseif ~isempty(varargin) && check_option(varargin,'west')
            pixelShift = get_option(varargin,'west',[0,0]);
            arraySize(pixelShift);
            if bounds1(2) >= bounds2(2)
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'northeast')
            pixelShift = get_option(varargin,'northeast',[0,0]);
            arraySize(pixelShift);
            inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (bounds1(4)-pixelShift(1,2))]; % north
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))]; % east

        elseif ~isempty(varargin) && check_option(varargin,'southeast')
            pixelShift = get_option(varargin,'southeast',[0,0]);
            arraySize(pixelShift);
            if bounds1(4) >= bounds2(4) % south
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds2(4)-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds1(4)-pixelShift(1,2))];
            end
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))]; % east

        elseif ~isempty(varargin) && check_option(varargin,'northwest')
            pixelShift = get_option(varargin,'northwest',[0,0]);
            arraySize(pixelShift);
            inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (bounds1(4)-pixelShift(1,2))]; %north
            if bounds1(2) >= bounds2(2) %west
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'southwest')
            pixelShift = get_option(varargin,'southwest',[0,0]);
            arraySize(pixelShift);
            if bounds1(4) >= bounds2(4) % south
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds2(4)-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds1(4)-pixelShift(1,2))];
            end
            if bounds1(2) >= bounds2(2) % west
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            end
        end
    end

    % get the x & y co-ordinates of the 2 maps
    XY1 = [inebsd1.prop.x,inebsd1.prop.y];
    XY2 = [inebsd2.prop.x,inebsd2.prop.y];

    % calculate the step size for map 2
    stepSize = calcStepSize(inebsd2);

    % set the tolerance to quarter of the step size
    tol = stepSize/4;

    % find the index of the points in map 2 that overlap with map 1
    [overlapID,~] = ismembertol(XY2,XY1,tol,'ByRows',true,'DataScale',1);

    % remove the overlapping points from map 2
    inebsd2 = inebsd2(~overlapID);

    % merge the maps together
    outebsd = [inebsd1,inebsd2];

    % gridify to get one set of uniform x & y co-ordinates
    gebsd = gridify(outebsd);

    % return to a uniform ebsd variable
    outebsd = EBSD(gebsd);

else
    error('Incorrect direction specified.')
    return
end
end
%%



%% Check for the size of the offset/overlay array
function arraySize(inArray)
if ~isequal(size(inArray), [1 2])
    error(sprintf('The offset/overlay must be a 1 x 2 array.'));
    return;
end
end
%%



%%
function parts = getVersionParts(V)
parts = sscanf(V, '%d.%d.%d')';
if length(parts) < 3
    parts(3) = 0; % zero-fills to 3 elements
end
end