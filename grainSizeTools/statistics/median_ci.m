function out = median_ci(data, varargin)
%% Function description:
% Estimate the approximate confidence interval (ci) error margins for the 
% median using a rule of thumb based on Hollander and Wolfe (1999).
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
%  median_ci(data, ci)
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
n = length(data);
dof = n - 1;

tScore = calcTScore(ci, n);                 % T-score

idLower = (n / 2) - (tScore * sqrt(n)) / 2;
idUpper = 1 + (n / 2) + (tScore * sqrt(n)) / 2;

if ceil(idUpper) >= length(data)
    upper = data(end);
    lower = data(floor(idLower));
else
    upper = data(ceil(idUpper));
    lower = data(floor(idLower));
end

confInt = [lower, upper];
intLength = upper - lower;

out.lower = lower;
out.upper = upper;
out.intLength = intLength;

end
