function out = autoSaltykov(diameters, varargin)
%% Function description:
% This function finds the best parameters for performing the Saltykov
% method by minimising the Cramer-von Mises (CvM) goodness-of-fit
% criterion. It graphically approximates the shape of the actual (3D)
% distribution of grain size from a population of apparent diameters
% measured in a thin section.
%
%% USER NOTES:
% The function only works correctly for unimodal lognormal-like grain size
% populations.
%
%% Modified by:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Authors:
% Dr Dorian Depriester
% Dr Régis Kubler
% Resolution of the Wicksell's equation by Minimum Distance Estimation,
% vol. 38, issue 3, pp. 213–226, 2019, doi:10.5566/ias.2133
%
%% Syntax:
% out = autoSaltykov(R)
% Performs the Saltykov method on:
% - a sample R;
% - using different numbers of bins (ranging from 10 to 25); and
% - using different methods (namely 'all', 'lower', 'center' and 'upper')
%
%% Input:
% diameters         - @double, a data array of apparent grain diameters
%
%% Output:
% out.method        - @char, optimal method...
% out.bins          - @double, optimal number of bins...
% out.centers       - @double, optimal bin centers...
% out.edges         - @double, optimal bin edges...
% out.freq          - @double, frequencies...
% outputs.CvM       - @double, ... of the best candidate with respect to
%                     the CvM criterion.
%
%% Options:
% method            - @char, constrains the minimisation to	the specified
%                     method ('lower', 'center' or 'upper'). default =
%                     'all', where all aforementioned methods are tested
% range             - @double, defines the range so that the investigated
%                     values for the number of bins are comprised between
%	                  min(RANGE) and max(RANGE). default = [10, 25]
% points            - @double, defines the number of points for numerical
%                     integration for the CvM test; default = 1000
%
%% See also:
% wicksellHistogram, wicksellUniform, Saltykov, wicksellSolution
%
%%


methods = get_option(varargin, 'methods', 'all');
if strcmpi(methods,'all')
    methods = {'lower', 'center', 'upper'};
elseif ~strcmpi(method, 'lower') || ~strcmpi(method, 'center') || ~strcmpi(method, 'upper')
    error('The ''method'' options are: ''all'', ''upper'', ''center'' or lower''.')
end

range = get_option(varargin, 'range', [10 25]);
nbins = min(range):max(range);
npts = get_option(varargin, 'points', 1000);
n = length(diameters);


% Interpolation points for numerical integration
diametersInt = linspace(min(diameters),max(diameters),npts);

% Empirical CDF
Fn = zeros(1,npts);
for jj = 1:npts
    Fn(jj) = nnz(diameters <= diametersInt(jj)) / n;
end


min_w2 = inf;
for ii = 1:length(methods)
    for jj = 1:length(nbins)
        % Perform the Saltykov method
        [tempCenters, tempEdges, tempFreq] = Saltykov(diameters, nbins(jj), 'method', methods{ii});

        %	Refold the distribution
        F = wicksellHistogram(diametersInt, tempEdges, tempFreq);

        % Cramer - von Mises criterion
        w2 = n * trapz(F, (Fn-F).^2);
        if w2 < min_w2
            min_w2 = w2;
            min_method = methods{ii};
            min_nbins = nbins(jj);
            freq = tempFreq;
            centers = tempCenters;
            edges = tempEdges;
        end

    end
end

[appCounts, appCenters] = hist(diameters, min_nbins);
appFreq = appCounts ./ n;
appFreq = appFreq ./ sum(appFreq);
out.appCounts = appCounts;
out.appCenters = appCenters;
out.appFreq = appFreq;


out.method = min_method;
out.bins = min_nbins;
out.centers = centers;
out.edges = edges;
out.freq = freq;
out.CvM = min_w2;

end
