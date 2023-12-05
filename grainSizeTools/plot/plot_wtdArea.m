function plot_wtdArea(data, dataArea, varargin)
%% Function description:
% Plots an area-weighted histogram of a dataset and displays different 
% area-weighted statistics.
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
% plot_wtdArea(data,area)
%
%% Input:
% data              - @double, a data array
% area              - @double, a data array against which the "data" array
%                     is normalised
%
%% Output:
% none
%
%% Options:
% binSize           - @char or @double, defines the plug-in method to
%                     calculate the bin size. The @char options are:
%                     'auto', 'doane', 'fd', 'rice', 'scott', 'sqrt',
%                     'sturges'; default = 'auto'.
%
%%


binSize = get_option(varargin,'binSize','auto'); 


% Estimate weighted mean
totalArea = sum(dataArea);
wtdArea = dataArea / totalArea;
wtdMean = sum(data .* wtdArea);

% Estimate mode interval
if isnumeric(binSize)
    [histogram,binEdges,~] = histcounts(data, binSize);
    h = binSize;

else
    [histogram,binEdges,~] = histcounts(data, 'BinMethod', binSize);
    h = binEdges(2) - binEdges(1);
end

% Estimate the cumulative areas of each grain size interval
cumArea = zeros(size(binEdges));
for index = 1:length(binEdges)
    if index == length(binEdges)
        mask = data >= binEdges(index);
    else
        mask = data >= binEdges(index) & data < (binEdges(index) + h);
    end
    if any(mask)
        area_sum = sum(dataArea(mask));
        cumArea(index) = round(area_sum, 1);
    end
end
% Find max excluding zero values
[~, getIndex] = max(cumArea(cumArea > 0)); 

disp(' ');
disp('=======================================');
disp('DESCRIPTIVE STATISTICS from plot_wtdArea');
disp(['Area-weighted mean = ', num2str(wtdMean), ' um']);
disp('---------------------------------------');
disp('HISTOGRAM FEATURES from plot_wtdArea');
disp(['Modal interval = ', num2str(binEdges(getIndex)),' - ', num2str(binEdges(getIndex) + h), ' um']);
if ischar(binSize)
    disp(['Number of classes = ', num2str(length(histogram))]);
    disp(['As per the ', binSize, ' rule, the bin size = ', num2str(h)]);
end
disp('=======================================');

% Normalise the y-axis values to a percentage of the total area
totalArea = sum(cumArea);
norm_cumArea = (cumArea / totalArea);
maxValue = max(norm_cumArea);

yOffset = 0.025;
% plot the figure
figH = figure;
set(findall(gcf, '-property', 'FontSize'), 'FontSize', 14);
ax = axes;

f1 = bar(ax, binEdges, norm_cumArea,...
    'FaceColor', [84/255, 168/255, 106/255],...
    'EdgeColor', [153/255, 255/255, 164/255],...
    'LineWidth', 2);
hold all;

f2 = plot(ax, [wtdMean wtdMean], [0, (maxValue + yOffset)],...
    'Color', [254/255, 196/255, 79/255],...
    'LineStyle', '-',...
    'LineWidth', 1.5,...
    'DisplayName', 'area wtd. mean');
hold off;


ylim([0 (maxValue + yOffset)]);
ylabel(ax,'Normalised area fraction');
xlabel(ax,'Apparent size');
legend(f2,{'area wtd. mean'});
legend(ax, 'Location', 'northeast');
legend('boxoff');
% axis tight;
hold off;

set(figH,'Name','Distribution of area weighted grain diameter(s)','NumberTitle','on');
set(figH, 'PaperPositionMode', 'auto');
end
