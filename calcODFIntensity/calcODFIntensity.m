function odf = calcODFIntensity(odf,varargin)
%% Function description:
% Returns the ODF intensity (f(g)) in user-defined steps using Bunge's 
% notation to the variable 'odf.opt.intensity'.
%
%% Author:
% Dr. Ralf Heilscher, 2023
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
% 
%% Syntax:
%  calcODFIntensity(odf)
%
%% Input:
%  odf          - @SO3FunRBF or @SO3FunHarmonic
%
%% Options:
%  phi2         - phi2 section steps for the ODF intensity calculation
%%

% check for input variable type
if ~isa(odf,'SO3FunRBF') && ~isa(odf,'SO3FunHarmonic')
    error('Input odf must be @SO3FunRBF or @SO3FunHarmonic variables.');
    return;
end

% get the user specified steps for the phi1, Phi, & phi2 sections
res = get_option(varargin,'resolution',5*degree);

% define the grid
% MTEX BUG: not returning the correct SO3G size
% SO3G = regularSO3Grid(odf.CS,odf.SS,'resolution',res);

% define odf extents
[maxRho,maxTheta,maxSec] = fundamentalRegionEuler(odf.SRight,odf.SLeft);
% define the dimensions of the odf grid
x = linspace(0,maxTheta,round(maxTheta/res)+1);
y = linspace(0,maxRho,round(maxRho/res)+1);
z = linspace(0,maxSec,round(maxSec/res)+1);
% create a meshgrid
[phi1,Phi,phi2] = meshgrid(x, y, z);
SO3G = orientation.byEuler(phi1,Phi,phi2,odf.CS,odf.SS);

% return the ODF intensity at the gridded points
odf.opt.intensity = odf.eval(SO3G);

% make negative f(g) values == 0
odf.opt.intensity(odf.opt.intensity<0) = 0;

% check if the user has not specified an output variable
if nargout == 0
    assignin('base','odf',odf);
end
end
