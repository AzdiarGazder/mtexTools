function out = bayesian_ci(data, varargin)
%% Function description:
% Use a Bayesian approach to estimate the confidence intervals of the
% geometric mean.
%
%% USER NOTES:
% This function assumes the population follows a lognormal distribution
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
% TE Oliphant, A Bayesian perspective on estimating mean, variance, and 
% standard-deviation from data, Faculty Publications. 278, 2006.
% https://scholarsarchive.byu.edu/facpub/278
%
%% Syntax:
%  bayesian_ci(data, ci)
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

% Calculate posterior parameters
arithMean = mean(data);                     % arithmetic mean
variance = var(data,0,"all");               % variance

tScore = calcTScore(ci, n);                 % T-score

% Define prior parameters
log_priorMean = 0;      % prior mean
log_priorVariance = 1;  % prior variance

% Calculate posterior parameters in log scale
log_posteriorMean = (log_priorVariance*log_priorMean + variance*arithMean) / ...
    (log_priorVariance + variance);
log_posteriorVariance = 1 / (1/log_priorVariance + n/variance);
% log_posteriorStdDev = sqrt(log_posteriorVariance);

% Estimate confidence limits
halfWidth = tScore * sqrt(log_posteriorVariance / n);
lower = log_posteriorMean - halfWidth;
upper = log_posteriorMean + halfWidth;

% % Transform results back to the original scale
posteriorMean = exp(log_posteriorMean + log_posteriorVariance/2);
% posteriorVariance = (exp(log_posteriorVariance) - 1) * exp(2 * log_posteriorMean + log_posteriorVariance);
posteriorStdDev = sqrt(log_posteriorVariance);
lower = exp(lower);
upper = exp(upper);
confInt = [lower, upper];
intLength = upper - lower;


% % Display the results
% disp(['Bayesian mean = ' num2str(posteriorMean)]);
% disp(['Bayesian variance = ' num2str(posteriorVariance)]);
% disp(['Bayesian standard deviation = ' num2str(posteriorStdDev)]);
% disp([num2str(100*ci),'% Confidence interval for the Bayesian mean = [' num2str(lower) ', ' num2str(upper) ']']);

out.mean = posteriorMean;
out.stdDev = posteriorStdDev;
out.lower = lower;
out.upper = upper;
out.intLength = intLength;

end




function t = calcTScore(ci, n)
%% Function description:
% Helper function to calculate the (two-tailed) critical value of the
% t-distribution
%
%% USER NOTES:
% This function assumes the population is symmetric.
%
%%

% Recalculate confidence for the two-tailed t-distribution
ci = ci + ((1 - ci) / 2);
% Calculate the two-tailed critical value of t-distribution
t = tinv(ci, n);

end