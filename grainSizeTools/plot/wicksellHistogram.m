function F = wicksellHistogram(diameters, edges, freq)
%% Function description:
% This function computes the Wicksell's transform of a finite histogram
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
% out = wicksellHistogram(diameters, freq, edges)
%
%% Input:
% diameters         - @double, a data array of apparent grain diameters
% freq              - @double, a data array of frequencies of the
%                     underlying distribution
% edges             - @double, a data array of bin edges of the
%                     underlying distribution
%
%% Output:
% F                 - @double, the CDF of the folded distribution
%
%% Options:
% none
%
%%

freq = freq(:)';
if length(freq) ~= length(edges) - 1
    error('The size of the freq must be (N - 1) with length(edges) = N')
end

N = length(freq);
centers = (edges(2 : (N + 1)) + edges(1 : N)) / 2;
nInt = length(diameters);

Fk = zeros(nInt, N);
for ii = 1:N
    Fk(:,ii) = wicksellUniform(diameters, edges(ii), edges(ii+1)) * centers(ii) * freq(ii);
end

E = sum(centers .* freq);
F = sum(Fk, 2)' / E;

end