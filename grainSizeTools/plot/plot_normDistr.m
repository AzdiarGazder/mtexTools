function plot_normDistr(data, varargin)
%% Function description:
% Plots the log-transformed normalised distribution of the dataset. This 
% is useful when comparing size distributions between samples with 
% different average values.
%
%% Authors:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
% Dr. Marco A. López Sánchez, 2023, marcoalopezatoutlookdotcom
%
%% Acknowledgements:
% Dr. Marco A. López Sánchez
% For the original Python script at:
% https://github.com/marcoalopez/GrainSizeTools/blob/master/grain_size_tools/plot.py
%
%% Syntax:
% plot_normDistr(data)
%
%% Input:
% data              - @double, a data array
%
%% Output:
% none
%
%% Options:
% type              - @char, the method to normalise the data. The 
%                     options are: 'mean' or 'mode'; default = 'mean'.
% bandWidth         - @char or @double, the method to estimate the
%                     bandwidth or a scalar directly defining the
%                     bandwidth. The @char options are:
%                     'silverman' or 'scott'; default = 'silverman'.
% precision         - @double, the maximum precision expected for the
%                     "peak" kde-based estimator; default = 0.05. This 
%                     variable is not related to confidence intervals.
%
%%


type = get_option(varargin,'type','mean');
bandWidth = get_option(varargin,'bandWidth','silverman');
precision = get_option(varargin,'precision',0.05);


data = data(~isnan(data) & ~isinf(data));   % omit NaNs and Infs (if any)
data = log(data);
data = data(:);

% normalise the data
switch type
    case 'mean'
        normFactor = mean(data);
    case 'median'
        normFactor = median(data);
    otherwise
        error('Normalisation factor is defined by ''mean'' or ''median''');
end
data = data ./ normFactor;

% estimate KDE
% Check if bandwidth is a string or is numeric and set the bw accordingly
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
    bw = bandWidth / std(data, 1);

else
    error('Invalid bandwidth parameter.');
end

% Estimate Gaussian kernel density function
[kde, xi] = ksdensity(data, 'Kernel', 'normal', 'Bandwidth', bw);

% Find peak grain size
[yMax, idx] = max(kde);
modeValue = xi(idx);

% Generate xGrid and yGrid
xGrid = generateGrid(min(data), max(data), precision);
yGrid = interp1(xi, kde, xGrid, 'spline');


disp(' ');
disp('=======================================');
disp('DESCRIPTIVE STATISTICS from plot_normDistr');
switch type
    case 'mean'
        disp(['Normalized SD = ' num2str(std(data), '%0.3f')]);
    case 'median'
        disp(['Normalized IQR = ' num2str(iqr(data), '%0.3f')]);
end
disp(['KDE bandwidth = ' num2str(bw)]);
disp('=======================================');

% plot the figure
figH = figure;
ax = axes(figH);

f1 = area(ax, xGrid, yGrid,...
    'FaceColor',[209/255, 52/255, 107/255],...
    'FaceAlpha', 0.5,...
    'EdgeColor', [47/255, 72/255, 88/255],...
    'LineStyle', '-',...
    'LineWidth', 2);
hold all;

switch type
    case 'mean'
        % Plot the arithmetic mean
        meanValue = mean(data);
        f2 = plot(ax, [meanValue meanValue], [0 yMax],...
            'Color', [254/255, 196/255, 79/255],...
            'LineStyle', '-',...
            'LineWidth', 2,...
            'DisplayName', 'arith. mean');
        hold all;
        legend(f2,{'arith. mean'});

    case 'median'
        % Plot the median
        medianValue = median(data);
        f2 = plot(ax, [medianValue medianValue], [0 yMax],...
            'Color',  [254/255, 196/255, 79/255],...
            'LineStyle', '--',...
            'LineWidth', 2,...
            'DisplayName', 'median');
        hold all;
        legend(f2,{'median'});

end

ylabel(ax, 'Density');
xlabel(ax, 'norm. log(grainDiameter(s))');
legend(ax, 'Location', 'northeast');
legend('boxoff');
axis tight;
hold off;

set(figH,'Name','Normalised lognormal distribution of grain diameter(s)','NumberTitle','on');
set(figH, 'PaperPositionMode', 'auto');
end
