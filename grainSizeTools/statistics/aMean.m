function out = aMean(data, varargin)
%% Function description:
% Returns the arithmetic mean, the Bessel corrected standard deviation,
% and the confidence interval based on the chosen method.
%
%% USER NOTES:
% This function is based on the following assumptions:
% - arithmetic mean is optimal for normal-like distributions
% - CLT confidence interval is optimised for normal distributions
% - GCI and mCox methods are optimised for lognormal distributions
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
%                     'GCI': generalised confidence interval method
%                     'mCox': modified Cox method
%
%%


method = get_option(varargin,'method','ASTM');

switch method
    case 'ASTM'
        out = CLT_ci(data, varargin{:});
    case 'GCI'
        out = GCI_ci(data, varargin{:});
    case 'mCox'
        out = mCox_ci(data, varargin{:});
    otherwise
        error('Confidence interval methods must be ''ASTM'', ''GCI'', or ''mCox''');
end


