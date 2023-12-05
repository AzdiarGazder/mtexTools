function t = calcTScore(ci, n)
%% Function description:
% Calculates the (two-tailed) critical value of the t-distribution
%
%% USER NOTES:
% This function assumes the population is symmetric.
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements:
% Dr. Marco A. Lopez-Sanchez
% For the original Python script at:
% https://github.com/marcoalopez/GrainSizeTools/blob/master/grain_size_tools/averages.py
% 
%% Syntax:
%  calcTScore(ci, n)
%
%% Input:
% ci                - @double, the certainty of the confidence interval
%                     A positive scalar value ranging between 0 and 1;
%                     default = 0.95
% n                 - @double, number of points in the dataset
%
%% Output:
% t                 - @double, the critical value of the (two-tailed) 
%                     t-distribution
%
%% Options:
% none
%
%%

% Recalculate confidence for the two-tailed t-distribution
ci = ci + ((1 - ci) / 2);

% Estimate the degrees of freedom
nu = max(0, n - 1);

% Calculate the two-tailed critical value of t-distribution
t = tinv(ci, nu);

end