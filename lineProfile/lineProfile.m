function lineProfile(inebsd,varargin)
%% Function description:
% Interactively plots an EBSD map property (numeric, logical, or
% misorientation) line profile along a user specified linear fiducial.
% Instructions on script use are provided in the window titlebar.
%
%% Notes to users:
% 1. This function is currently restricted to single phase maps only.
% 2. MTex's function: "C:\mtex\EBSDAnalysis\@EBSD\spatialProfile.m"
% cannot be used as it does not account for the type of ebsd variable 
% introduced to it.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Version(s):
% A version describing this functionality was posted in:
% https://mtex-toolbox.github.io/EBSDProfile.html
%
%% Syntax:
%  plotprofile(ebsd,varargin)
%
%% Input:
%  ebsd      - @EBSD
%
%% Output:
%  none
%
%% Options:
%  color      -  @numeric, define the colour of the ROI line
%  lineWidth  -  @numeric, define the width of the ROI line
%  lineStyle  -  @char,    define the style of the ROI line, types = '-','--',':', or '-.'
%%

close all;

% define line profile options
lineColor = get_option(varargin,'color',[1 0 0]);
lineWidth = get_option(varargin,'lineWidth',2);
lineStyle = get_option(varargin,'lineStyle','-');

% create an ebsd variable in case input ebsd data is gridded
inebsd = EBSD(inebsd);

% calculate the map step size
stepSize = calcStepSize(inebsd);

% grid ebsd map data
% While MTex's default "gridify.m" can be used here, the command creates
% Nan pixels.
% It is recommended to use the modified "gridify2.m" instead.
[gebsd,~] = gridify2(inebsd);
% assignin('base','gebsd',gebsd);

% re-grid the ebsd grid
% Done to ensure no rounding-off errors in grid values.
% This step is especially necessary when converting from hexagonal to
% square grid types
inebsd = regrid(inebsd,stepSize);

% perform linear interpolation to remove NaNs from ebsd property data
gebsd = clean(gebsd);

% create a new user-defined plot
figure(1);

if nargin>=1 && isa(varargin{1},'logical')
    dataType = 'logical';
    varargin{1} = double(varargin{1});
end

if nargin>=1 && isa(varargin{1},'orientation')
    dataType = 'orientation';
    plot(gebsd,gebsd.orientations);

elseif nargin>=1 && isa(varargin{1},'crystalShape')
    error('Error: Incorrect input data. Supported data types are @logical, @orientation, or @double only.');
    return;

elseif nargin>=1 && isnumeric(varargin{1})
    if ~exist('dataType','var')
        dataType = 'numeric';
    end
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
    elseif any(ismember(fields(gebsd.prop),'kam'))
        idxMatrix = reshape(gebsd.prop.error',[],1);
    elseif any(ismember(fields(gebsd.prop),'gnd'))
        idxMatrix = reshape(gebsd.prop.error',[],1);
    end  
    gebsdProperty = nan(size(idxMatrix)); % define an array of NaNs
    gebsdProperty(~isnan(idxMatrix)) = varargin{1}; % replace numeric values into the NaN array
    gebsdProperty = reshape(gebsdProperty,size(gebsd,2),size(gebsd,1)).'; % reshape NaN-numeric array row-wise
    plot(gebsd,gebsdProperty);

else
    dataType = 'numeric';
    plot(gebsd,gebsd.phaseId)
    gebsdProperty = gebsd.phaseId;
end




% % https://au.mathworks.com/matlabcentral/answers/325754-how-to-stop-while-loop-by-right-mouse-button-click
ax1 = gca;
f1 = ancestor(ax1,'figure');
set(f1,'Name',...
    'Band contrast map: Left-click to select two points defining a line profile.',...
    'NumberTitle','on');
% % https://au.mathworks.com/matlabcentral/answers/325754-how-to-stop-while-loop-by-right-mouse-button-click
xy = [];
hold(ax1,'all');
while true
    allfigh = findall(0,'type','figure');
    if length(allfigh) > 1; break; end
    in = ginput(1); % input using left-click
    selectType = get(f1,'SelectionType');
    if strcmpi(selectType,'alt'); return; end % exit on right-click
    scatter(in(1),in(2),...
        'MarkerEdgeColor',[0 0 0],...
        'MarkerFaceColor',[0 0 0]); % plot the point
    xy = [xy;in]; % add point to array

    if size(xy,1) == 2 % profile plot when 2 points are inputted by the user
        % prevent further clicks by the user
        disableDefaultInteractivity(ax1);

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
            stepSizeX = stepSize;%gebsd.dx;
            stepSizeY = stepSize;%gebsd.dy;
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


        % plot the fiducial decribing the line profile
        line(xy(:,1),xy(:,2),'color',[lineColor 0.5],'linewidth',lineWidth,'linestyle',lineStyle);

        % get ebsd data along the line profile
        [ebsdLine,distLine] = spatialProfile2(gebsd,[xy(:,1),xy(:,2)]);

        % plot the profiles based on the map data type
        switch dataType
            case {'logical','numeric'}
                gebsdProp = reshape(gebsdProperty',[],1);
                xyGEBSD = [reshape(gebsd.prop.x',[],1), reshape(gebsd.prop.y',[],1)]; % reshape indices row-wise into a single column array
                xyLine = [ebsdLine.prop.x, ebsdLine.prop.y];
                idx = find(ismember(xyGEBSD,xyLine,'rows'));
                gebsdPropLine = gebsdProp(idx);

                % plot the property gradient
                figure(2);
                plot(distLine,gebsdPropLine,...
                    '-o','MarkerSize',5,'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0],...
                    'color',[1 0 0],'linewidth',1.5);

                hold all
                ax2 = gca;
                disableDefaultInteractivity(ax2);
                hold off
                xlim([0 max(distLine)]);
                ylim([min(gebsdPropLine) max(gebsdPropLine)]);
                xlabel('Distance [um]');
                ylabel('EBSD map property')

            case 'orientation'
                % % define the window settings for a set of docked figures
                % % Ref: https://au.mathworks.com/matlabcentral/answers/157355-grouping-figures-separately-into-windows-and-tabs
                warning off
                desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
                % % Define a unique group name for the dock using the function name
                % % and the system timestamp
                dockGroupName = ['lineProfile_',char(datetime('now','Format','yyyyMMdd_HHmmSS'))];
                desktop.setGroupDocked(dockGroupName,0);
                bakWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

                % plot the misorientation gradient
                drawnow;
                figH = gobjects(1);
                figH = figure('WindowStyle','docked');
                set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
                drawnow;
                plot(0.5*(distLine(1:end-1)+distLine(2:end)),...
                    angle(ebsdLine(1:end-1).orientations,ebsdLine(2:end).orientations)/degree,...
                    '-o','MarkerSize',5,'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0],...
                    'color',[1 0 0],'linewidth',1.5);

                hold all
                % plot the misorientation angle relative to the first orientation on the
                % line profile
                plot(distLine,...
                    angle(ebsdLine(1).orientations,ebsdLine.orientations)/degree,...
                    '-s','MarkerSize',5,'MarkerFaceColor',[0 0 1], 'MarkerEdgeColor',[0 0 0],...
                    'color',[0 0 1],'linewidth',1.5);

                ax2 = gca;
                disableDefaultInteractivity(ax2);
                hold off
                xlim([0 max(distLine)]);
                xlabel('Distance [um]');
                ylabel('Misorientation angle [º]')
                legend('gradient','wrt 1st pt.')
                drawnow;


                drawnow;
                figH = gobjects(1);
                figH = figure('WindowStyle','docked');
                set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
                drawnow;
                plotIPDF(ebsdLine.orientations,[xvector,yvector,zvector],...
                    'property',distLine,'markersize',20,'antipodal')
                cb = mtexColorbar(parula);
                ylabel(cb,'Distance [um]','FontSize',14);
                cbh = get(gca,'Colorbar');
                cbh.Label.Position(1) = 3;
                drawnow;

        end
        % place the first figure on top
%         allfigh = findall(0,'type','figure')
%         if length(allfigh) > 1
%             figure(length(allfigh)-2);
%         else
            figure(1);
%         end
    end
end

end
