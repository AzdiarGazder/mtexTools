function odf = calcODFIntensity(odf,varargin)
%% Function description:
% Returns the ODF intensity (f(g)) in user-defined steps of phi2 using 
% Bunge's notation to the variable 'odf.opt.intensity'.
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

% get the user specified steps for the phi2 sections
phi2Steps = get_option(varargin,'phi2',(0:5:90)*degree);

% define the phi2 sections
phi2Sec = phi2Sections(odf.CS,odf.SS,'phi2',phi2Steps);

% make a grid using the user specified phi2 steps
S3G = phi2Sec.makeGrid;

% return the ODF intensity at the gridded points
odf.opt.intensity = odf.eval(S3G);

% make negative f(g) values == 0
odf.opt.intensity(odf.opt.intensity<0) = 0;

% check if the user has not specified an output variable
if nargout == 0
    assignin('base','odf',odf);
end
end
