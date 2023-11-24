function threshold = calcThreshold(inData,varargin)
%% Function description:
% This function calculates a threshold based on:
% (1) the cumulative distribution function (CDF) of a given dataset, OR
% (2) the differential of the CDF of a given dataset.
% In both cases, the bin widths of the CDF are calculated using either
% Scott's, Freedman-Diaconis', or the square root rules, or by specifying
% a value.
% In Case (1), the threshold is determined by a specified number of
% standard deviations from the mean of the data.
% In Case (2), the threshold is determined by fitting a Gaussian to the
% differential data and finding the specified number of standard deviations
% from the mid-point of the fitted Gaussian.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  calcThreshold(data)
%
%% Input:
%  data         - @double, a n x 1 array
%
%% Options:
%  'cdf'/'dcdf' - @char, specify the plot type, default = 'cdf'
%  'scott'      - @char, calculate an optimal bin width for the cdf using
%                 Scott's rule
%  'fd'         - @char, calculate an optimal bin width for the cdf using
%                 the Freedman-Diaconis' rule
%  'sqrt'       - @char, calculate an optimal bin width for the cdf using
%                 the square root rule
%  'binWidth'   - @double, specify a bin width for the cdf
%  'sigma'      - @double, sigma value to compute the threshold,
%                 default = 3


% Specify if the CDF or dCDF requires thresholding
plotType = char(extract_option(varargin,{'cdf','dcdf'}));
if isempty(plotType)
    plotType = 'cdf';
    warning('Plot types ''cdf'' or ''dcdf'' not specified. Default ''cdf'' will be used.');
end

% Specify the bin width
binWidth = get_option(varargin,'binWidth',[]);
if isempty(binWidth)
    if check_option(varargin,'scott')
        % Calculate Scott's rule for optimal bin width
        binWidth = 3.5 * std(inData) / numel(inData)^(1/3);

    elseif check_option(varargin,'fd')
        % Calculate the Freedman-Diaconis' rule for optimal bin width
        iqrValue = iqr(inData);
        binWidth = 2 * iqrValue / numel(inData)^(1/3);

    elseif check_option(varargin,'sqrt')
        % Calculate the square root rule for optimal bin width
        binWidth = range(inData) / sqrt(numel(inData));

    else % since nothing is defined, set bin width defaults
        binWidth = 0.01;

    end
end

% Specify the user-defined sigma value to threshold
thresholdSigma = get_option(varargin,'sigma',3);

% Specify whether to show the plot or not
flagSilent = check_option(varargin,'silent');


% Calculate the number of bins
numBins = ceil(range(inData) / binWidth);

% Bin the data using the specified step size
[counts, binEdges] = histcounts(inData, 'BinWidth', binWidth, 'NumBins', numBins);

% Calculate bin centers
binCenters = binEdges(1:end-1) + binWidth/2;

% Calculate the PDF
pdf = counts / (sum(counts) * binWidth);

% Calculate the CDF
cdf = cumsum(pdf * binWidth);
% cdf = [0, cdf];


switch plotType
    case 'cdf'
        % Calculate mu and sigma
        mu = mean(inData);
        sigma = std(inData);

        % Calculate the lower and upper bounds based on the threshold sigma
        lowerBound = mu - (thresholdSigma * sigma);
        upperBound = mu + (thresholdSigma * sigma);
        % Calculate the theoretical probability based on the lower and upper bounds
        theoProb = normcdf(upperBound, mu, sigma) - normcdf(lowerBound, mu, sigma);
        % Since the data does have negative numbers, min(lowerBound) = 0
        if lowerBound < 0
            lowerBound = 0;
        end
        % Calculate the actual probability (varies from theoretical probability
        % when theoretical min(lowerBound) < 0)
        actProb = normcdf(upperBound, mu, sigma) - normcdf(lowerBound, mu, sigma);

        % Calculate the threshold
        [~, idxX] = min(abs(binCenters - upperBound));
        threshold.x = binCenters;
        threshold.y = cdf;
        threshold.id = idxX;

        % Display the results
        disp('----');
        disp(['Mean (mu): ' num2str(mu)]);
        disp(['Standard deviation (sigma): ' num2str(sigma)]);
        disp(['Lower bound for ',num2str(thresholdSigma),'-sigma: ' num2str(lowerBound)]);
        disp(['Upper bound for ',num2str(thresholdSigma),'-sigma: ' num2str(upperBound)]);
        disp(['Theoretical probability within ',num2str(thresholdSigma),'-sigma: ' num2str(theoProb)]);
        disp(['Actual probability within ',num2str(thresholdSigma),'-sigma: ' num2str(actProb)]);
        disp('----');

        if ~flagSilent
            % Plot the PDF
            figure;
            subplot(2, 1, 1);
            bar(binCenters, pdf, 'hist');
            hold all;
            % Highlight threshold sigma bounds on the PDF plot
            fill([lowerBound, upperBound, upperBound, lowerBound], [0, 0, max(pdf), max(pdf)], 'r', 'FaceAlpha', 0.1667);
            line([lowerBound, lowerBound], ylim, 'Color', 'k', 'LineWidth', 3, 'LineStyle', '--');
            line([upperBound, upperBound], ylim, 'Color', 'k', 'LineWidth', 3, 'LineStyle', '--');
            legend('PDF', [num2str(thresholdSigma),'-sigma bounds']);
            % title('Probability density function (PDF)');
            xlim([0 max(binCenters)]);
            ylim([0 max(pdf)]);
            hold off;
        end

    case 'dcdf'
        % Differentiate the CDF
        dydx = diff(cdf) ./ diff(binCenters);
        dydx = [0, dydx];

        % Fit a Gaussian to the differential data
        fitResult = fit(binCenters', dydx', 'gauss1');
        % Get the mid-point and sigma values
        midPoint = fitResult.b1;
        sigma = fitResult.c1 / sqrt(2); % standard deviation

        % Calculate the fitted Gaussian data
        dydxFit = fitResult(binCenters);
        dydxFit = dydxFit';

        % Calculate the lower and upper bounds of the Gaussian based on the threshold sigma
        lowerBound = midPoint - (thresholdSigma * sigma);
        % Since the data does have negative numbers, min(lowerBound) = 0
        if lowerBound < 0
            lowerBound = 0;
        end
        upperBound = midPoint + (thresholdSigma * sigma);

        % Calculate the threshold
        [~, idxX] = min(abs(binCenters - upperBound));
        threshold.x = binCenters;
        threshold.y = cdf;
        threshold.id = idxX;

        % Display the results
        disp('----');
        disp(['Mid-point: ' num2str(midPoint)]);
        disp(['Standard deviation (sigma): ' num2str(sigma)]);
        disp('----');

        if ~flagSilent
            % Plot the differential
            figure;
            subplot(2, 1, 1);
            bar(binCenters, dydx, 'hist');
            hold all;
            plot(binCenters,dydxFit, 'Color', 'g', 'LineWidth', 3, 'LineStyle', '-');
            % Highlight threshold sigma bounds on the differential plot
            fill([lowerBound, upperBound, upperBound, lowerBound], [0, 0, max(pdf), max(pdf)], 'r', 'FaceAlpha', 0.1667);
            line([lowerBound, lowerBound], ylim, 'Color', 'k', 'LineWidth', 3, 'LineStyle', '--');
            line([upperBound, upperBound], ylim, 'Color', 'k', 'LineWidth', 3, 'LineStyle', '--');
            legend('d(CDF)/d(binCenters)', 'Gaussian fit', [num2str(thresholdSigma),'-sigma bounds']);
            % title('Differential function (dCDF)');
            xlim([0 max(binCenters)]);
            ylim([0 max([dydx,dydxFit])]);
            hold off;
        end

end

if ~flagSilent
    % Plot the CDF
    subplot(2, 1, 2);
    plot([0, binCenters], [0, cdf], 'b', 'LineWidth', 2);
    hold all;
    % Highlight threshold sigma bounds on the PDF plot
    fill([lowerBound, upperBound, upperBound, lowerBound], [0, 0, max(cdf), max(cdf)], 'r', 'FaceAlpha', 0.1667);
    line([lowerBound, lowerBound], ylim, 'Color', 'k', 'LineWidth', 3, 'LineStyle', '--');
    line([upperBound, upperBound], ylim, 'Color', 'k', 'LineWidth', 3, 'LineStyle', '--');
    % Plot the threshold point
    scatter(threshold.x(idxX), threshold.y(idxX),...
        75, 'g', 'filled', 'DisplayName', 'thresholdSigma');
    legend('CDF', [num2str(thresholdSigma),'-sigma bounds']);
    % title('Cumulative distribution function (CDF)');
    xlim([min(binCenters) max(binCenters)]);
    ylim([0 max(cdf)]);
    hold off;

    % Link x-axes of the two subplots
    linkaxes([subplot(2, 1, 1), subplot(2, 1, 2)], 'x');
end

end