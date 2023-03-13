function outObj = rename(inObj,varargin)
%% Function description:
% Rename phases using the ebsd or grains variables interactively via a
% GUI or via scripting.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Modified by:
% Dr. Frank Niessen to include renaming of ebsd or grains variables.
%
%% Version(s):
% The first version of this function was posted in:
% https://github.com/ORTools4MTEX/ORTools/blob/develop/src/renamePhases.m
%
%% Syntax:
%  ebsd   = rename(ebsd,varargin)
%  grains = rename(grains,varargin)
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
% {'newName1','newName2',...} - @cell containing @char arrays of the phase
%                               name(s). The number of @char arrays in the 
%                               cell must match the number of phases in a 
%                               map. Use an empty char array to leave phase
%                               names as-is.
%  'oldName','newName'        - @char of the old phase name and a @char
%                               array of the new phase name.
%  ebsd.CSList{},'newName'    - @crystalSymmetry for the phase and
%                               a @char of the new phase name.
%  CS{},'newName'             - @crystalSymmetry for the phase and a @char
%                               of the new phase name.
%%

outObj = inObj;
if ~isa(outObj,'EBSD') && ~isa(outObj,'grain2d') % check for variable type
    error(sprintf('\nOnly @ebsd or @grains accepted.'));
    return;
end
numPhases = length(outObj.CSList);
phaseName = char(outObj.mineralList(1:numel(outObj.mineralList)));


numInput = numel(varargin);
if numInput == 0 % the interactive GUI option to rename phases
    fprintf('Renaming phases:\n');
    for ii = 2:numPhases
        fprintf('    - ''%s''\n',phaseName(ii,:))
        promptString = {['\bf\fontsize{14} Rename the phase ''',deblank(phaseName(ii,:)),''' to:']};
        guiTitle = ['Rename phase(s)'];
        defInput = {deblank(phaseName(ii,:))};
        guiDims = [1 70];
        guiOptions.Resize = 'on';
        guiOptions.WindowStyle = 'normal';
        guiOptions.Interpreter = 'tex';
        try
            newPhaseName = cell2mat(inputdlg(promptString,guiTitle,guiDims,defInput,guiOptions));
            if isempty(newPhaseName) || strcmpi(deblank(phaseName(ii,:)),deblank(newPhaseName)) % if the "Ok" or "Cancel" buttons are clicked
                warning('Keeping original phase name.');
            else % rename the phase
                outObj.CSList{ii}.mineral = newPhaseName;
                clear newPhaseName
            end

        catch
            return;
        end
    end

elseif numInput == 1 % the cell array option to rename phases
    if iscell(varargin(1)) % check for input = a cell array
        phaseNamesCellArray = varargin(1);
        phaseNamesCellArray = phaseNamesCellArray{1};
    else
        error(sprintf('\Phase names must be specified as ''char'' arrays within a {cell}.'));
        return;
    end

    if iscellstr(phaseNamesCellArray) == 0  % check for char strings within the cell array
        error(sprintf('\nPhase names must be specified as ''char'' arrays within a {cell}.'));
        return;
    end

    logicalCellArray = ~cellfun('isempty',phaseNamesCellArray)';
    if length(logicalCellArray) ~= (numPhases-1) % check for the length of the cell array
        error(sprintf('\nNumber of ''char arrays'' within the {cell} is not equal to the number of phases in the map.'));
        return;
    end

    phaseNamesCellArray = pad(phaseNamesCellArray,' ');
    newPhaseNames = cell2mat(phaseNamesCellArray');
    fprintf('Renaming phases:\n');
    for ii = 2:numPhases % note: the first "phase" comprises unindexed pixels
        if logicalCellArray(ii-1) && ~isequal(newPhaseNames(ii-1,:),blanks(size(newPhaseNames,2)))
            fprintf('    - ''%s''\n',phaseName(ii,:))
            outObj.CSList{ii}.mineral = newPhaseNames(ii-1,:);
        end
    end

elseif numInput > 1 % the phase name or crystal symmetry option to rename phases
    inputIdx = 1:numInput;
    oddLogicalIdx = rem(inputIdx,2) ~= 0; %find the odd indices
    oddIdx = inputIdx(oddLogicalIdx); % indices of the phase name(s)
    evenIdx = inputIdx(~oddLogicalIdx); % indices of the phase color(s)

    fprintf('Renaming phases:\n');
    for ii = 1:length(oddIdx)
        if ischar(varargin{oddIdx(ii)}) % check for phase name as char input
            phaseIdx = find(strcmpi(cellstr(phaseName),varargin{oddIdx(ii)}) == 1);
            if isempty(phaseIdx) % check for phase name in the list
                error(sprintf('\nError in phase name.'));
                return;
            end
            fprintf('    - ''%s''\n',phaseName(phaseIdx,:));
            if ischar(varargin{evenIdx(ii)}) == 1 % check for a char array
                outObj.CSList{phaseIdx}.mineral = varargin{evenIdx(ii)};
            else
                error(sprintf('\nPhase names must be specified as ''char'' arrays within a {cell}.'));
                return;
            end

        elseif isa(varargin{oddIdx(ii)},'crystalSymmetry') % check for phase as crystal symmetry input
            fprintf('    - ''%s''\n',varargin{oddIdx(ii)}.mineral);
            if ischar(varargin{evenIdx(ii)}) == 1 % check for a char array
                varargin{oddIdx(ii)}.mineral = varargin{evenIdx(ii)};
            else
                error(sprintf('\nPhase names must be specified as ''char'' arrays within a {cell}.'));
                return;
            end

        elseif ~ischar(varargin{oddIdx(ii)}) || ~isa(varargin{oddIdx(ii)},'crystalSymmetry')
            error(sprintf('\nInput error. Check variable type(s).'));
            return;
        end

    end

end
end
