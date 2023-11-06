function out = CLT2_ci(data, varargin)
%% Function description:
% Returns the error margin for the geometric mean based on the central
% limit theorem and the t-statistics.
%
% This is the method described in the ASTM standard E112-12 (1996):
% Standard test methods for determining average grain size.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements:
% Dr. Marco A. Lopez-Sanchez
% For the original Python script at:
% https://github.com/marcoalopez/GrainSizeTools/blob/master/grain_size_tools/averages.py
%
%% Syntax:
%  CLT2_ci(data, ci)
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
data = log(data);
data = data(:);
n = length(data);

arithMean = mean(data);                     % arithmetic mean
stdDev = std(data,1);                       % Bessel corrected standard deviation

tScore = calcTScore(ci, n);                 % T-score

% Estimate confidence limits
lower = exp(arithMean - tScore * (stdDev / sqrt(n)));
upper = exp(arithMean + tScore * (stdDev / sqrt(n)));
confInt = [lower, upper];
intLength = upper - lower;

out.mean = exp(arithMean);
out.stdDev = exp(stdDev);
out.lower = lower;
out.upper = upper;
out.intLength = intLength;

end
