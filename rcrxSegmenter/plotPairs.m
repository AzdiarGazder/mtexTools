function plotPairs(inData,gmm, varargin)
%% Function description:
% This function returns the pairwise histogram and scatter plots. It uses 
% the data array and results from Gaussian mixture modelling as inputs.
%
%% Modified by:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements: 
% For the original functions posted by:
% Ryosuke F Takeuchi
% https://au.mathworks.com/matlabcentral/fileexchange/60866-pairplot-meas-label-group-colors-mode%
%
% David Legland, daviddotleglandatinraedotfr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% https://au.mathworks.com/matlabcentral/fileexchange/43912-table-class?s_tid=prof_contriblnk
%
%% Syntax:
%  plotPairs(inData,gmm)
%
%% Input:
%  inData       - @double, an n x m array of data that was previously
%                 used as input in the "calcClusters.m" function
%  gmm          - @struc, the output from the "calcClusters.m"
%
%% Options:
%  'labels'     - @cell, a cell array of @char values comprising the labels
%                 of the inData columns
%  'type'       - @char, specifies the plot type. The options are:
%                 'histogram','bar','kde', and 'cdf'.
%
%%
% 



% Define the labels for the data columns
numDataCols = size(inData, 2);
tempLabels = cellstr(num2str((1:numDataCols)', '%d'));
labels = get_option(varargin,'labels',tempLabels);

% Get the fieldnames of the clusters in the "gmm" structure variable
clusterNames = fields(gmm.cluster);
% Define the number of colors based on the number of clusters
numClusters = length(clusterNames);
colors = lines(numClusters);

% Define a cell array containing the cluster results
clusterArray = cell(size(inData, 1),1);
for ii = 1:length(clusterNames)
    clusterArray(gmm.cluster.(clusterNames{ii}) == true) = {clusterNames{ii}};
end

% Define the plot type
plotType = get_option(varargin,'type','histogram');

%% Scatter plots
for ii = 1:numDataCols
    for jj = 1:numDataCols
        % select the appropriate axis
        ax = subplot(numDataCols, numDataCols, sub2ind([numDataCols numDataCols], ii, jj));

        if ii == 1
            ylabel(labels{jj});
        end
        if jj == numDataCols
            xlabel(labels{ii});
        end
        hold all;

        if ii == jj
            continue;
        end

        if isempty(clusterArray)
            plot(ax, inData(:, ii), inData(:, jj), '.');
        else
            for kk = 1:numClusters
                idx = strcmpi(clusterArray, clusterNames{kk});
                plot(ax, inData(idx, ii), inData(idx, jj), ...
                    '.', 'Color', colors(kk,:));
            end
        end
        xlim([min(inData(:, ii)) max(inData(:, ii))]);
        legend(clusterNames,'Location','best');
    end
end


%% Histogram plots
for ii = 1:numDataCols
    % select the appropriate axis
    ax = subplot(numDataCols, numDataCols, sub2ind([numDataCols numDataCols], ii, ii));
    hold all;

    bins = linspace(min(inData(:,ii)), max(inData(:,ii)), 20);

    if strcmpi(plotType, 'histogram')
        % Display histograms
        if isempty(clusterArray)
            histogram(ax, inData(:, ii), bins, 'Normalization', 'probability');
        else
            for kk = 1:numClusters
                idx = strcmpi(clusterArray, clusterNames{kk});
                histogram(ax, inData(idx, ii), bins, 'FaceColor', colors(kk,:), ...
                    'Normalization', 'probability');
            end
        end
        xlim([bins(1) bins(end)]);
        legend(clusterNames,'Location','best');

    elseif strcmpi(plotType, 'bar')
        % Display bars
        % Convert bin centers to edges
        db = diff(bins) / 2;
        edges = [bins(1)-db(1), bins(1:end-1)+db, bins(end)+db(end)];
        edges(2:end) = edges(2:end) + eps(edges(2:end));

        if isempty(clusterArray)
            [counts, ~] = histcounts(inData(:, ii), edges);
            bar(ax, bins, counts, 'BarWidth', 1, 'FaceColor', colors(kk,:))
        else
            for kk = 1:numClusters
                idx = strcmpi(clusterArray, clusterNames{kk});
                [counts, ~] = histcounts(inData(idx, ii), edges);
                bar(ax, bins, counts, 'BarWidth', 1, 'FaceColor', colors(kk,:))
            end
        end
        xlim([edges(1) edges(end)]);
        legend(clusterNames,'Location','best');

    elseif strcmpi(plotType, 'kde')
        % Use the kernel-density estimate
        if isempty(clusterArray)
            [f, xf] = ksdensity(inData(:,ii));
            plot(ax, xf, f);
        else
            for kk = 1:numClusters
                idx = strcmpi(clusterArray, clusterNames{kk});
                [f, xf] = ksdensity(inData(idx,ii));
                plot(ax, xf, f, 'Color', colors(kk,:));
            end
        end
        legend(clusterNames,'Location','best');

    elseif strcmpi(plotType, 'cdf')
        % Display the cumulative density function
        if isempty(clusterArray)
            [f, x] = ecdf(inData(idx, ii));
            plot(ax, x, f);
        else
            for kk = 1:numClusters
                idx = strcmpi(clusterArray, clusterNames{kk});
                [f, x] = ecdf(inData(idx, ii));
                plot(ax, x, f, 'Color', colors(kk,:));
            end
        end
        legend(clusterNames,'Location','best');
    end
end

end

