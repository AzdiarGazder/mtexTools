function [centers, edges, freq] = Saltykov(diameters, varargin)
%% Function description:
% This function performs the Scheil-Schwartz-Saltykov method (called the 
% Saltykov method for short) to unfold the distribution of apparent grain 
% sizes in 2D sections, giving the distribution of actual (3D) grain size,
% considering grains as spheres.
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
% out = wicksellSolution(D, d1, d2)
%
%% Input:
% diameters         - @double, a data array of apparent grain diameters
% dmin              - @double, the lower limit of the bin/class
% dmax              - @double, the upper limit of the bin/class
%
%% Output:
% centers           - @double, bin centers of the unfolded distribution
% edges             - @double, bin edges of the unfolded distribution
% freq              - @double, frequencies of the unfolded distribution
%
%% Options:
% method            - @char, constrains the minimisation to	the specified 
%                     method ('lower', 'center' or 'upper'). default = 
%                     'upper' limit of each bin is used as the radius 
%                     reference when computing the Wicksell's equation.
% bins              - @double, defines the number of bins for applying the 
%                     Saltykov method; default = 15
%
%% References:
%   Higgins (2000)                          doi:10.2138/am-2000-8-901
%   Lopez-Sanchez and Llana-Funez (2016)	doi:10.21105/joss.00863
%
%% See also:
% wicksellHistogram, wicksellUniform, Saltykov, wicksellSolution
%
%%


nbins = get_option(varargin, 'bins', 15);
method = get_option(varargin, 'method', 'upper');


[counts, centers] = hist(diameters, nbins);
freq = counts / length(diameters);
dr = centers(2) - centers(1);
edges = [(centers(1) - (dr/2)) (centers + (dr/2))];
edges(edges < 0) = 0;

if strcmpi(method, 'lower')
    limits = edges(1: nbins);

elseif strcmpi(method, 'center')
    limits = centers;

elseif strcmpi(method, 'upper')
    limits = edges(2 : (nbins + 1));

else
    error('The ''method'' option can be either ''upper'', ''center'' or lower''.')
end

for ii = 1 : nbins
    % Start from upper classes
    I = nbins + 1 - ii;	
    
    % Use the maximum value in that class
    R_I = edges(I + 1);	
    Pi = wicksellSolution(R_I, edges(I), edges(I + 1));

    for jj = 1: (I - 1)
        Pj = wicksellSolution(limits(I), edges(jj), edges(jj + 1));
        Pnorm = Pj * freq(I) / Pi;
        
        % Avoid negative values
        freq(jj) = max(freq(jj) - Pnorm, 0);
        
        % Normalise the distribution
        freq = freq / sum(freq);          
    end
end

end