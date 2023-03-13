function outObj = recolor(inObj,varargin)
%% Function description:
% Recolor phases using the ebsd or grains variables interactively via a 
% GUI or via scripting.
%
%% Note to users:
% If old style color seleUI is needed, type the following in the command
% window and re-start Matlab:
% setpref('Mathworks_uisetcolor', 'Version', 1);
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Modified by:
% Dr. Frank Niessen to include recoloring of ebsd or grains variables.
%
%% Version(s):
% The first version of this function was originally posted in:
% https://github.com/ORTools4MTEX/ORTools/blob/develop/src/recolorPhases.m
%
%% Syntax:
%  ebsd   = recolorPhases(ebsd,varargin)
%  grains = recolorPhases(grains,varargin)
%
%% Input:
%  ebsd             - @EBSD
%  grains           - @grains
%
%% Output:
%  ebsd             - @EBSD
%  grains           - @grains
%
%% Options:
% {[R G B],[],[R G B]....}   -  @cell containing 1 x 3 double arrays 
%                               for the phase color(s). The number of
%                               double arrays in the cell must match the 
%                               number of phases in a map. Use an empty 
%                               array to leave phase colors as-is.
%  'phaseName',[R G B]       -  @char for the phase name and a 1 x 3 double
%                               array for the phase color.
%  ebsd.CSList{},[R G B]     -  @crystalSymmetry for the phase and 
%                               a 1 x 3 double array for the phase color.
%  CS{},[R G B]              -  @crystalSymmetry for the phase and
%                               a 1 x 3 double array for the phase color.
%%

outObj = inObj;
if ~isa(outObj,'EBSD') && ~isa(outObj,'grain2d') % check for variable type
    error(sprintf('\nOnly @ebsd or @grains accepted.'));
    return;
end
numPhases = length(outObj.CSList);
phaseName = char(outObj.mineralList(1:numel(outObj.mineralList)));


numInput = numel(varargin);
if numInput == 0 % the interactive GUI option to recolor phases
    fprintf('Recoloring phases:\n');
    for ii = 2:numPhases
        fprintf('    - ''%s''\n',phaseName(ii,:))
        promptString = ['Define RGB for ''',phaseName(ii,:),''''];
        try
            cRGB = uisetcolor([outObj.CSList{ii}.color],promptString); % show the selected color
            if cRGB == 0 % if the "Cancel" or "Close" buttons are clicked
                warning('Keeping previous phase color(s).');
                return;
            else % recolor the phase
                outObj.CSList{ii}.color = cRGB;
                clear cRGB
            end

        catch
        end
    end

elseif numInput == 1 % the cell array option to recolor phases
    if iscell(varargin(1)) % check for input = a cell array
        colorCellArray = varargin(1);
        colorCellArray = colorCellArray{1};
    else
        error(sprintf('\nColors must be specified as [1 x 3] arrays within a {cell}.'));
        return;
    end

    if max(cell2mat(cellfun(@size,colorCellArray,'UniformOutput',false))) ~= 3  % check for the maximum number of color columns within the cell array
        error(sprintf('\nColors must be specified as an [R G B] = [1 x 3] array.'));
        return;
    end

    logicalCellArray = ~cellfun('isempty',colorCellArray);
    if length(logicalCellArray) ~= (numPhases-1) % check for the length of the cell array
        error(sprintf('\nNumber of [color arrays] within the {cell} is not equal to the number of phases in the map.'));
        return;
    end

    tempRGB = cell2mat(colorCellArray');
    cRGB = NaN(length(logicalCellArray),3);
    cRGB(logicalCellArray == 1,:) = tempRGB;

    fprintf('Recoloring phases:\n');
    for ii = 2:numPhases % note: the first "phase" comprises unindexed pixels
        if logicalCellArray(ii-1)
            fprintf('    - ''%s''\n',phaseName(ii,:))
            outObj.CSList{ii}.color = cRGB(ii-1,:);
        end
    end

elseif numInput > 1 % the phase name or crystal symmetry option to recolor phases
    inputIdx = 1:numInput;
    oddLogicalIdx = rem(inputIdx,2) ~= 0; %find the odd indices
    oddIdx = inputIdx(oddLogicalIdx); % indices of the phase name(s)
    evenIdx = inputIdx(~oddLogicalIdx); % indices of the phase color(s)
    
    fprintf('Recoloring phases:\n');
    for ii = 1:length(oddIdx)
        if ischar(varargin{oddIdx(ii)}) % check for phase name as char input
            phaseIdx = find(strcmpi(cellstr(phaseName),varargin{oddIdx(ii)}) == 1);
            if isempty(phaseIdx) % check for phase name in the list
                error(sprintf('\nError in phase name.'));
                return;
            end
            fprintf('    - ''%s''\n',phaseName(phaseIdx,:));
            if length(varargin{evenIdx(ii)}) == 3 % check for the maximum number of color columns
                outObj.CSList{phaseIdx}.color = varargin{evenIdx(ii)};
            else
                error(sprintf('\nColors must be specified as an [R G B] = [1 x 3] array.'));
                return;
            end

        elseif isa(varargin{oddIdx(ii)},'crystalSymmetry') % check for phase as crystal symmetry input
            fprintf('    - ''%s''\n',varargin{oddIdx(ii)}.mineral);
            if length(varargin{evenIdx(ii)}) == 3 % check for the maximum number of color columns
                varargin{oddIdx(ii)}.color = varargin{evenIdx(ii)};
            else
                error(sprintf('\nColors must be specified as an [R G B] = [1 x 3] array.'));
                return;
            end

        elseif ~ischar(varargin{oddIdx(ii)}) || ~isa(varargin{oddIdx(ii)},'crystalSymmetry')
            error(sprintf('\nInput error. Check variable type(s).'));
            return;
        end

    end
end
end

