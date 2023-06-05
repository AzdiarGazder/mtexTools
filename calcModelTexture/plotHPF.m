function plotHPF(odf,varargin)
%% Function description:
% Plots pole figures in publication-ready format.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Version(s):
% The first version of this function was posted in:
% https://github.com/ORTools4MTEX/ORTools/blob/develop/plotPODF_transform.m
%
%% Syntax:
%  plotPF(odf,varargin) 
%
%% Input:
%  odf               - @SO3Fun...
%
%% Options:
%  specimenSymmetry  - @specimenSymmetry
%  hpf               - @Miller array of pole figures
%  stepSize          - @double of the step size of contour levels in the PFs
%  max               - @double of the maximum f(g) in the PFs
%  colormap          - @double of the colormap in the PFs
%%

% Specify or set the specimen symmetry in the ODF
% If specified by the user, find the cell index of the "specimenSymmetry" 
% type variable within varargin 
idx = find(cellfun(@(x) any(isa(x,'specimenSymmetry')),varargin));
if ~isempty(idx)
    odf.SS = varargin{idx};
else % set default symmetry
    odf.SS = specimenSymmetry('triclinic');
end

% Specify or set the pole figures to plot in the ODF (default = fcc)
% If specified by the user, find the cell index of the "specimenSymmetry" 
% type variable within varargin 
idx = find(cellfun(@(x) any(isa(x,'Miller')),varargin)); % if only 1 PF is specified
if isempty(idx)
    idx = find(cellfun(@(x) any(isa(x,'cell')),varargin)); % if multiple PFs are specified
end
if ~isempty(idx)
    hpf = varargin{idx};
else % set default pole figures
    hpf = {Miller(1,1,1,odf.CS),Miller(2,0,0,odf.CS), Miller(2,2,0,odf.CS)};
end

% Specify or set the step size of contour levels in the PFs
stepSize = get_option(varargin,'stepSize',1);

% Specify or calculate the value of the maximum f(g) in the PFs
maxPF = get_option(varargin,'max',ceil(max(max(calcPoleFigure(odf,hpf,regularS2Grid('resolution',2.5*degree),'antipodal')))));

% Specify or set the colormap in the PFs
pfColormap = get_option(varargin,'colormap',gray);


% Plot the pole figures
figH = figure;
plotPDF(odf,...
    hpf,...
    'antipodal','silent','contourf',1:stepSize:maxPF);
%     'points','all',...
%     'equal','antipodal',...
%     'contourf',1:stepSize:maxPF);
hold all;
colormap(pfColormap);
caxis([1 maxPF]);
colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
    'YTick', [1:stepSize:maxPF],...
    'YTickLabel',num2str([1:stepSize:maxPF]'), 'YLim', [1 maxPF],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
CLim(gcm,'equal'); % set equal color range to all plots
set(figH,'Name','Pole figure(s)','NumberTitle','on');
hold off;
drawnow;

end
