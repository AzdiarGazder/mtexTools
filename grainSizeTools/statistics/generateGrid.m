function grid = generateGrid(start, stop, varargin)
%% Function description:
% Returns an equispaced grid of discretised values over the sample space 
% with a fixed range and desired precision.
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
%  freqPeak(data, varargin)
%
%% Input:
% start             - @double, the starting value of the sequence
% stop              - @double, the end value of the sequence
% precision         - @double, the desired precision (density) of the array
%                     
%% Output:
% grid              - @double
%
%% Options:
% none
%
%%

precision = get_option(varargin,'precision',0.05);
range = stop - start;

% Check if range > precision
if range < precision
    error('The precision must be smaller than the range of grain sizes');
else
    n = round(range / precision);
end

grid = linspace(start, stop, n);
end