function plot_qq(data, varargin)
%% Function description:
% Plots the test of a dataset if it follows a lognormal distribution 
% using a quantile–quantile (q-q) plot and a Shapiro-Wilk test.
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
% plot_qq(data)
%
%% Input:
% data              - @double, a data array
%
%% Output:
% none
%
%% Options:
% ci                - @double, the certainty of the confidence interval
%                     A positive scalar value ranging between 0 and 1;
%                     default = 0.95
% interval          - @double,  the percentile interval to estimate; 
%                     default = 2% 
%%


ci = get_option(varargin, 'ci', 0.95);
interval = get_option(varargin,'interval',2);


data = data(~isnan(data) & ~isinf(data));   % omit NaNs and Infs (if any)
data = log(data);
data = data(:);

% Estimate percentiles in the actual data
pctl = 0:interval:100;
actualData = prctile(data, pctl);
idx1 = ~isnan(actualData) & ~isinf(actualData);

% Estimate percentiles for the theoretical data
amean = mean(data);
stdDev = std(data);
theoreticalData = norminv(pctl / 100, amean, stdDev);
idx2 = ~isnan(theoreticalData) & ~isinf(theoreticalData);

% Omit NaNs and Infs (if any)
idx = idx1 & idx2;
actualData = actualData(idx);
theoreticalData = theoreticalData(idx);

minValue = min(theoreticalData);
maxValue = max(theoreticalData);


%% Estimate the Shapiro - Wilkes test to check for lognormality
% In Shapiro-Wilkes tests, the chances of the null hypothesis being
% rejected becomes larger for large sample sizes.
% Consequently, the sample size is limited to a maximum of 250
if length(data) > 250
    [H, log_pValue, log_W] = shapiroWilk(datasample(data, 250,'replace',false), (1-ci));
else
    [H, log_pValue, log_W] = shapiroWilk(data, (1-ci));
end

disp(' ');
disp('=======================================');
disp('DESCRIPTIONS from plot_qq');
disp('Shapiro-Wilk test for lognormality');
if H == 0 || log_pValue > 0.05
    disp('Data is lognormally distributed.');
else
    disp('Data is not lognormally distributed.');
end
disp(['Lognormality test: ',...
    num2str(log_W, '%0.2f'),...
    ', ',...
    num2str(log_pValue, '%0.2f'),...
    ' (test statistic, p-value)']);
disp('=======================================');


% Plot the figure
figH = figure;
set(findall(gcf, '-property', 'FontSize'), 'FontSize', 14);
ax = gca;

plot(theoreticalData, actualData,...
    'o',...
    'MarkerFaceColor', [130/255 200/255 235/255],...
    'MarkerEdgeColor', [100/255 180/255 205/255],...
    'MarkerSize', 12,...
    'LineWidth', 2,...
    'DisplayName', 'observed');
hold all;

plot([minValue, maxValue], [minValue, maxValue],...
    'Color', [47/255, 72/255, 88/255],...
    'LineStyle', '-',...
    'LineWidth', 2,...
    'DisplayName', 'perfect lognormal');

xlabel('Theoretical');
ylabel('Observed');
legend('Location', 'southeast');
legend('boxoff');
axis tight;
hold off;

set(figH,'Name','Lognormal distribution of grain diameter(s) on a quantile-quantile plot','NumberTitle','on');
set(figH, 'PaperPositionMode', 'auto');
end