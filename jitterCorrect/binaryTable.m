function out = binaryTable(numVariables)
%% Function description:
% Returns a variable containing all logical combinations for a given 
% number of variables.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements(s):
% The first version of this function was posted in:
% https://au.mathworks.com/matlabcentral/answers/1645690-how-to-create-all-combinations-of-boolean-vector-possibilities/?s_tid=ans_lp_feed_leaf
%
%% Syntax:
%  binaryTable(n) 
%
%% Input:
%  n                 - @double defining the number of variables
%
%%

x = 0: (2^numVariables - 1);
out = flipud(dec2bin(x', numVariables) == '0');

end
