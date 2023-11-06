function plot_distr(data, varargin)
%% Function description:
% Plots the distribution of sizes in a dataset.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements:
% Dr. Marco A. Lopez-Sanchez
% For the original Python script at:
% https://github.com/marcoalopez/GrainSizeTools/blob/master/grain_size_tools/plot.py
%
%% Syntax:
% plot_distr(data)
%
%% Input:
% data              - @double, a data array
%
%% Output:
% none
%
%% Options:
% bandWidth         - @char or @double, the method to estimate the
%                     bandwidth or a scalar directly defining the
%                     bandwidth. The @char options are:
%                     'silverman' or 'scott'; default = 'silverman'.
% binSize           - @char or @double, defines the plug-in method to
%                     calculate the bin size. The @char options are:
%                     'auto', 'doane', 'fd', 'rice', 'scott', 'sqrt',
%                     'sturges'; default = 'auto'.
%
%%


binSize = get_option(varargin,'binSize','auto');
bandWidth = get_option(varargin,'bandWidth','silverman');


data = data(~isnan(data) & ~isinf(data));   % omit NaNs and Infs (if any)
data = data(:);

% switch plotType
%     case 'hist' % histogram
if isnumeric(binSize)
    bins = ceil((max(data) - min(data)) / binSize);
else
    switch binSize
        case 'auto'
            if length(data) > 1000
                bins = ceil((max(data) - min(data)) / (2 * iqr(data) / (length(data)^(1/3))));
            else
                bins = ceil((max(data) - min(data)) / (3.5 * std(data) / length(data)^(1/3)));
            end
        case 'doane'
            bins = ceil(1 + log(length(data)) + log(1 + abs(skewness(data)) / sqrt(kurtosis(data))));
        case 'fd'
            bins = ceil((max(data) - min(data)) / (2 * iqr(data) / length(data)^(1/3)));
        case 'rice'
            bins = ceil(2 * length(data)^(1/3));
        case 'scott'
            bins = ceil((max(data) - min(data)) / (3.5 * std(data) / length(data)^(1/3)));
        case 'sqrt'
            bins = ceil(sqrt(length(data)));
        case 'sturges'
            bins = ceil(log2(length(data)) + 1);
        otherwise
            error('Invalid bin size argument');
    end
end


disp(' ');
disp('=======================================');
disp('DESCRIPTIVE STATISTICS');
disp(['Number of classes = ', num2str(bins)]);
disp(['Bin size = ', num2str((max(data) - min(data)) / bins)]);
disp('=======================================');


% Plot the figure
figH = figure;
ax = gca;

f1 = histogram(ax, data, bins,...
    'Normalization', 'probability',...
    'FaceColor', [128/255, 65/255, 157/255],...
    'EdgeColor', [197/255, 159/255, 215/255],...
    'LineWidth', 2,...
    'FaceAlpha', 0.7);
hold all;


%     case 'kde' % kernel density estimate (KDE)
if ischar(bandWidth)
    switch bandWidth
        case 'silverman'
            bw = 1.06 * std(data) * numel(data)^(-1/5);
        case 'scott'
            bw = 3.5 * std(data) * numel(data)^(-1/3);
        otherwise
            error('Invalid bandwidth parameter.');
    end

elseif isnumeric(bandWidth)
    bw = bandWidth;% / std(data, 1);

else
    error('Invalid bandwidth parameter.');
end

% Estimate the Gaussian kernel density function
[kde, xi] = ksdensity(data, 'Kernel', 'normal', 'Bandwidth', bw);

xGrid = linspace(min(data), max(data), 1000);
yGrid = interp1(xi, kde, xGrid, 'spline');
% Scale yGrid to histogram maximum
yGrid = yGrid .* (max(f1.Values) / max(yGrid));

disp(' ');
disp('---------------------------------------');
disp(['KDE bandwidth = ', num2str(bw)]);
disp('---------------------------------------');

% end


yOffset = 0.05;
% Plot the kernel density estimate (KDE)
f2 = plot(ax, xGrid, yGrid,...
    'Color', [47/255, 72/255, 88/255],...
    'LineStyle', '-',...
    'LineWidth', 2.5,...
    'DisplayName', 'kde');
hold all;

% Plot the arithmetic mean
amean = mean(data);
f3 = plot(ax, [amean amean], [0 (max(yGrid) + yOffset)],...
    'Color', [254/255, 196/255, 79/255],...
    'LineStyle', '-',...
    'LineWidth', 1.5,...
    'DisplayName', 'arith. mean');
hold all;

% Plot the geometric mean
gmean = exp(mean(log(data)));
f4 = plot(ax, [gmean gmean], [0 (max(yGrid) + yOffset)],...
    'Color', [254/255, 196/255, 79/255],...
    'LineStyle', '-.',...
    'LineWidth', 1.5,...
    'DisplayName', 'geo. mean');
hold all;

% Plot the median
medianValue = median(data);
f5 = plot(ax, [medianValue medianValue], [0 (max(yGrid) + yOffset)],...
    'Color',  [254/255, 196/255, 79/255],...
    'LineStyle', '--',...
    'LineWidth', 1.5,...
    'DisplayName', 'median');
hold all;

% Plot the mode
[~, idx] = max(yGrid);
mode = xGrid(idx);
f6 = plot(ax, [mode mode], [0 (max(yGrid) + yOffset)],...
    'Color', [254/255, 196/255, 79/255],...
    'LineStyle', ':',...
    'LineWidth', 1.5,...
    'DisplayName', 'mode');
hold on;

xlim([0 max(xGrid)]);
ylim([0 (max(yGrid) + yOffset)]);
ylabel(ax, 'Density');
xlabel(ax, 'Apparent size');
legend([f3, f4, f5, f6],{'arith. mean', 'geo. mean', 'median', 'mode'});
legend(ax, 'Location', 'northeast', 'FontSize', 16);
legend('boxoff');
axis tight;
hold off;

set(figH, 'PaperPositionMode', 'auto');
end
