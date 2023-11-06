function out = mMedian(data, varargin)
%% Function description:
% Returns the median, the interquartile length, and the confidence
% intervals for the median based on th rule-of-thumb method of Hollander
% and Wolfe (1999).
%
%% USER NOTES:
% This function is based on the following assumptions:
% - median is optimal for both normal and lognormal-like distributions.
%   It behaves better than means when data contamination is expected
%   (i.e. more robust).
% - the interquertile length/range is a measure of the spread of
%   the distribution.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements:
% Dr. Marco A. Lopez-Sanchez
% For the original Python script at:
% https://github.com/marcoalopez/GrainSizeTools/blob/master/grain_size_tools/averages.py
%
%% Reference:
% Hollander and Wolfe (1999) Nonparametric Statistical Methods, 3rd editon,
% John Wiley, New York, pp. 787
%
%% Syntax:
%  median(data)
%
%% Input:
% data              - @double, a data array
%
%% Output:
% out               - @struc
%
%% Options:
% ci                - @double, the certainty of the confidence interval
%                     A positive scalar value ranging between 0 and 1;
%                     default = 0.95
%
%%


ci = get_option(varargin, 'ci', 0.95);


data = data(~isnan(data) & ~isinf(data));   % omit NaNs and Infs (if any)
data = data(:);
data = sort(data);

% Compute the median and interquartile range
medianValue = median(data);
iqrRange = iqr(data);

% Compute confidence intervals
out = median_ci(data, varargin{:});
out.median = medianValue;
out.iqr = iqrRange;

end