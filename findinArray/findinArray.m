function varargout = findinArray(in1,in2,varargin)
%% Function description:
% This function finds the location of elements in array1 within array2 
% irrespective of data type. The location of common elements may be 
% expressed as indices, subscripts, or a logical array.
%
%% Author:
% Dr. Azdiar Gazder, 2024, azdiaratuowdotedudotau
%
%% Acknowledgements:
% The original function posted in:
% https://www.mathworks.com/matlabcentral/answers/87731-find-elements-of-an-array-in-another-array
%
%% Syntax:
%  findinArray
%
%% Input:
%  array1          - the array of elements to search for
%  array2          - the array of elements within which the search is 
%                    performed
%
%% Output:
%  varargout       - @double, indices or subscripts or logical array of 
%                    common elements
%
%% Options:
%  'index'         - returns indices
%  'subscript'     - returns subscripts (rows and columns)
%  'logical'       - returns logical array (1 = match; 0 = no match)
%


if check_option(varargin,{'index'})
    warning('Default: Returning indices');
    flagType = 'index';

elseif check_option(varargin,{'subscript'})
    warning('Default: Returning subscripts (rows and columns)');
    flagType = 'subscript';

elseif check_option(varargin, {'logical'})
    warning('Default: Returning logical array');
    flagType = 'logical';

else
    warning('Default: Returning indices');
    flagType = 'index';
end


% Convert arrays to cells with string elements for comparison
array1 = array2Cell(in1);
array2 = array2Cell(in2);

% Find common elements
C = intersect(array1,array2);

% Find indices of common elements in array2
idx = find(ismember(array2,C));


if isequal(flagType, 'subscript')
    [row,col] = ind2sub(size(array2),idx);
    temp = sortrows([row(:),col(:)],1);
    varargout{1} = temp(:,1);
    varargout{2} = temp(:,2);

elseif isequal(flagType, 'logical')
    logicalArray = ismember(1:numel(array2), idx);
    varargout{1} = reshape(logicalArray, size(array2));

elseif isequal(flagType, 'index')
    varargout{1} = idx;
end

end



function out = array2Cell(in)
% Convert different array types into a cell containing string elements

if isdatetime(in)
    out = cellstr(datestr(in, 'dd-mmm-yyyy HH:MM:SS'));

elseif iscategorical(in)
    out = cellstr(in);

elseif issparse(in)
    [row, col, val] = find(in);
    out = cell(size(in));
    for ii = 1:size(out, 1)
        for jj = 1:size(out, 2)
            idx = find(row == ii & col == jj, 1);  % Find the index of the current element
            if isempty(idx)
                out{ii, jj} = '';  % Set empty string for zero elements
            else
                out{ii, jj} = num2str(val(idx));  % Convert non-zero elements to string
            end
        end
    end

elseif istable(in)
    % Convert table variables to cell array of strings
    out = cell(size(in));
    for ii = 1:numel(in.Properties.VariableNames)
        if isstring(in.(in.Properties.VariableNames{ii})) || ischar(in.(in.Properties.VariableNames{ii}))
            out(:,ii) = cellstr(in.(in.Properties.VariableNames{ii}));
        elseif iscell(in.(in.Properties.VariableNames{ii}))
            out(:,ii) = in.(in.Properties.VariableNames{ii});
        elseif isnumeric(in.(in.Properties.VariableNames{ii})) || islogical(in.(in.Properties.VariableNames{ii}))
            out(:,ii) = arrayfun(@num2str, in.(in.Properties.VariableNames{ii}), 'UniformOutput', false);
        else
            out(:,ii) = {''}; % Handle unsupported types as empty string
        end
    end


elseif iscell(in)
    % Convert all elements to string arrays (takes care of all non-char
    % data types)
    strArray = cellfun(@string, in, 'UniformOutput', false);
    % Convert string elements to char arrays
    out = cellfun(@char, strArray, 'UniformOutput', false);


elseif isstruct(in)
    % Convert struct fields to cell array of strings
    fieldNames = fieldnames(in);
    out = cell(numel(in), numel(fieldNames));
    for ii = 1:numel(in)
        for jj = 1:numel(fieldNames)
            fieldValue = in(ii).(fieldNames{jj});
            if isstring(fieldValue) || ischar(fieldValue)
                out{ii,jj} = fieldValue;
            elseif isnumeric(fieldValue) || islogical(fieldValue)
                out{ii,jj} = num2str(fieldValue);
            else
                out{ii,jj} = ''; % Handle unsupported types as empty string
            end
        end
    end

elseif isstring(in)
    out = cellfun(@(x) {x}, in);

elseif ischar(in)
    if size(in,1) >= size(in,2)
        out = num2cell(in,2);
    elseif size(in,2) > size(in,1)
        out = cellstr(in);
    end

elseif isnumeric(in) || islogical(in)
    out = arrayfun(@num2str, in, 'UniformOutput', false);

else
    out = {}; % Handle unsupported types as empty cell array
end

end