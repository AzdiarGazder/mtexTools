function T = isMultiple(A)
%% Function description:
% This function returns a logical array with a TRUE value if an element
% occurs multiple times anywhere in the array.
%
%% Author:
% Jan Heidelberg, (C) 2021
%
%% License:
% CC BY-SA 3.0, see: creativecommons.org/licenses/by-sa/3.0/
%
%% Reference:
% The function is uploaded at:
% https://au.mathworks.com/matlabcentral/answers/336500-finding-the-indices-of-duplicate-values-in-one-array
%
%% Tested:
% Matlab 2009a, 2015b(32/64), 2016b, 2018b, Win7/10
%
%% Syntax:
% T = isMultiple(A)
%
%% Input:
% A - @double or @char, A numerical or char array of any dimensions
%
%% Input:
% T - @logical, TRUE if an element occurs multiple times anywhere in the
%     array
%
%% Options:
%
%


T        = false(size(A));
[S, idx] = sort(A(:).');
m        = [false, diff(S) == 0];

if any(m)        % Any equal elements found
    m(strfind(m, [false, true])) = true;
    T(idx) = m;   % Re-sort to original order
end
end