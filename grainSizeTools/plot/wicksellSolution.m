function result = wicksellSolution(D, d1, d2)
%% Function description:
% This function estimates the cross-section size probability for a 
% discretised population of spheres based on the Wicksell (1925) and later 
% on, by Scheil (1931), Schwartz (1934) and Saltykov (1967).
% This is:
% P(r1 < r < r2) = 1/R * (sqrt(R^2 - r1^2) - sqrt(R^2 - r2^2))
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
% D                 - @double, a data array of apparent grain diameters
%                     signifying the midpoint of the actual class
% dmin              - @double, the lower limit of the bin/class
% dmax              - @double, the upper limit of the bin/class
%
%% Output:
% result            - @double, the cross-section probability for a 
%                     specific range of grain sizes
%
%% Options:
% none
%
%% References:
% Saltykov (1967)  doi:10.1007/978-3-642-88260-9_31
% Scheil   (1931)  doi:10.1002/zaac.19312010123
% Schwartz (1934)  Met. Alloy 5:139
% Wicksell (1925)  doi:10.2307/2332027
% Higgins  (2000)  doi:10.2138/am-2000-8-901
%
%%


% convert diameters to radii
R = D / 2;
r1 = d1 / 2;
r2 = d2 / 2;

result = (1 / R) * (sqrt(R^2 - r1^2) - sqrt(R^2 - r2^2));
% result = (1 / D) * (sqrt(D^2 - d1^2) - sqrt(D^2 - d2^2));

end
