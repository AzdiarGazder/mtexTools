function out = CLT_ci(data, varargin)
%% Function description:
% Estimate the error margin for the arithmetic mean based on the central 
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
%  CLT_ci(data, ci)
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
data = data(:);
n = length(data);

arithMean = mean(data);                    % arithmetic mean
stdDev = std(data,1);                      % Bessel corrected standard deviation

tScore = calcTScore(ci,n);                 % T-score
err = tScore * stdDev / sqrt(n);           % standard error

% Estimate confidence limits
lower = arithMean - err;
upper = arithMean + err;
% confInt = [lower, upper];
intLength = upper - lower;

out.mean = arithMean;
out.stdDev = stdDev;
out.lower = lower;
out.upper = upper;
out.intLength = intLength;

end

