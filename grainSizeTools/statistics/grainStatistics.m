function grainStatistics(data, varargin)
%% Options:
% ci                - @double, the certainty of the confidence interval
%                     A positive scalar value ranging between 0 and 1;
%                     default = 0.95
% bandWidth         - @char or @double, the method to estimate the
%                     bandwidth or a scalar directly defining the
%                     bandwidth. The @char options are:
%                     'silverman' or 'scott'; default = 'silverman'
% precision         - @double, the maximum precision expected for the
%                     "peak" kde-based estimator; default = 0.05. This
%                     variable is not related to confidence intervals.


% Delete NaNs and Infs from data (if any)
data = data(~isnan(data) & ~isinf(data));
% Check for and remove negative values from the data
if sum(data <= 0) > 0
    disp('Warning: Negative and/or zero values present in the data.');
    data = data(data > 0);
    disp('Negative/zero values were automatically removed');
    disp('');
end
data = data(:);

if length(data) <= 30
    smallDataset(data, varargin{:});

else
    largeDataset(data, varargin{:});
end

end






% -------------------------------------------------------------------------
function smallDataset(data, varargin)
%% Function description:
% Estimate the confidence interval using the t-distribution with (n - 1)
% degrees of freedom t(n - 1).
%
%% USER NOTES:
% This is default method when sample size is small (i.e. - n <= 30) and
% the standard deviation cannot be estimated accurately. For large
% datasets, the t-distribution approaches a normal distribution.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements:
% Dr. Marco A. Lopez-Sanchez
% For the original Python script named "conf_interval" at:
% https://github.com/marcoalopez/GrainSizeTools/blob/master/grain_size_tools/GrainSizeTools_script.py
%
%% Syntax:
%  smallDataset(data)
%
%% Input:
% confidenceLevel   - @double, the certainty of the confidence interval
%                     A positive scalar value ranging between 0 and 1;
%                     default = 0.95
%
%% Output:
% Output in the command window
%
%% Options:
% ci                - @double, the certainty of the confidence interval
%                     A positive scalar value ranging between 0 and 1;
%                     default = 0.95
%
%%


ci = get_option(varargin, 'ci', 0.95);


% Delete NaNs and Infs from data (if any)
data = data(~isnan(data) & ~isinf(data));
% Check for and remove negative values from the data
if sum(data <= 0) > 0
    disp('Warning: Negative and/or zero values present in the data.');
    data = data(data > 0);
    disp('Negative/zero values were automatically removed');
    disp('');
end
data = data(:);
n = length(data);
dof = n - 1;                                % degrees of freedom

arithMean = mean(data);                     % arithmetic mean
stdDev = std(data, 1);                      % Bessel corrected standard deviation

tScore = calcTScore(ci, n);                 % T-score

confInt = arithMean + (tScore * stdError);  % confidence interval
err = confInt(2) - arithMean;

disp(' ');
disp('=======================================');
disp(['Mean = ', num2str(arithMean, '%0.2f'), ' ± ', num2str(err, '%0.2f')]);
disp([num2str(100*ci),'% Confidence interval = [', num2str(confInt(1)), ', ', num2str(confInt(2)), ']']);
disp(['Max / min = ', num2str(arithMean + confInt(2), '%0.2f'), ' / ', num2str(arithMean + confInt(1), '%0.2f')]);
disp(['Estimated coefficients of variation']);
disp(['Lower bound = ',num2str(100 * (arithMean - confInt(1)) / arithMean), ' %']);
disp(['Upper bound = ',num2str(100 * (confInt(2) - arithMean) / arithMean), ' %']);
disp(['Coefficient of variation = ±', num2str(100 * err / arithMean, '%0.1f'), ' %']);
disp('=======================================');

end






% -------------------------------------------------------------------------
function largeDataset(data, varargin)
%% Function description:
% Estimate different grain size statistics. This includes different mean
% types, the median, the frequency peak grain size via KDE, the confidence
% intervals using different methods, and the distribution features.
%
%% USER NOTES:
% This function assumes the data follows a normal or symmetric
% distrubution when sample size is large.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements:
% Dr. Marco A. Lopez-Sanchez
% For the original Python script named "summarize" at:
% https://github.com/marcoalopez/GrainSizeTools/blob/master/grain_size_tools/GrainSizeTools_script.py
%
%% Syntax:
%  largeDataset(data)
%
%% Input:
% data              - @double, a data array
%
%% Output:
% Output in the command window
%
%% Options:
% ci                - @double, the certainty of the confidence interval
%                     A positive scalar value ranging between 0 and 1;
%                     default = 0.95
% bandWidth         - @char or @double, the method to estimate the
%                     bandwidth or a scalar directly defining the
%                     bandwidth. The @char options are:
%                     'silverman' or 'scott'; default = 'silverman'
% precision         - @double, the maximum precision expected for the
%                     "peak" kde-based estimator; default = 0.05. This
%                     variable is not related to confidence intervals.
%
%%


ci = get_option(varargin, 'ci', 0.95);
bandWidth = get_option(varargin, 'bandWidth', 'silverman');
precision = get_option(varargin, 'precision', 0.05);


% Delete NaNs and Infs from data (if any)
data = data(~isnan(data) & ~isinf(data));
% Check for and remove negative values from the data
if sum(data <= 0) > 0
    disp('Warning: Negative and/or zero values present in the data.');
    data = data(data > 0);
    disp('Negative/zero values were automatically removed');
    disp('');
end
data = data(:);


%% Estimate the Shapiro - Wilk test to check for normality and lognormality
% In Shapiro-Wilk tests, the chances of the null hypothesis being
% rejected becomes larger for large sample sizes.
% Consequently, the sample size is limited to a maximum of 250
if length(data) > 250
    [H, pValue, W] = shapiroWilk(datasample(data, 250,'replace',false), (1-ci));
    [log_H, log_pValue, log_W] = shapiroWilk(datasample(log(data), 250,'replace',false), (1-ci));
else
    [H, pValue, W] = shapiroWilk(data, (1-ci));
    [log_H, log_pValue, log_W] = shapiroWilk(log(data), (1-ci));
end

disp(' ');
disp('=======================================');
disp('CENTRAL TENDENCY ESTIMATORS');
disp('=======================================');

% switch avgType
%     case 'aMean'
if log_pValue < 0.05                 % Data is not lognormally distributed
    varargin = [varargin, 'method', 'ASTM'];
    outAMean = aMean(data, varargin{:});
else                                 % Data is lognormally distributed
    if length(data) > 99
        varargin = [varargin, 'method', 'mCox'];
        outAMean = aMean(data, varargin{:});
    else
        varargin = [varargin, 'method', 'GCI'];
        outAMean = aMean(data, varargin{:});
    end
end

% estimate the coefficients of variation
lowerCvar = 100 * (outAMean.mean - outAMean.lower) / outAMean.mean;
upperCvar = 100 * (outAMean.upper - outAMean.mean) / outAMean.mean;

disp(['Arithmetic mean = ',...
    num2str(outAMean.mean, '%0.2f'),...
    ' um']);

disp(['Confidence intervals at ',...
    num2str(ci * 100, '%0.1f'),...
    ' %']);

if log_pValue < 0.05                 % Data is not lognormally distributed
    disp(['ASTM (CLT) method: ',...
        num2str(outAMean.lower, '%0.2f'),...
        ' - ',...
        num2str(outAMean.upper, '%0.2f'),...
        ', (±',...
        num2str(100 * (outAMean.upper - outAMean.mean) / outAMean.mean, '%0.1f'),...
        '%), length = ',...
        num2str(outAMean.intLength, '%0.3f')]);
else                                 % Data is lognormally distributed
    if length(data) > 99
        disp(['mCox method: ',...
            num2str(outAMean.lower, '%0.2f'),...
            ' - ',...
            num2str(outAMean.upper, '%0.2f'),...
            ' (-', num2str(lowerCvar, '%0.1f'),...
            '%, +',...
            num2str(upperCvar, '%0.1f'),...
            '%), length = ',...
            num2str(outAMean.intLength, '%0.3f')]);
    else
        disp(['GCI method: ',...
            num2str(outAMean.lower, '%0.2f'),...
            ' - ',...
            num2str(outAMean.upper, '%0.2f'),...
            ' (-',...
            num2str(lowerCvar, '%0.1f'),...
            '%, +',...
            num2str(upperCvar, '%0.1f'),...
            '%), length = ',...
            num2str(outAMean.intLength, '%0.3f')]);
    end
end



varargin = delete_option(varargin, 'method');
%     case 'gMean'
if length(data) > 99
    varargin = [varargin, 'method', 'ASTM'];
    outGMean = gMean(data, varargin{:});
else
    varargin = [varargin, 'method', 'Bayesian'];
    outGMean = gMean(data, varargin{:});
end

% estimate the coefficients of variation
lowerCvar = 100 * (outGMean.mean - outGMean.lower) / outGMean.mean;
upperCvar = 100 * (outGMean.upper - outGMean.mean) / outGMean.mean;

disp('---------------------------------------');
disp(['Geometric mean = ',...
    num2str(outGMean.mean, '%0.2f'),...
    ' um']);

disp(['Confidence interval at ',...
    num2str(ci * 100, '%0.1f'),...
    ' %']);

if length(data) > 99
    disp(['ASTM (CLT) method: ',...
        num2str(outGMean.lower, '%0.2f'),...
        ' - ',...
        num2str(outGMean.upper, '%0.2f'),...
        ' (-',...
        num2str(lowerCvar, '%0.1f'),...
        '%, +',...
        num2str(upperCvar, '%0.1f'),...
        '%), length = ',...
        num2str(outGMean.intLength, '%0.3f')]);
else
    disp(['Bayesian method: ',...
        num2str(outGMean.lower, '%0.2f'),...
        ' - ',...
        num2str(outGMean.upper, '%0.2f'),...
        ' (-',...
        num2str(lowerCvar, '%0.1f'),...
        '%, +',...
        num2str(upperCvar, '%0.1f'),...
        '%), length = ',...
        num2str(outGMean.intLength, '%0.3f')]);
end


varargin = delete_option(varargin, 'method');
%     case 'median'
outMedian = mMedian(data, varargin{:});

% estimate coefficients of variation
lowerCvar = 100 * (outMedian.median - outMedian.lower) / outMedian.median;
upperCvar = 100 * (outMedian.upper - outMedian.median) / outMedian.median;

disp('---------------------------------------');
disp(['Median = ',...
    num2str(outMedian.median, '%0.2f'),...
    ' microns']);

disp(['Confidence interval at ',...
    num2str(ci * 100, '%0.1f'),...
    ' %']);

disp(['Robust method: ',...
    num2str(outMedian.lower, '%0.2f'),...
    ' - ',...
    num2str(outMedian.upper, '%0.2f'),...
    ' (-',...
    num2str(lowerCvar, '%0.1f'),...
    '%, +',...
    num2str(upperCvar, '%0.1f'),...
    '%), length = ',...
    num2str(outMedian.intLength, '%0.3f')]);



%     case 'mode'
outMode = freqPeak(data, varargin{:});

disp('---------------------------------------');
disp(['Mode (KDE-based) = ',...
    num2str(outMode.mode, '%0.2f'),...
    ' um']);

disp(['Maximum precision set to ',...
    num2str(precision)]);

if ischar(bandWidth)
    bandWidth(1) = upper(bandWidth(1));
    disp(['KDE bandwidth = ', num2str(outMode.bw), ' (', bandWidth, ' rule-of-thumb)'])
else
    disp(['KDE bandwidth = ', num2str(outMode.bw)])
end
% end



disp(' ');
disp('=======================================');
disp('DISTRIBUTION FEATURES');
disp('=======================================');
disp(['Sample size (n) = ', num2str(length(data))])
disp(['Standard deviation = ', num2str(std(data), '%0.2f'), ' (1-sigma)'])
% switch avgType
%     case 'gMean'
disp(['Lognormal shape (multiplicative standard deviation) = ', num2str(outGMean.stdDev, '%0.2f')]);

%     case 'median'
disp(['Interquartile range (IQR) = ', num2str(outMedian.iqr, '%0.2f')]);
% end



disp('---------------------------------------');
disp('Shapiro-Wilk tests for normality and lognormality');
if H == 0 || pValue > 0.05
    disp('Data is normally distributed.');
else
    disp('Data is not normally distributed.');
end
disp(['Normality test: ',...
    num2str(W, '%0.2f'),...
    ', ',...
    num2str(pValue, '%0.2f'),...
    ' (test statistic, p-value)']);

if log_H == 0 || log_pValue > 0.05
    disp('Data is lognormally distributed.')
else
    disp('Data is not lognormally distributed.')
end
disp(['Lognormality test: ',...
    num2str(log_W, '%0.2f'),...
    ', ',...
    num2str(log_pValue, '%0.2f'),...
    ' (test statistic, p-value)']);
disp('=======================================');

end
