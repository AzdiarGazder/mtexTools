function v = calcODFVolumeFraction(odf)
%% Function description:
% Returns the volume fraction of a discrete ODF using Bunge's notation.
%
%% Author:
% Dr. Azdiar Gazder, 2024, azdiaratuowdotedudotau
% 
%% Reference:
% Quantitative Texture Analysis, edited by HJ Bunge and C Esling (1982)
%
%% Further reading:
% http://pajarito.materials.cmu.edu/lectures/Volume_Fractions-30Jan20.pdf
%
%% Syntax:
%  calcODFVolumeFraction(odf)
%
%% Input:
%  odf          - @SO3FunRBF or @SO3FunHarmonic
%
%% Options:
%
%%


% Initialise variables
fg = odf.opt.intensity;

% Define odf extents
[maxRho,maxTheta,maxSec] = fundamentalRegionEuler(odf.SRight,odf.SLeft);

% Define the dimensions of the odf grid
x = linspace(0,maxTheta,size(fg,2));
y = linspace(0,maxRho,size(fg,1));
z = linspace(0,maxSec,size(fg,3));

% Create a meshgrid
[phi1, Phi, phi2] = meshgrid(x, y, z);
dphi1 = max(diff(phi1(:)),[],'all');
dPhi = max(diff(Phi(:)),[],'all');
dphi2 = max(diff(phi2(:)),[],'all');


% Initialise the grid of multiplier fractions with 1
multFrac = ones(size(phi1));

% Update the corner values of the grid of multiplier fractions with 1/8
multFrac([1 end], [1 end], [1 end]) = 1/8;

% Update the edge values of the grid of multiplier fractions with 1/4
multFrac([1 end], [1 end], 2:end-1) = 1/4;
multFrac([1 end], 2:end-1, [1 end]) = 1/4;
multFrac(2:end-1, [1 end], [1 end]) = 1/4;

% Update the end faces of the grid of multiplier fractions with 1/2
multFrac([1 end], 2:end-1, 2:end-1) = 1/2;
multFrac(2:end-1, [1 end], 2:end-1) = 1/2;
multFrac(2:end-1, 2:end-1, [1 end]) = 1/2;

% CHECK
% scatter3(phi1(:),Phi(:),phi2(:),50,multFrac(:),'filled');

% Calculate the ODF volume fraction
v = 1/((pi()^2)) .* multFrac .* odf.opt.intensity .* (cos(Phi -(dPhi/2)) - cos(Phi + (dPhi/2))) .* sin(Phi) .* (dphi1 * dphi2);

% Normalise the volume fraction
v = v ./ sum(v(:));

end