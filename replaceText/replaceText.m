function replaceText(inFile,outFile,searchString,replaceString,varargin)
%% Function description:
% This script enables users to edit by replacing or changing the first or 
% all instances of a full line of text in a text-based file. This is 
% especially useful if small changes are needed on-the-fly to function 
% files in publicly released toolboxes (like MTEX).
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements:
% The original function posted in:
% https://au.mathworks.com/matlabcentral/answers/62986-how-to-change-a-specific-line-in-a-text-file
%
%% Syntax:
%  replaceCommand
%
%% Input:
%  inFile        - @char, the full path (inlcuding name) to the input file
%  outFile       - @char, the full path (inlcuding name) to the input file
%  searchString  - @char, the line that needs replacing in the input file
%  replaceString - @char, the replacement line in the input file
%
%% Output:
%  none
%
%% Options:
%  'first'       - @char, replace only the first instance of the string in
%                         the file
%  'all'         - @char, replace all instances of the string in the file
%


if find_option(varargin,'all') 
    methodType = 'all';
else
    methodType = 'first'; % define the default method
end


% Read the file contents as a cell array
fid = fopen(inFile);
fileData = textscan(fid, '%s', 'Delimiter', '\n', 'CollectOutput', true);
fclose(fid);

% Convert the cell to a string array
fileText = string(fileData{:});

% Find the indices where the string array requires modification
idx = [];
for ii = 1:length(fileText) % length(fileData{1})
    % textFlag = strcmp(fileData{1}{ii}, searchString); % flag when the location of the searchString in the cell array is found
    textFlag = strcmp(fileText{ii}, searchString); % flag when the location of the searchString in the cell array is found
    if textFlag == 1
        idx = [idx; ii];
    end
end

if ~isempty(idx) % this avoids any file appending errors
    switch(methodType)
        case('first')
            % fileData{1}{idx(1)} = replaceString; % swap the searchString with the replaceString at the location
            fileText{idx(1)} = replaceString; % swap the searchString with the replaceString at the location

        case('all')
            for ii = 1:length(idx)
                % fileData{1}{idx(ii)} = replaceString; % swap the searchString with the replaceString at the location
                fileText{idx(ii)} = replaceString; % swap the searchString with the replaceString at the location
            end
    end

    % Write the modified cell array into a text file
    fid = fopen(outFile, 'w');
    for ii = 1:length(fileText) % length(fileData{1})
        % fprintf(fid, '%s\n', char(fileData{1}{ii}));
        fprintf(fid, '%s\n', char(fileText{ii}));
    end
    fclose(fid);
end

end