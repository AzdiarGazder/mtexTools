function outebsd = stitch(inebsd1,inebsd2,varargin)
%% Function description:
% Combines 2 ebsd maps given a user-defined position (and offset) for map 2
% relative to map 1.
%
%% Note to users:
% Gridify the "outebsd" variable before saving as a *.ctf file.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements: 
% Based on https://github.com/mtex-toolbox/mtex/issues/362
%
%% Syntax:
%  [ebsd] = stitch(ebsd1,ebsd2,arg,array)
%
%% Input:
%  ebsd1       - @EBSD
%  ebsd2       - @EBSD
%  arg         - char defining position of ebsd2 relative to ebsd1.
%                Options = 'north', 'south', 'east', 'west',
%                'northeast', 'southeast', 'northwest', 'southwest'
%  array       - numeric array defining an [x,y] offset in pixels for
%                ebsd2 relative to ebsd1.
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

%     figure
%     plot(inebsd1,inebsd1.bc);
%     figure
%     plot(inebsd2,inebsd2.bc);

    bounds1 = inebsd1.extend; % [xmin, xmax, ymin, ymax]
    bounds2 = inebsd2.extend; % [xmin, xmax, ymin, ymax]

    xMapDir = getMTEXpref('xAxisDirection');
    zMapDir = getMTEXpref('zAxisDirection');


    if strcmpi(xMapDir,'north') && strcmpi(zMapDir,'intoPlane')
        warning(sprintf('\nMap 1 origin = south-west corner.\n+ve x-values = moves map 2 left relative to map 1.\n+ve y-values = moves map 2 down relative to map 1.'));

        if ~isempty(varargin) && check_option(varargin,'north')
            pixelShift = get_option(varargin,'north',[0,0]);
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))];

        elseif ~isempty(varargin) && check_option(varargin,'south')
            pixelShift = get_option(varargin,'south',[0,0]);
            if bounds1(2) <= bounds2(2)
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,2)), (0-pixelShift(1,1)) ];
            else
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'east')
            pixelShift = get_option(varargin,'east',[0,0]);
            inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(bounds1(4)-pixelShift(1,1))];

        elseif ~isempty(varargin) && check_option(varargin,'west')
            pixelShift = get_option(varargin,'west',[0,0]);
            if bounds1(4) <= bounds2(4)
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)), (-bounds1(4)-pixelShift(1,1))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)), (-bounds2(4)-pixelShift(1,1))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'northeast')
            pixelShift = get_option(varargin,'northeast',[0,0]);
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))]; % north
            inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(bounds1(4)-pixelShift(1,1))]; % east

        elseif ~isempty(varargin) && check_option(varargin,'southeast')
            pixelShift = get_option(varargin,'southeast',[0,0]);
            if bounds1(2) <= bounds2(2) % south
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,2)), (0-pixelShift(1,1)) ];
            else
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))];
            end
            inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(bounds1(4)-pixelShift(1,1))]; % east

        elseif ~isempty(varargin) && check_option(varargin,'northwest')
            pixelShift = get_option(varargin,'northwest',[0,0]);
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))]; % north
            if bounds1(4) <= bounds2(4) % west
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)), (-bounds1(4)-pixelShift(1,1))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)), (-bounds2(4)-pixelShift(1,1))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'southwest')
            pixelShift = get_option(varargin,'southwest',[0,0]);
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
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))];

        elseif ~isempty(varargin) && check_option(varargin,'south')
            pixelShift = get_option(varargin,'south',[0,0]);
            if bounds1(2) <= bounds2(2)
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,2)), (0-pixelShift(1,1)) ];
            else
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'east')
            pixelShift = get_option(varargin,'east',[0,0]);
            if bounds1(4) <= bounds2(4)
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(-bounds1(4)-pixelShift(1,1))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(-bounds2(4)-pixelShift(1,1))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'west')
            pixelShift = get_option(varargin,'west',[0,0]);
            inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(bounds1(4)-pixelShift(1,1))];

        elseif ~isempty(varargin) && check_option(varargin,'northeast')
            pixelShift = get_option(varargin,'northeast',[0,0]);
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))]; % north
            if bounds1(4) <= bounds2(4) % east
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(-bounds1(4)-pixelShift(1,1))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(-bounds2(4)-pixelShift(1,1))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'southeast')
            pixelShift = get_option(varargin,'southeast',[0,0]);
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
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,2)), (0-pixelShift(1,1))]; % north
            inebsd2 = inebsd2 + [(0-pixelShift(1,2)),(bounds1(4)-pixelShift(1,1))]; % west

        elseif ~isempty(varargin) && check_option(varargin,'southwest')
            pixelShift = get_option(varargin,'southwest',[0,0]);
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
            if bounds1(4) >= bounds2(4)
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds2(4)-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds1(4)-pixelShift(1,2))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'south')
            pixelShift = get_option(varargin,'north',[0,0]);
            inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (bounds1(4)-pixelShift(1,2))];

        elseif ~isempty(varargin) && check_option(varargin,'east')
            pixelShift = get_option(varargin,'east',[0,0]);
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))];

        elseif ~isempty(varargin) && check_option(varargin,'west')
            pixelShift = get_option(varargin,'west',[0,0]);
            if bounds1(2) >= bounds2(2)
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'northeast')
            pixelShift = get_option(varargin,'northeast',[0,0]);
            if bounds1(4) >= bounds2(4) % north
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds2(4)-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds1(4)-pixelShift(1,2))];
            end
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))]; % east

        elseif ~isempty(varargin) && check_option(varargin,'southeast')
            pixelShift = get_option(varargin,'southeast',[0,0]);
            inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (bounds1(4)-pixelShift(1,2))]; % south
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))]; % east

        elseif ~isempty(varargin) && check_option(varargin,'northwest')
            pixelShift = get_option(varargin,'northwest',[0,0]);
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
            inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (bounds1(4)-pixelShift(1,2))];

        elseif ~isempty(varargin) && check_option(varargin,'south')
            pixelShift = get_option(varargin,'south',[0,0]);
            if bounds1(4) >= bounds2(4)
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds2(4)-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds1(4)-pixelShift(1,2))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'east')
            pixelShift = get_option(varargin,'east',[0,0]);
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))];

        elseif ~isempty(varargin) && check_option(varargin,'west')
            pixelShift = get_option(varargin,'west',[0,0]);
            if bounds1(2) >= bounds2(2)
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'northeast')
            pixelShift = get_option(varargin,'northeast',[0,0]);
            inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (bounds1(4)-pixelShift(1,2))]; % north
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))]; % east

        elseif ~isempty(varargin) && check_option(varargin,'southeast')
            pixelShift = get_option(varargin,'southeast',[0,0]);
            if bounds1(4) >= bounds2(4) % south
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds2(4)-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (-bounds1(4)-pixelShift(1,2))];
            end
            inebsd2 = inebsd2 + [(bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))]; % east

        elseif ~isempty(varargin) && check_option(varargin,'northwest')
            pixelShift = get_option(varargin,'northwest',[0,0]);
            inebsd2 = inebsd2 + [(0-pixelShift(1,1)), (bounds1(4)-pixelShift(1,2))]; %north
            if bounds1(2) >= bounds2(2) %west
                inebsd2 = inebsd2 + [(-bounds1(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            else
                inebsd2 = inebsd2 + [(-bounds2(2)-pixelShift(1,1)), (0-pixelShift(1,2))];
            end

        elseif ~isempty(varargin) && check_option(varargin,'southwest')
            pixelShift = get_option(varargin,'southwest',[0,0]);
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
    xx = [inebsd2.unitCell(:,1);inebsd2.unitCell(1,1)]; % repeat the 1st x co-ordinate to close the unit pixel shape
    yy = [inebsd2.unitCell(:,2);inebsd2.unitCell(1,2)]; % repeat the 1st y co-ordinate to close the unit pixel shape
    unitPixelArea = polyarea(xx,yy);
    if size(inebsd2.unitCell,1) == 6 % hexGrid
        stepSize = sqrt(unitPixelArea/sind(60));
    else % squareGrid
        stepSize = sqrt(unitPixelArea);
    end

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

%     figure;
%     plot(outebsd,outebsd.bc)

else
    error('Incorrect direction specified.')
    return
end
end
