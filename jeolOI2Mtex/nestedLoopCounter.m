function rowIdx = nestedLoopCounter(currentLoopIdx,varargin)
%% Function description:
% Returns the current count (or specifically, the row index) for a series 
% of running nested loops. The function currently employs three nested 
% loops but can be reduced to two nested loops or extended to multiple 
% nested loops.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax
%
%  [idx] = nestedLoopCounter(currentLoop,varargin)
%
% Input
%  currentLoop      - @numeric
%
% Output
%  idx              - @numeric
%%

% check if the number of columns of the current loop matches the number of
% varargin
if size(currentLoopIdx,2) ~= length(varargin)
    error('The size of the current loop should match the number of varargin.')
    return;
end

% % check if the varargin are arrays
% for ii = 1:length(varargin)
%     varargScalar = isscalar(varargin{ii});
%     if varargScalar == 1
%         error(['Varargin ', num2str(ii),' should be a 1 x c array.'])
%         return;
%     end
% end

% define the indices of the nested loop
[outerLoop,middleLoop,innerLoop] = ndgrid(varargin{1},varargin{2},varargin{3});
loopIdx = [outerLoop(:),middleLoop(:),innerLoop(:)];
loopIdx = sortrows(loopIdx,[1 2 3]);

% find the row index of the current loop within the nested loop indices
% tic;
rowIdx = find(ismember(loopIdx,currentLoopIdx,'rows')==1);
% idx = find(any(all(bsxfun(@eq,loopCombos,permute(currentLoop,[3 2 1])),2),3) == 1)
% toc
end
