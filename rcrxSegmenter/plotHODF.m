function figH = plotHODF(odf,varargin) 
%% Function description:
% Plots orientation distribution function phi2 sections in publication-
% ready format.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Version(s):
% The first version of this function was posted in:
% https://github.com/ORTools4MTEX/ORTools/blob/develop/plotPODF_transform.m
%
%% Syntax:
%  plotODF(odf,varargin) 
%
%% Input:
%  odf               - @SO3Fun...
%
%% Options:
%  specimenSymmetry  - @specimenSymmetry
%  sections          - @double array of phi2 sections in degrees
%  stepSize          - @double of the step size of contour levels in the ODF
%  max               - @double of the maximum f(g) in the ODF
%  colormap          - @double of the colormap in the ODF
%%

% Specify or set the specimen symmetry in the ODF
% If specified by the user, find the cell index of the "specimenSymmetry" 
% type variable within varargin 
idx = find(cellfun(@(x) any(isa(x,'specimenSymmetry')),varargin));
if ~isempty(idx)
    odf.SS = varargin{idx};
else % set default symmetry
    odf.SS = specimenSymmetry('orthorhombic');
end

% Specify or set the phi2 sections to plot in the ODF
odfSections = get_option(varargin,'sections',[0 45 90]*degree);

% Specify or calculate the value of the maximum f(g) in the ODF
maxODF = get_option(varargin,'max',ceil(max(odf)./10)*10);

% Specify or set the step size of contour levels in the ODF
stepSize = get_option(varargin,'stepSize',maxODF/10);

% Specify or set the colormap in the ODF
odfColormap = get_option(varargin,'colormap',gray);


% Plot the orientation distribution function
figH = figure;
plotSection(odf,...
    'phi2',odfSections,...
    'points','all','equal',...
    'contourf',1:stepSize:maxODF);
hold all;
colormap(odfColormap);
caxis([1 maxODF]);
colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
    'YTick', (1:stepSize:maxODF),...
    'YTickLabel',num2str((1:stepSize:maxODF)'), 'YLim', [1 maxODF],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
CLim(gcm,'equal'); % set equal color range to all plots
% set(figH,'Name','Orientation distribution function (ODF)','NumberTitle','on');
hold off;
drawnow;

end
