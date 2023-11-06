function out = mCox_ci(data, varargin)
%% Function description:
% Returns the error margin for the arithmetic mean using the modified
% Cox method.
%
%% USER NOTES:
% This fucntion assumes the population follows a lognormal distribution
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
% BG Armstrong, Confidence intervals for arithmetic means of lognormally 
% distributed exposures, American Industrial Hygiene Association Journal, 
% Volume 53, Issue 8, 1992, Pages 481 - 485. 
% https://doi.org/10.1080/15298669291360003
%
%% Syntax:
%  mCox_ci(data, ci)
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


data = data(~isnan(data) & ~isinf(data));  % omit NaNs and Infs (if any)
data = log(data);
data = data(:);
n = length(data);

arithMean = mean(data);                    % arithmetic mean
stdDev = std(data,1);                      % Bessel corrected standard deviation

tScore = calcTScore(ci,n);                 % T-score

% Estimate confidence limits
lower = exp(arithMean + 0.5 * stdDev^2 - tScore * (stdDev / sqrt(n)) * sqrt(1 + (stdDev^2 * n) / (2 * (n + 1))));
upper = exp(arithMean + 0.5 * stdDev^2 + tScore * (stdDev / sqrt(n)) * sqrt(1 + (stdDev^2 * n) / (2 * (n + 1))));
confInt = [lower, upper];
intLength = upper - lower;

out.mean = arithMean;
out.stdDev = stdDev;
out.lower = lower;
out.upper = upper;
out.intLength = intLength;

end

