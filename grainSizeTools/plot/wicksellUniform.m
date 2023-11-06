function F = wicksellUniform(diameters, dmin, dmax)
%% Function description:
% This function compute the Wicksell's transform of a uniform distribution
% and returns the folded Cumulative Density Function (CDF).
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
% out = wicksellUniform(diameters, freq, edges)
%
%% Input:
% diameters         - @double, a data array of apparent grain diameters
% dmin              - @double, minimum bound of the underlying uniform 
%                     distribution
% dmax              - @double, maximum bound of the underlying uniform 
%                     distribution
%
%% Output:
% F                 - @double, the CDF of the folded distribution
%
%% Options:
% none
%
%%


F = ones(size(diameters));
if dmax <= dmin
    error('Rmax must be greater than Rmin')
end

gamma = dmax * sqrt(dmax^2 - diameters.^2) - diameters.^2 .* log(dmax + sqrt(dmax^2 - diameters.^2));

F(diameters < dmin) = 1 - (gamma(diameters < dmin) +...
    diameters(diameters < dmin).^2 .* log(dmin + sqrt(dmin^2 - diameters(diameters < dmin).^2)) -...
    dmin * sqrt(dmin^2 - diameters(diameters < dmin).^2)) /...
    (dmax^2 - dmin^2);

F(dmin <= diameters & diameters < dmax) = 1 - (gamma(dmin <= diameters & diameters < dmax) +...
    diameters(dmin <= diameters & diameters < dmax).^2 .* log(diameters(dmin <= diameters & diameters < dmax))) /...
    (dmax^2 - dmin^2);
end
