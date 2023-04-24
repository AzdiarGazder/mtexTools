function odfIntensity = calcODFIntensity(odf,varargin)
%% Function description:
% Returns a 3D variable of the ODF intensity (f(g)) in user-defined steps 
% of phi2 using Bunge's notation.
%
%% Author:
% Dr. Ralf Heilscher, 2023
% 
%% Modified by:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
% to function format
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

% get the user defined phi2 steps
phi2Steps = get_option(varargin,'phi2',(0:5:90)*degree);
phi2Sec = phi2Sections(odf.CS,odf.SS,'phi2',phi2Steps);

% make a grid in user specified phi2 steps
S3G = phi2Sec.makeGrid;

% return the ODF intensity at the gridded points
odfIntensity = odf.eval(S3G);

end
