function out = gMean(data, varargin)
%% Function description:
% Returns the geometric mean, the multiplicative (geometric) standard 
% deviation, and the confidence interval based on the chosen method.
%
%% USER NOTES:
% This function is based on the following assumptions:
% - the geometric mean is optimal for lognormal-like distributions
% - the multiplicative standard deviation is a measure of the lognormal 
%   shape
% - The Bayesian method is sometimes slightly superior to CLT for
%   very small (< 100) sample sizes
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements:
% Dr. Marco A. Lopez-Sanchez
% For the original Python script at:
% https://github.com/marcoalopez/GrainSizeTools
%
%% Syntax:
%  aMean(data, ci, method)
%
%% Input:
% data              - @double, a data array
%
%% Output:
% mean              - @double, the arithmetic mean
% stdDev            - @double, the Bessel corrected standard deviation
% confInt           - @double, the lower and upper confidence
%                     intervals (tuple)
% intLength         - @double, the interval length (scalar)
%
%% Options:
% ci                - @double, the certainty of the confidence interval
%                     A positive scalar value ranging between 0 and 1;
%                     default = 0.95
% method            - @char, the method to estimate the confidence 
%                     interval The options are:
%                     'ASTM': central limit theorem based (default)
%                     'Bayesian': Bayesian based method
%
%%


method = get_option(varargin,'method','ASTM');

switch method
    case 'ASTM'
        out = CLT2_ci(data, varargin{:});
    case 'Bayesian'
        out = bayesian_ci(data, varargin{:});
    otherwise
        error('Confidence interval methods must be ''ASTM'', or ''Bayesian''');
end


