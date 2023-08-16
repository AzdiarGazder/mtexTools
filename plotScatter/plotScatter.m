function hAxes = plotScatter(X,Y,varargin)
%% Function description:
% Creates a scatter plot coloured by density.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgments:
% Robert Henson, Flow Cytometry Data Reader and Visualization.
% For the original script uploaded to:
% https://www.mathworks.com/matlabcentral/fileexchange/8430-flow-cytometry-data-reader-and-visualization
%
%% Reference:
% Paul H. C. Eilers and Jelle J. Goeman
% Enhancing scatterplots with smoothed densities
% Bioinformatics, Mar 2004; 20: 623 - 628.
%
%% Syntax:
%  plotScatter(X,Y,varargin)
%
%% Input:
%  X,Y               - numeric vectors of the same size
%
%% Options:
% log              - flag specifying a log scale for the Y axis
% symmetric        - flag specifying the X-Y data is symmetric
%
% lambda           - specifies the smoothing factor used by the density
%                    estimator. The default value is 20 which roughly 
%                    signifies smoothing over 20 bins around a given point.
% bins             - specifies the number of bins used to estimate the 
%                    density in the 2D histogram. The default is to use 
%                    the number of unique values in X and Y up to a 
%                    maximum of 200.
%
% type             - specifies the plot type (options: 'surf','mesh', 
%                    'contour', 'image', 'scatter')
% markerType       - specifies the marker type
% markerSize       - specifies the marker size
% markerFaceColor  - specifies the marker face color
% markerEdgeColor  - specifies the marker edge color
% linewidth        - specifies the marker or contour line width
% colormap         - specifies a colormap for the marker or contour
% filled           - fills the marker or contour with a color or colormap
%
%%


logFlag = check_option(varargin,'log');
symmetricFlag = check_option(varargin,'symmetric');


lambda = get_option(varargin,'lambda',20);
nbins = get_option(varargin,'bins',[min(numel(unique(X)),200), min(numel(unique(Y)),200)]);

plotType = get_option(varargin,'type','scatter');

markerType = get_option(varargin,'marker','o');
markerSize = get_option(varargin,'size',20);
markerFaceColorFlag = check_option(varargin,'MarkerFaceColor');
if markerFaceColorFlag
    markerFaceCol = get_option(varargin,'MarkerFaceColor');
end
markerEdgeCol = get_option(varargin,'MarkerEdgeColor',[0 0 0]);
LineWdth = get_option(varargin,'linewidth',1);
cmap = get_option(varargin,'colormap',jet);
fillFlag = check_option(varargin,'filled');

if logFlag
    Y = log10(Y);
end

minX = min(X,[],1);
maxX = max(X,[],1);
minY = min(Y,[],1);
maxY = max(Y,[],1);


edgesX = linspace(minX, maxX, nbins(1)+1);
centersX = edgesX(1:end-1) + .5*diff(edgesX);
edgesX = [-Inf edgesX(2:end-1) Inf];

edgesY = linspace(minY, maxY, nbins(2)+1);
centersY = edgesY(1:end-1) + .5*diff(edgesY);
edgesY = [-Inf edgesY(2:end-1) Inf];

[n,~] = size(X);
bins = zeros(n,2);
% % Reverse the columns to put the first column of X along the horizontal
% % axis, the second along the vertical.
[~,bins(:,2)] = histc(X,edgesX);
[~,bins(:,1)] = histc(Y,edgesY);
H = accumarray(bins,1,nbins([2 1])) ./ n;
G = smooth1D(H,nbins(2)/lambda);
if symmetricFlag
    F = filter2D(H,lambda);
else
    F = smooth1D(G',nbins(1)/lambda)';
end

if logFlag
    centersY = 10.^centersY;
    Y = 10.^Y;
end


switch(plotType)
    case {'surf'}
        h = surf(centersX,centersY,F,'edgealpha',0,'LineWidth',LineWdth);
    
    case {'mesh'}
        h = mesh(centersX,centersY,F,'LineWidth',LineWdth);
    
    case {'contour'}
        if fillFlag
            [~,h] = contourf(centersX,centersY,F,'LineWidth',LineWdth);
        else
            [~,h] = contour(centersX,centersY,F,'LineWidth',LineWdth);
        end
        colormap(cmap);
    
    case {'image'}
        nc = 256;
        F = F./max(F(:));
        h = image(centersX,centersY,floor(nc.*F) + 1);
        colormap(cmap);
    
    case {'scatter'}
        if markerFaceColorFlag % marker color specified
            h = scatter(X,Y,...
                markerSize,markerType,...
                'MarkerFaceColor',markerFaceCol,...
                'MarkerEdgeColor',markerEdgeCol,...
                'LineWidth',LineWdth);
        
        else % no marker color specified, use the colormap instead
            F = F./max(F(:));
            ind = sub2ind(size(F),bins(:,1),bins(:,2));
            markerFaceCol = F(ind);
            if fillFlag
                h = scatter(X,Y,...
                    markerSize,markerFaceCol,markerType,'filled',...
                    'MarkerEdgeColor',markerEdgeCol,...
                    'LineWidth',LineWdth);
            else
                h = scatter(X,Y,...
                    markerSize,markerFaceCol,markerType,...
                    'LineWidth',LineWdth);
            end
            colormap(cmap);
        end
end

if logFlag
    set(gca,'yscale','log');
end

hAxes = get(h,'parent');
end



function Z = filter2D(Y,bw)
% % For symmetric data
z = -1:(1/bw):1;
k = .75 * (1 - z.^2);
k = k ./ sum(k);
Z = filter2(k'*k,Y);
end



function Z = smooth1D(Y,lambda)
% % For non-symmetric data
[m,~] = size(Y);
E = eye(m);
D1 = diff(E,1);
D2 = diff(D1,1);
P = lambda.^2 .* D2'*D2 + 2.*lambda .* D1'*D1;
Z = (E + P) \ Y;
end
