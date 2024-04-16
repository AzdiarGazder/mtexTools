function ebsd = loadEDS_csv(ebsd)
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


% Get a list of all *.csv files in the pwd and/or any subfolders
csvFileFormat = fullfile(pwd, '**/* series.csv');
fStruct = dir(csvFileFormat);

for ii = 1:size(fStruct,1)
    
    % Read the csv file(s) without empty rows
    temp = readmatrix([fStruct(ii).folder,'\',fStruct(ii).name]);

    % Delete "...series.csv" from the file name and convert to lowercase
    fName = lower(erase(fStruct(ii).name," series.csv"));
    % Delete all spaces within the file name
    fName = fName(~isspace(fName));
    % Assign the csv file data to the 'ebsd.prop' structure variable using
    % the file name as the fieldname
    ebsd.prop.(fName) = temp(:);
end

end

