function outObj = rename(inObj,varargin)
%% Function description:
% Rename phases using the ebsd or grains variables interactively via a
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





% % Check if all phase names agree with the names in the EBSD data set
% if ~isempty(intersect(outObj.mineralList(2:numel(outObj.mineralList)),phaseStrings)) &&...
%         all(contains(intersect(outObj.mineralList,phaseStrings),phaseStrings))
%     [~,~,ind] = intersect(outObj.mineralList,phaseStrings);
%     ind = sort(ind);
%     fprintf(' -> %s phase(s) automatically identified ''%s''\n',phaseStrings{ind});
%
% else
%     fprintf(' -> Identifying phases to rename\n');
%     try
%         for ii = 2:phaseNum
%             fprintf(['    - ''',phaseNames(ii,:),'''']);
%             [ind,~] = listdlg('PromptString',['Rename phase corresponding to ''',phaseNames(ii,:),''':'],...
%                 'SelectionMode','single','ListString',phaseStrings,...
%                 'ListSize',[300 150]);
%             ebsd.CSList{ii}.mineral = phaseStrings{ind};
%             fprintf([' renamed to ''',phaseStrings{ind},'''\n']);
%         end
%     catch
%         % This command prevents function execution in cases when
%         % the user presses the "Cancel" or "Close" buttons
%         message = sprintf('Program terminated: Execution aborted by user');
%         uiwait(errordlg(message));
%         error('Program terminated: Execution aborted by user');
%     end
% end
% end


% numInput = numel(varargin);
% if numInput == 0 % the interactive GUI option to rename phases
%     fprintf('renameing phases:\n');
%     for ii = 2:numPhases
%         fprintf('    - ''%s''\n',phaseName(ii,:))
%         promptString = ['Define RGB for ''',phaseName(ii,:),''''];
%         try
%             cRGB = uisetcolor([outObj.CSList{ii}.color],promptString); % show the selected color
%             if cRGB == 0 % if the "Cancel" or "Close" buttons are clicked
%                 warning('Keeping previous phase color(s).');
%                 return;
%             else % rename the phase
%                 outObj.CSList{ii}.color = cRGB;
%                 clear cRGB
%             end
%
%         catch
%         end
%     end
%
% elseif numInput == 1 % the cell array option to rename phases
%     if iscell(varargin(1)) % check for input = a cell array
%         colorCellArray = varargin(1);
%         colorCellArray = colorCellArray{1};
%     else
%         error(sprintf('\nColors must be specified as [1 x 3] arrays within a {cell}.'));
%         return;
%     end
%
%     if max(cell2mat(cellfun(@size,colorCellArray,'UniformOutput',false))) ~= 3  % check for the maximum number of color columns within the cell array
%         error(sprintf('\nColors must be specified as an [R G B] = [1 x 3] array.'));
%         return;
%     end
%
%     logicalCellArray = ~cellfun('isempty',colorCellArray);
%     if length(logicalCellArray) ~= (numPhases-1) % check for the length of the cell array
%         error(sprintf('\nNumber of [color arrays] within the {cell} is not equal to the number of phases in the map.'));
%         return;
%     end
%
%     tempRGB = cell2mat(colorCellArray');
%     cRGB = NaN(length(logicalCellArray),3);
%     cRGB(logicalCellArray == 1,:) = tempRGB;
%
%     fprintf('renameing phases:\n');
%     for ii = 2:numPhases % note: the first "phase" comprises unindexed pixels
%         if logicalCellArray(ii-1)
%             fprintf('    - ''%s''\n',phaseName(ii,:))
%             outObj.CSList{ii}.color = cRGB(ii-1,:);
%         end
%     end
%
% elseif numInput > 1 % the phase name or crystal symmetry option to rename phases
%     inputIdx = 1:numInput;
%     oddLogicalIdx = rem(inputIdx,2) ~= 0; %find the odd indices
%     oddIdx = inputIdx(oddLogicalIdx); % indices of the phase name(s)
%     evenIdx = inputIdx(~oddLogicalIdx); % indices of the phase color(s)
%
%     fprintf('renameing phases:\n');
%     for ii = 1:length(oddIdx)
%         if ischar(varargin{oddIdx(ii)}) % check for phase name as char input
%             phaseIdx = find(strcmpi(cellstr(phaseName),varargin{oddIdx(ii)}) == 1);
%             if isempty(phaseIdx) % check for phase name in the list
%                 error(sprintf('\nError in phase name.'));
%                 return;
%             end
%             fprintf('    - ''%s''\n',phaseName(phaseIdx,:));
%             if length(varargin{evenIdx(ii)}) == 3 % check for the maximum number of color columns
%                 outObj.CSList{phaseIdx}.color = varargin{evenIdx(ii)};
%             else
%                 error(sprintf('\nColors must be specified as an [R G B] = [1 x 3] array.'));
%                 return;
%             end
%
%         elseif isa(varargin{oddIdx(ii)},'crystalSymmetry') % check for phase as crystal symmetry input
%             fprintf('    - ''%s''\n',varargin{oddIdx(ii)}.mineral);
%             if length(varargin{evenIdx(ii)}) == 3 % check for the maximum number of color columns
%                 varargin{oddIdx(ii)}.color = varargin{evenIdx(ii)};
%             else
%                 error(sprintf('\nColors must be specified as an [R G B] = [1 x 3] array.'));
%                 return;
%             end
%
%         elseif ~ischar(varargin{oddIdx(ii)}) || ~isa(varargin{oddIdx(ii)},'crystalSymmetry')
%             error(sprintf('\nInput error. Check variable type(s).'));
%             return;
%         end
%
%     end
% end
% end
%
