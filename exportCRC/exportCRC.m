function exportCRC(ebsd,pfName,varargin)
% export EBSD to *.crc and *.cpr files
%
% Description:
% Export variable of type @EBSD to proprietary
% Oxford Instruments HKL Channel 5 *.cpr and *.crc file format.
%
% # In MTEX's "ebsd.load" script, any EDS data contained in the original
% *.crc file is ignored. Therefore, in MTEX, the EDS data belonging to
% an EBSD map needs to be imported and the elemental windows defined
% separately.
% # Even if the EDS data belonging to an EBSD map was previously
% imported and the elemental windows defined, this script ignores it.
% Consequently, this script does not account for any EDS data stored in the
% ebsd variable. If and when MTEX implements the introduction of EBSD and
% EDS data, then a check for value will be introduced to
% |ebsd.opt.cprData.edxwindows.count|. If the value it is not zero, then
% that many number of columns will be should be defined in the |ebsdData|
% variable in the getCPRInfo script and "Process *.crc data" section of
% this script.
%
% Syntax:
%   exportCRC(ebsd,fName)
%
% Input:
%  ebsd  - @EBSD
%  fname - path and file name
%

[filePath,fileName,~] = fileparts(pfName);

% Re-number any strange phase numbers (*.ang file error)
ebsd.phaseMap = (0:(length(ebsd.phaseMap)-1))';

%% Re-define the ebsd variable
% Done to ensure no rounding-off errors in grid values.
% This step is especially necessary when converting from hexagonal to
% square grid types
ebsd = EBSD(ebsd);



%% Process *.cpr data
if isfield(ebsd.opt,'cprInfo')
    % In this case, the input map is of *.cpr & *.crc type
    flagOIFormat = true;
    flagCPRInfo = true;
    % So the structure containing the cpr data pre-exists
    cprStruct = ebsd.opt.cprInfo;

elseif ~isfield(ebsd.opt,'cprInfo') && isfield(ebsd.prop,'bc') && isfield(ebsd.prop,'bs')
    % In this case, the input map is of OI *.ctf or *.txt types
    flagOIFormat = true;
    flagCPRInfo = false;
    % Since the structure containing the cpr data is missing, information
    % for an equivalent CPR file data needs to be generated
    cprStruct = getCPRInformation(ebsd,'flagOIFormat',flagOIFormat,'flagCPRInfo',flagCPRInfo);

else
    % In this case, the input map is from another vendor
    flagOIFormat = false;
    flagCPRInfo = false;
    % Since the structure containing the cpr data is missing, information
    % for an equivalent CPR file data needs to be generated
    cprStruct = getCPRInformation(ebsd,'flagOIFormat',flagOIFormat,'flagCPRInfo',flagCPRInfo);

end
% Find the first level field names of the structure
headerNames = fieldnames(cprStruct);


%% In case of the ANG file format, pre-rotate the ebsd data
if ~flagOIFormat && ~flagCPRInfo
    rot = rotation.byAxisAngle(zvector,90*degree); % counterclockwise
    ebsd = rotate(ebsd,rot,'keepEuler');
    rot = rotation.byAxisAngle(xvector,180*degree);
    ebsd = rotate(ebsd,rot,'keepXY');
end


%% Change reference frame
if check_option(varargin,'convertSpatial2EulerReferenceFrame')
    ebsd = rotate(ebsd,rotation.byAxisAngle(xvector,180*degree),'keepEuler');
elseif check_option(varargin,'convertEuler2SpatialReferenceFrame')
    ebsd = rotate(ebsd,rotation.byAxisAngle(xvector,180*degree),'keepXY');
elseif ~check_option(varargin,'convertSpatial2EulerReferenceFrame') && ~check_option(varargin,'convertEuler2SpatialReferenceFrame')
    warning(['.crc and .cpr files usually have inconsistent conventions for spatial ' ...
        'coordinates and Euler angles. You may want to use one of the options ' ...
        '''convertSpatial2EulerReferenceFrame'' or ''convertEuler2SpatialReferenceFrame'' to correct for this.']);
end


%% Replace NaNs (especially after changing from hexagonal to square grid types)
% After applying the gridify command, grid points in the regular grid that
% do not have a correspondence in the regular grid are set to NaN.
% However, this causes an issue with OI Channel-5 as the software does not
% work with NaNs in the map data.

% METHOD 2: Replace NaNs with zero using the default MTEX method
ebsd.prop.phi1 = ebsd.rotations.phi1;
ebsd.prop.Phi = ebsd.rotations.Phi;
ebsd.prop.phi2 = ebsd.rotations.phi2;

ebsd.prop.phi1(isnan(ebsd.prop.phi1)) = 0;
ebsd.prop.Phi(isnan(ebsd.prop.Phi)) = 0;
ebsd.prop.phi2(isnan(ebsd.prop.phi2)) = 0;

if isfield(ebsd.prop,'fit')
    ebsd.prop.fit(isnan(ebsd.prop.fit)) = 0;
end
if isfield(ebsd.prop,'bc')
    ebsd.prop.bc(isnan(ebsd.prop.bc)) = 0;
end
if isfield(ebsd.prop,'bs')

    ebsd.prop.bs(isnan(ebsd.prop.bs)) = 0;
end
if isfield(ebsd.prop,'iq')
    ebsd.prop.iq(isnan(ebsd.prop.iq)) = 0;
end
if isfield(ebsd.prop,'imagequality')
    ebsd.prop.imagequality(isnan(ebsd.prop.imagequality)) = 0;
end
if isfield(ebsd.prop,'ci')
    ebsd.prop.ci(isnan(ebsd.prop.ci)) = 0;
end
if isfield(ebsd.prop,'confidenceindex')
    ebsd.prop.confidenceindex(isnan(ebsd.prop.confidenceindex)) = 0;
end
%%


%% Process *.crc data
% Column-wise list of fields in a *.crc file
% C1 = phaseIndex;
% C2 = Euler1; C3 = Euler2; C4 = Euler3;
% C5 = MAD; C6 = BC; C7 = BS;
% C8 = Number of bands; C9 = Error;
% C10 = is or is not indexed;
% C11...Cx = edsWindow_1... edsWindow_x
% classType = {'int8' 'single' 'single' 'single' 'single' 'int8' 'int8' 'int8' 'int8' 'single' 'single' ... 'single'};
% byteLength = [1 4 4 4 4 1 1 1 1 4 4 ... 4];


% Transpose row & column data first
% Then flip column data from left-to-right
%% C1 = phaseIndex
grid.phase = fliplr(ebsd.phase.');

%% C2 = Euler1
grid.phi1 = fliplr(ebsd.prop.phi1.');

%% C3 = Euler2
grid.Phi = fliplr(ebsd.prop.Phi.');

%% C4 = Euler3
grid.phi2 = fliplr(ebsd.prop.phi2.');

%% C5 = MAD
if flagOIFormat && isfield(ebsd.prop,'mad')
    grid.mad = fliplr(ebsd.prop.mad.');
elseif isfield(ebsd.prop,'fit')
    grid.mad = fliplr(ebsd.prop.fit.');
else
    grid.mad = zeros(size(fliplr(ebsd.isIndexed.')));
end

%% C6 = BC
if flagOIFormat && isfield(ebsd.prop,'bc')
    grid.bc = fliplr(ebsd.prop.bc.');
elseif isfield(ebsd.prop,'iq')
    iq = round(255 * mat2gray(ebsd.prop.iq));
    grid.bc = fliplr(iq.');
elseif isfield(ebsd.prop,'imagequality')
    imagequality = round(255 * mat2gray(ebsd.prop.imagequality));
    grid.bc = fliplr(imagequality.');
else
    grid.bc = zeros(size(fliplr(ebsd.isIndexed.')));
end

%% C7 = BS
if flagOIFormat && isfield(ebsd.prop,'bs')
    grid.bs = fliplr(ebsd.prop.bs.');
elseif isfield(ebsdGrid.prop,'ci')
    ci = round(255 * mat2gray(ebsd.prop.ci));
    grid.bs = fliplr(ci.');
elseif isfield(ebsd.prop,'confidenceindex')
    confidenceindex = round(255 * mat2gray(ebsd.prop.confidenceindex));
    grid.bs = fliplr(confidenceindex.');
else
    grid.bs = zeros(size(fliplr(ebsd.isIndexed.')));
end

%% C8 = Number of bands
if flagOIFormat && isfield(ebsd.prop,'bands')
    grid.bands = fliplr(ebsd.prop.bands.');
else
    numBands = 6 * ones(size(ebsd.isIndexed)); % assign the OI minimum of 6 bands to indexed points
    numBands(ebsd.isIndexed == 0) = 1; % assign zero bands to zero solution points
    grid.bands = fliplr(numBands.');
end

%% C9 = Error
if flagOIFormat && isfield(ebsd.prop,'error')
    grid.error = fliplr(ebsd.prop.error.');
else
    grid.error = zeros(size(fliplr(ebsd.isIndexed.')));
end

%% C10 = is or is not indexed
% As per OI convention: 0 = indexed, 1 = zero solution
grid.isIndexed = fliplr(double(~ebsd.isIndexed).');



%% Organise map information
% Convert into single columns and as per the required data variable
% formats for writing to the *.crc file
% classType = {'int8' 'single' 'single' 'single' 'single' 'int8' 'int8' 'int8' 'int8' 'single' 'single' ... 'single'};
% byteLength = [1 4 4 4 4 1 1 1 1 4 4 ... 4];
ebsdData{1} = uint8(grid.phase(:));
ebsdData{2} = single(grid.phi1(:));
ebsdData{3} = single(grid.Phi(:));
ebsdData{4} = single(grid.phi2(:));
ebsdData{5} = single(grid.mad(:));
ebsdData{6} = uint8(grid.bc(:));
ebsdData{7} = uint8(grid.bs(:));
ebsdData{8} = uint8(grid.bands(:));
ebsdData{9} = uint8(grid.error(:));
ebsdData{10} = single(grid.isIndexed(:));


%% Find the classes of the column data
for ii = 1:length(ebsdData)
    classType{ii} = class(ebsdData{ii});
end

%% Define the total number of data records to write
data2Write = length(ebsdData{1})*length(classType);

%% Write *.cpr file
disp('Start writing *.cpr file...');
cprName = fullfile(filePath,[fileName '.cpr']);
fid = fopen(cprName,'W');

for ii = 1:length(headerNames)
    % Upper case the first alphabet of first-level field names and convert
    % to a string
    % headerString = [upper(headerNames{ii}(1)), headerNames{ii}(2:end)];
    headerString = strrep(headerNames{ii},'_',' ');
    % Write the first-level field name of the structure as a string
    % into the file
    fwrite(fid,['[',headerString,']']);
    % Write a carriage return for a new line into the file
    fwrite(fid,newline);
    currentProp = cprStruct.(headerNames{ii});

    % Check if the first-level field name is a nested structure
    if isstruct(currentProp)
        % Find the second level field names of the structure
        subheaderNames = fieldnames(currentProp);
        for jj = 1:length(subheaderNames)
            % Upper case the first alphabet of second-level field names
            % and convert to a string
            % subheaderString = [upper(subheaderNames{jj}(1)), subheaderNames{jj}(2:end)];
            subheaderString = strrep(subheaderNames{jj},'_',' ');
            currentProp2 = currentProp.(subheaderNames{jj});

            % Define the second-level field value as a string
            if ischar(currentProp2)
                subheaderValue = currentProp2;
                subheaderValue = strrep(subheaderValue,'_',' ');
            elseif isnumeric(currentProp2)
                subheaderValue = num2str(currentProp2);
            end
            % Write the second-level field name of the structure and its
            % value as strings into the file
            fwrite(fid,[subheaderString,'=',subheaderValue]);
            % Write a carriage return for a new line into the file
            fwrite(fid,newline);
        end
    end
    % Write a carriage return for a new line into the file
    fwrite(fid,newline);

    progress(ii,length(headerNames));
end
% Close the *.cpr file
fclose(fid);
disp('Done!')

%% Write *.crc file
disp('Start writing *.crc file...');
crcName = fullfile(filePath,[fileName '.crc']);
fid = fopen(crcName,'W');

% Write individual data records to the *.crc file
for ii = 1:length(ebsdData{1})
    for jj = 1:length(classType)
        % Write data to file with the appropriate number of bits
        fwrite(fid, ebsdData{jj}(ii), ['*' classType{jj}]);

        % Update progress at intervals
        if mod(jj+((ii-1)*length(classType)),data2Write/20) == 0
            progress(ii,length(ebsdData{1}));
        end
    end
end
% Close the *.crc file
fclose(fid);
disp('Done!')
end
%%



%% MIT License
% Copyright (c) 2020 Azdiar Gazder, Frank Niessen
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.
%%
