function out = freqPeak(data, varargin)
%% Function description:
% Returns the peak of the frequency ("mode") of a continuous
% distribution based on the Gaussian kernel density estimator.
%
%% Authors:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
% Dr. Marco A. López Sánchez, 2023, marcoalopezatoutlookdotcom
%
%% Acknowledgements:
% Dr. Marco A. López Sánchez
% For the original Python script at:
% https://github.com/marcoalopez/GrainSizeTools
%
%% Syntax:
%  freqPeak(data, varargin)
%
%% Input:
% data              - @double, a data array
%                     
%% Output:
% out               - @struc
%
%% Options:
% bandWidth         - @char or @double, the method to estimate the 
%                     bandwidth or a scalar directly defining the 
%                     bandwidth. The @char options are:
%                     'silverman' or 'scott'; default = 'silverman'
% precision         - @double, the maximum precision expected for the
%                     "peak" kde-based estimator; default = 0.05. This 
%                     variable is not related to confidence intervals.
%
%%


bandWidth = get_option(varargin,'bandWidth','silverman');
precision = get_option(varargin,'precision',0.05);

% Check if bandwidth is a string or is numeric and set the bw accordingly
if ischar(bandWidth)
    switch bandWidth
        case 'silverman'
            bw = 1.06 * std(data) * numel(data)^(-1/5);
        case 'scott'
            bw = 3.5 * std(data) * numel(data)^(-1/3);
        otherwise
            error('Invalid bandwidth parameter.');
    end

elseif isnumeric(bandWidth)
    bw = bandWidth / std(data, 1);

else
    error('Invalid bandwidth parameter.');
end

% Estimate the Gaussian kernel density function
[kde, xi] = ksdensity(data, 'Kernel', 'normal', 'Bandwidth', bw);

% Find peak grain size
[yMax, idx] = max(kde);
modeValue = xi(idx);

% Generate xGrid and yGrid
xGrid = generateGrid(min(data), max(data), precision);
yGrid = interp1(xi, kde, xGrid, 'spline');
% Scale yGrid to data maximum
yGrid = yGrid .* (max(data) / max(yGrid));


% Output tuple
out.x = xi;
out.densities = kde;

out.xGrid = xGrid;
out.yGrid = yGrid;

out.mode = modeValue;
out.peakDensity = yMax;
out.bw = bw;

end


