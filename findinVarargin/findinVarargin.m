function varargout = findinVarargin(char2Find,option,varargin)
%% Function description:
% This function finds the location of an element within varargin. The 
% location may be expressed as indices, subscripts, or a logical 
% array.
%
%% Author:
% Dr. Azdiar Gazder, 2024, azdiaratuowdotedudotau
%
%% Syntax:
%  findinVarargin
%
%% Input:
%  char2Find       - the string to search for
%  option          - specifies the type of varargout
%                    'index'     = returns indices
%                    'subscript' = returns subscripts (rows and columns)
%                    'logical'   = returns logical array (1 = match; 
%                                  0 = no match)
%
%% Output:
%  varargout       - @double, indices or subscripts or logical array of 
%                    common elements
%
%% Options:
%
%


switch lower(option)
    case 'index'
    warning('Default: Returning indices');
    flagType = 'index';

    case 'subscript'
    warning('Default: Returning subscripts (rows and columns)');
    flagType = 'subscript';

    case 'logical'
    warning('Default: Returning logical array');
    flagType = 'logical';

    otherwise
    warning('Default: Returning indices');
    flagType = 'index';
end

% Split varargin into a cell array
vArgin = array2Cell(varargin{:});

% Find all 0×0 char arrays (if any)
idx = find(strcmpi(vArgin,{''}));

% Logical array finding the location of the char array within varargin
isPresent = cellfun(@(s) contains(lower(char2Find),s), lower(vArgin));
isPresent(idx) = 0; % re-set all 0×0 char arrays to 0


% Determine varargout based on flagType
switch flagType
    case 'index'
        varargout{1} = find(isPresent); % Return indices
        
    case 'subscript'
        [cols, rows] = find(reshape(isPresent, [], length(varargin)));
        varargout{1} = rows;
        varargout{2} = cols; % Return subscripts (rows and columns)
        
    case 'logical'
        varargout{1} = isPresent; % Return logical array
        
    otherwise
        error('Invalid flagType specified.');
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