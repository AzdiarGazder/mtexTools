function figH = plotPairs(inData,gmm, varargin)
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
% tempLabels = cellstr(num2str((1:numDataCols)', '%d'));
tempLabels = num2roman((1:numDataCols)'); % use Roman numerals as temporary labels
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


figH = figure;
%% Scatter plots
for ii = 1:numDataCols
    for jj = 1:numDataCols
        % select the appropriate axis
        ax = subplot(numDataCols, numDataCols, sub2ind([numDataCols numDataCols], ii, jj));
        xlabel(labels{ii});
        ylabel(labels{jj});
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
        legend(clusterNames,'Location','northeast');
        box on; axis tight; % axis square;
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
            xlabel('Data');
            ylabel('Norm. counts');
        else
            for kk = 1:numClusters
                idx = strcmpi(clusterArray, clusterNames{kk});
                histogram(ax, inData(idx, ii), bins,...
                    'Normalization', 'probability',...
                    'FaceColor', colors(kk,:),...
                    'LineWidth',1);
                xlabel(labels{ii});
                ylabel('Norm. counts');
            end
        end
        xlim([bins(1) bins(end)]);
        legend(clusterNames,'Location','northeast');
        box on; axis tight; % axis square;


    elseif strcmpi(plotType, 'bar')
        % Display bars
        % Convert bin centers to edges
        db = diff(bins) / 2;
        edges = [bins(1)-db(1), bins(1:end-1)+db, bins(end)+db(end)];
        edges(2:end) = edges(2:end) + eps(edges(2:end));

        if isempty(clusterArray)
            [counts, ~] = histcounts(inData(:, ii), edges);
            bar(ax, bins, counts, 'BarWidth', 1, 'FaceColor', colors(kk,:));
            xlabel('Bins');
            ylabel('Counts');
        else
            for kk = 1:numClusters
                idx = strcmpi(clusterArray, clusterNames{kk});
                [counts, ~] = histcounts(inData(idx, ii), edges);
                bar(ax, bins, counts,...
                    'BarWidth', 1,...
                    'FaceColor', colors(kk,:),...
                    'LineWidth',1);
                xlabel(labels{ii});
                ylabel('Counts');
            end
        end
        xlim([edges(1) edges(end)]);
        legend(clusterNames,'Location','northeast');
        box on; axis tight; % axis square;


    elseif strcmpi(plotType, 'kde')
        % Use the kernel-density estimate
        if isempty(clusterArray)
            [f, xf] = ksdensity(inData(:,ii));
            plot(ax, xf, f);
            xlabel('Data');
            ylabel('Density estimate');
        else
            for kk = 1:numClusters
                idx = strcmpi(clusterArray, clusterNames{kk});
                [f, xf] = ksdensity(inData(idx,ii));
                plot(ax, xf, f,...
                    'Color', colors(kk,:),...
                    'LineWidth',1);
                xlabel(labels{ii});
                ylabel('Density estimate');
            end
        end
        legend(clusterNames,'Location','northeast');
        box on; axis tight; % axis square;


    elseif strcmpi(plotType, 'cdf')
        % Display the cumulative density function
        if isempty(clusterArray)
            [f, x] = ecdf(inData(idx, ii));
            plot(ax, x, f);
            xlabel('Data');
            ylabel('CDF');
        else
            for kk = 1:numClusters
                idx = strcmpi(clusterArray, clusterNames{kk});
                [f, x] = ecdf(inData(idx, ii));
                plot(ax, x, f,...
                    'Color', colors(kk,:),...
                    'LineWidth',1);
                xlabel(labels{ii});
                ylabel('CDF');
            end
        end
        legend(clusterNames,'Location','northeast');
        box on; axis tight; % axis square;


    end
end


end












function varargout = num2roman(n)
%   NUM2ROMAN(N) returns modern Roman numeral form of integer N, which can
%	be scalar (returns a string), vector or matrix (returns a cell array of
%	strings, same size as N).
%
%	The function uses strict rules with substractive notation and commonly
%	found 'MMMM' form for 4000. It includes also parenthesis notation for
%	large numbers (multiplication by 1000). It considers only the integer
%	part of N.
%
%	Examples:
%		num2roman(1968)
%		num2roman(10.^(0:7))
%		reshape(num2roman(1:100),10,10)
%
%	See also ROMAN2NUM.
%
%	Author: François Beauducel <beauducel@ipgp.fr>
%	  Institut de Physique du Globe de Paris
%	Created: 2005
%	Modified: 2021-01-05
%	Copyright (c) 2005-2021, François Beauducel, covered by BSD License.
%	All rights reserved.
%
%	Redistribution and use in source and binary forms, with or without
%	modification, are permitted provided that the following conditions are
%	met:
%
%	   * Redistributions of source code must retain the above copyright
%	     notice, this list of conditions and the following disclaimer.
%	   * Redistributions in binary form must reproduce the above copyright
%	     notice, this list of conditions and the following disclaimer in
%	     the documentation and/or other materials provided with the distribution
%
%	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%	POSSIBILITY OF SUCH DAMAGE.

narginchk(1,1);

if ~isnumeric(n)
    error('N must be numeric array (scalar, vector or matrix).')
end

s = cell(size(n));

for kk = 1:numel(n)
    m = max(floor((log10(n(kk)) - log10(5000))/3) + 1,0);

    for ii = m:-1:0
        if isnan(n(kk))
            ss = '?';
        else
            ss = roman(fix(n(kk)/10^(3*ii)));
        end

        if ii == m
            s{kk} = ss;
        else
            s{kk} = ['(',s{kk},')',ss];
        end

        n(kk) = mod(n(kk),10^(3*ii));
    end
end

% converts to string if n is a scalar
if numel(n) == 1
    s = s{1};
end

% converts to string if n is empty
if isempty(n)
    s = '';
end

% only display without output argument
if nargout == 0
    disp(s)
else
    varargout{1} = s;
end
end



function out = roman(in)
% This subfunction converts numbers up to 4999

r = reshape('IVXLCDM   ',2,5);	% the 3 last blank chars are to avoid error for n >= 1000
out = '';
numDigits = floor(log10(in)) + 1;	% m is the number of digit

% n is processed sequentially for each digit
for ii = numDigits:-1:1
    i2 = fix(in/10^(ii-1));	% i2 is the digit (0 to 9)

    % Roman numeral is a concatenation of r(1:2,i) and r(1,i+1)
    % combination with regular rules (exception for 4000 = MMMM)
    % Note: the expression uses REPMAT behavior which returns empty
    % string for N <= 0
    out = [out,repmat(r(1,ii),1,i2*(i2 < 4 | (i2==4 & ii==4)) + (i2 == 9) + (i2==4 & ii < 4)), ...
        repmat([r(2,ii),repmat(r(1,ii),1,i2-5)],1,(i2 >= 4 & i2 <= 8 & ii ~= 4)), ...
        repmat(r(1,ii+1),1,(i2 == 9))];

    % substract the most significant digit
    in = in - i2*10^(ii-1);
end
end