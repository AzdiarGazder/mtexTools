function out = GCI_ci(data, varargin)
%% Function description:
% Returns the confidence interval for the arithmetic mean using the
% generalised confidence interval (GCI) method of Krishnamoorthy and
% Mathew (2003). This is a Monte Carlo method optimised for lognormal
% populations.
%
%% USER NOTES:
% This function assumes the population follows a lognormal distribution.
%
%% Authors:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
% Dr. Marco A. López Sánchez, 2023, marcoalopezatoutlookdotcom
%
%% Acknowledgements:
% Dr. Marco A. López Sánchez
% For the original Python script at:
% https://github.com/marcoalopez/GrainSizeTools/blob/master/grain_size_tools/averages.py
%
%% Reference:
% K Krishnamoorthy, T Mathew, Inferences on the means of lognormal
% distributions using generalized p-values and generalized confidence
% intervals, Journal of Statistical Planning and Inference, Volume 115,
% Issue 1, 2003, Pages 103-121.
% https://doi.org/10.1016/S0378-3758(02)00153-2

%% Syntax:
%  GCI_ci(data, ci)
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
% runs              - @double, defines the number of Monte Carlo 
%                     iterations to generate zArray and uArray values
%
%%


ci = get_option(varargin, 'ci', 0.95);
alpha = 1 - ci;

% Define the number of Monte Carlo iterations to generate zArray and 
% uArray values
runs = get_option(varargin,'runs',1E4);

fx = 'GCI_ci';
if nargin + nargin(fx) == 0
    warning('GCI_ci assumes the default confidence level = 0.95');
    ci = 0.95;
end


data = data(~isnan(data) & ~isinf(data));  % omit NaNs and Infs (if any)
% data = log(data);
data = data(:);
n = length(data);
dof = n - 1;                               % degrees of freedom

arithMean = mean(data);                    % arithmetic mean
stdDev = std(data,1);                      % Bessel corrected standard deviation

variance = var(log(data),0,"all");              % variance
% When w = 0 (default), the variance is normalised by (n - 1), where n is
% the size of the population.
% When w = 1, the variance is normalised by the population size.

%% Generate random values from the normal N(0,1) distribution
% rng('default');                           % for reproducibility
zArray = normrnd(0, 1, [runs,1]);

%% Generate random values from a non-central chi-square distribution
% with (n - 1) degrees of freedom
% Define the non-centrality parameter (lambda)
% Since this is set to 0 in the original script, random samples are being 
% generated from a central chi-square distribution
lambda = 0;
% Generate random values
uArray = sqrt(ncx2rnd(dof, lambda, [runs,1]));

tArray = calcGCIEq(arithMean, variance, zArray, uArray, n);
tArray = sort(tArray);

% Estimate confidence limits
lower = prctile(tArray, 100 * (alpha / 2));
upper = prctile(tArray, 100 * (1 - (alpha / 2)));
% confInt = [lower, upper];
intLength = upper - lower;

out.mean = arithMean;
out.stdDev = stdDev;
out.lower = lower;
out.upper = upper;
out.intLength = intLength;

end



function out = calcGCIEq(arithMean, variance, zArray, uArray, n)
%% Function description:
% Helper function to calculate the GCI equation
% Estimate the second and third terms of the equation
secondTerm = (zArray ./ (uArray ./ sqrt(n - 1))) .* (sqrt(variance) ./ sqrt(n));
thirdTerm = 0.5 .* variance ./ (uArray.^2 ./ (n - 1));
out = exp(arithMean - secondTerm + thirdTerm);
end


