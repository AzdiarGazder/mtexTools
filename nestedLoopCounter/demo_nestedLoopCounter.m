% Define three nested loops
outLoop = 1:5 % outermost loop
midLoop = 1:3 % middle loop
inLoop = 1:2:7 % innermost loop

% assume the nested loops are running such that [outLoop midLoop inLoop]
% is currently at step [1 3 5]

% the count (or row index) corresponding to [1 3 5] is:
idx = nestedLoopCounter([1 3 5],outLoop,midLoop,inLoop)