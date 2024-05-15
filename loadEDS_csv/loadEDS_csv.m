function ebsd = loadEDS_csv(ebsd,varargin)
%% Function description:
% Automatically loads all energy dispersive x-ray spectroscopy (EDS)
% elemental data (counts per pixel) stored within individual *.csv files
% when combined EBSD+EDS mapping is undertaken.
% The *.csv files may comprise user defined TruMap or QuantMap data
% exported from the Oxford Instruments Aztec software suite.
% The elemental values are returned within the 'ebsd.prop' structure
% variable.
%
%% Author:
% Dr. Azdiar Gazder, 2024, azdiaratuowdotedudotau
%
%% Syntax:
%  [ebsd] = loadEDS_csv(ebsd)
%
%% Input:
%  ebsd       - @EBSD
%
%% Output:
%  ebsd       - @EBSD
%
%% Options:
%
%%

toDelete = get_option(varargin,'delete','');

% Get a list of all *.csv files in the pwd and/or any subfolders
% csvFileFormat = fullfile(pwd, '**/* series.csv');
csvFileFormat = fullfile(pwd, '**/*.csv');
fStruct = dir(csvFileFormat);

for ii = 1:size(fStruct,1)

    % Read the csv file(s) without empty rows
    temp = readmatrix([fStruct(ii).folder,'\',fStruct(ii).name]);

    % Delete "...series.csv" (default) from the file name and convert to
    % lowercase

    if isempty(toDelete) && contains(fStruct(ii).name,' series.csv')
        fName = lower(erase(fStruct(ii).name,' series.csv'));
    elseif isempty(toDelete) && contains(fStruct(ii).name,' Wt%.csv')
        fName = lower(erase(fStruct(ii).name,' Wt%.csv'));
    else
        fName = lower(erase(fStruct(ii).name,toDelete));
    end
    % Delete all spaces within the file name
    fName = fName(~isspace(fName));
    % Assign the csv file data to the 'ebsd.prop' structure variable using
    % the file name as the fieldname
    ebsd.prop.(fName) = temp(:);
end

end

