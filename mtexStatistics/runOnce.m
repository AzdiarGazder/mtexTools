function runOnce
%% Function description:
% This function permanently and automatically overwrites files in the
% "C:\~\mtex\..." folder as per user modifications.
%
% USER NOTES:
% This function only needs to be run once.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  runOnce
%
%% Input:
%  none
%
%% Output:
%  none
%%

% Find all the files in the 'files2Replace' sub-directory
fileInfo = dir([pwd,'\files2Replace\','*.txt']);

status = false(1,length(fileInfo));
for ii = 1:length(fileInfo)

    % Define the full path and modified file
    pfName = [fileInfo(ii).folder,'\',fileInfo(ii).name];

    % Find the index of all '_' in the file name
    idx = strfind(fileInfo(ii).name,'_');

    % Replace the '_' with '\' in the phrase of interest (which comprises
    % the known part of the MTEX path)
    knownPath = strrep(fileInfo(ii).name(idx(1)+1:idx(3)-1),'_','\');

    % Find the file name while deleting the file extension
    fileName = erase(fileInfo(ii).name(idx(3)+1:end),'.txt');

    % Assume the full path to the MTEX folder on the computer is unknown
    % such that if the path is "C:\~\mtex\...", the "~" signifies the
    % unknown part.
    % Since a part of the path is known (from above):
    pName_MTEX = what(knownPath); % finds the full path of the folder
                                  % containing the file to be replaced
    pfName_MTEX = [pName_MTEX.path,'\',fileName,'.m']; % defines the full
                                                       % path & new file
                                                       % name when copying
                                                       % is undertaken
    % Replace the file in the MTEX distribution
    % The 'f' ensures the file is overwritten in case it exists
    status(ii) = copyfile(pfName, pfName_MTEX,'f');

end

% Check if all files were copied
disp('----');
if all(status) == true
    disp(['File overwrite successful for ',num2str(sum(status)), ' file(s).']);
else
    disp(['File overwrite failed for ',num2str(nnz(~status)), ' file(s).']);
end
disp('----');

end