function out = calcInflection(inData,varargin)
%% Function description:
% This function calculates the inflection point of a cumulative 
% distribution function (CDF) that contains two populations with different 
% magnitudes of a given variable. The inflection point is defined as the 
% furthest point from a line connecting the first and last points of the 
% CDF. The bin widths of the CDF are calculated from a probability 
% distribution function (PDF) using either Scott's, Freedman-Diaconis', or 
% the square root rules, or by specifying a value.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements: 
% Dr. Andrew J. Cross, Washington University in St. Louis
% For the description and script published in:
% AJ Cross, DJ Prior, M Stipp, S Kidder, The recrystallized grain size 
% piezometer for quartz: An EBSD-based calibration, Geophysical Research
% Letters, https://doi.org/10.1002/2017GL073836, 2017.
%
%% Syntax:
%  calcInflection(data)
%
%% Input:
%  data         - @double, a n x 1 array
%
%% Options:
%  'scott'      - @char, calculate an optimal bin width for the cdf using
%                 Scott's rule
%  'fd'         - @char, calculate an optimal bin width for the cdf using
%                 the Freedman-Diaconis' rule
%  'sqrt'       - @char, calculate an optimal bin width for the cdf using
%                 the square root rule
%  'binWidth'   - @double, specify a bin width for the CDF
%  'min'        - @double, specify minimum of the data array for the PDF
%  'max'        - @double, specify maximum of the data array for the PDF
%%



% Specify whether to show the plot or not
flagSilent = check_option(varargin,'silent');


% Calculate the probability distribution function (PDF)
[binWidth,binCenters,pdf] = calcPDF(inData,varargin{:});

% Calculate the cumulative distribution function (CDF)
cdf = cumsum(pdf * binWidth);

% Calculate a straight the line passing through the first and last points
% of the curve
line = polyfit([binCenters(1) binCenters(end)],[cdf(1) cdf(end)],1);

% Find the distance between each point and the curve
dist = abs((line(1).* binCenters) + (-1.* cdf) + line(2))/...
    sqrt(line(1)^2 + (-1)^2);

% The inflection point is the point furthest from the line
[~,id] = max(dist);

% Define the output
out.x = binCenters;
out.y = cdf;
out.id = id;

if ~flagSilent
    % Plot the cdf and the inflection point
    figure
    plot(binCenters,cdf,'linewidth',3)
    hold all
    scatter(binCenters(id),cdf(id),100,'or','linewidth',2)
    plot([0 binCenters(id)],[cdf(id) cdf(id)],'-k','linewidth',2)
    xlabel('Parameter to segment');
    ylabel('Cumulative frequency');
    hold off
end

end






function [binWidth,binCenters,pdf] = calcPDF(inData,varargin)
%% Function description:
% This function calculates a probability distribution function (PDF). The
% bin widths of the PDF are calculated using either Scott's,
% Freedman-Diaconis', or the square root rules, or by specifying
% a value.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  calcPDF(data)
%
%% Input:
%  data         - @double, a n x 1 array
%
%% Options:
%  'scott'      - @char, calculate an optimal bin width for the cdf using
%                 Scott's rule
%  'fd'         - @char, calculate an optimal bin width for the cdf using
%                 the Freedman-Diaconis' rule
%  'sqrt'       - @char, calculate an optimal bin width for the cdf using
%                 the square root rule
%  'binWidth'   - @double, specify a bin width for the cdf
%  'min'        - @double, specify minimum of the data array
%  'max'        - @double, specify maximum of the data array
%%



% Specify the bin width
binWidth = get_option(varargin,'binWidth',[]);
if isempty(binWidth)
    if check_option(varargin,'scott')
        % Calculate Scott's rule for optimal bin width
        binWidth = 3.5 * std(inData) / numel(inData)^(1/3);

    elseif check_option(varargin,'fd')
        % Calculate the Freedman-Diaconis' rule for optimal bin width
        iqrValue = iqr(inData);
        binWidth = 2 * iqrValue / numel(inData)^(1/3);

    elseif check_option(varargin,'sqrt')
        % Calculate the square root rule for optimal bin width
        binWidth = range(inData) / sqrt(numel(inData));

    else % since nothing is defined, set bin width defaults
        binWidth = 0.01;

    end
end

% Specify the max of the data
minData = get_option(varargin,'min',[]);
% Specify the max of the data
maxData = get_option(varargin,'max',[]);


% Calculate the number of bins
if ~isempty(minData) &&  isempty(maxData)
    numBins = ceil((max(inData) - minData) / binWidth);

elseif isempty(minData) &&  ~isempty(maxData)
    numBins = ceil((maxData - min(inData)) / binWidth);

elseif ~isempty(minData) &&  ~isempty(maxData)
    numBins = ceil((maxData - minData) / binWidth);

elseif isempty(minData) && isempty(maxData)
    numBins = ceil(range(inData) / binWidth);
end


% Bin the data using the specified bin width and number of bins
[counts, binEdges] = histcounts(inData, 'BinWidth', binWidth, 'NumBins', numBins);

% Calculate bin centers
binCenters = binEdges(1:end-1) + binWidth/2;

% Calculate the probability distribution function (PDF)
pdf = counts ./ (sum(counts) * binWidth);

end