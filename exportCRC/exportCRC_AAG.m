function exportCRC(ebsd,pfName)
%% Function description:
% Exports input EBSD map orientation data in any vendor format to
% proprietary Oxford Instruments HKL Channel 5 *.cpr and *.crc output file
% format.
%
%% Modified by:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements:
% For the original script posted by Dr Mark Pearce
% CSIRO Mineral Resources, Australia
%
%% Version(s):
% This is a modification of MTEX's built-in "export_crc" version 1.0
% function published on 08 AUG 2020 by:
% Dr Azdiar Gazder azdiaratuowdotedudotau, and
% Dr Frank Niessen, contactatfniessendotcom
% and located at:
% ~\mtex\EBSDAnalysis\@EBSD
%
%% Syntax:
% exportCRC(ebsd,pfName)
%
%% Input:
% ebsd   - @EBSD
% pfname - @char, a string containing the full path and file name of the
%                 *.cpr and *.crc files.
%
%% Other notes:
% (1) In case of maps with hexagonal grids, prior conversion to a square
%     grids is required before invoking this function.
%     For a detailed demonstration, please refer to:
%     https://github.com/AzdiarGazder/mtexTools/tree/main/hex2Square
%
% (2) In MTEX's "ebsd.load" script, any EDS data contained in the original
%     *.crc file is ignored. Therefore, in MTEX, the EDS data belonging to
%     an EBSD map needs to be imported and the elemental windows defined
%     separately.

% (3) Even if the EDS data belonging to an EBSD map was previously
%     imported and the elemental windows defined, this script ignores it.
%     Consequently, this script does not account for any EDS data stored
%     in the ebsd variable.
%     If and when MTEX implements the introduction of EBSD and EDS data,
%     then a check for value will be introduced to
%     "ebsd.opt.cprData.edxwindows.count".
%     If the value it is not zero, then that many number of columns will
%     be should be defined in the "ebsdData" variable in the getCPRInfo
%     script and "Process *.crc data" section of this script.
%
%%

screenPrint('SegmentStart','Export ebsd data to *.cpr/crc files');

%% Process the input data
tic
screenPrint('Step','Process ebsd data before writing to files');
%% Define the file path, name and extension
[filePath,fileName,~] = fileparts(pfName);
%%


%% Re-number any strange phase numbers (*.ang file error)
ebsd.phaseMap = [0:(length(ebsd.phaseMap)-1)]';
%%

%% Re-grid the ebsd grid
% Done to ensure no rounding-off errors in grid values.
% This step is especially necessary when converting from hexagonal to
% square grid types
ebsd = EBSD(ebsd);
% stepSize = calcStepSize(ebsd);
% ebsd = regrid(ebsd,stepSize);
%%


%% Process *.cpr data
% Define a structure containing the cpr data
if isfield(ebsd.opt,'cprInfo')
    cprStruct = ebsd.opt.cprInfo;
    flagOIFormat = true;
    flagcprStruct = true;

elseif ~isfield(ebsd.opt,'cprInfo') && isfield(ebsd.prop,'bc') && isfield(ebsd.prop,'bs')
    % When the map is originally an OI file format but is missing data,
    % then equivalent CPR file data needs to be generated.
    cprStruct = getCPRInfo(ebsd);
    flagOIFormat = true;
    flagcprStruct = false;
disp('FUCK1')
else
    % When the map is not originally an OI file format
    % (i.e. - *.cpr, *.crc, *.ctf, or *.txt), then equivalent CPR file
    % data needs to be generated.
    cprStruct = getCPRInfo(ebsd);
    flagOIFormat = false;
end
% Find the first level field names of the structure
headerNames = fieldnames(cprStruct);
%%



%% Replace NaNs with zero after changing from hexagonal to square grid types
% After applying the gridify command, grid points in the regular grid that
% do not have a correspondence in the regular grid are set to NaN.
% However, this causes an issue with OI Channel-5 as the software does not
% work with NaNs in the map data.

ebsd.prop.phi1 = ebsd.rotations.phi1;
ebsd.prop.Phi = ebsd.rotations.Phi;
ebsd.prop.phi2 = ebsd.rotations.phi2;

ebsd.prop.phi1(isnan(ebsd.prop.phi1)) = 0;
ebsd.prop.Phi(isnan(ebsd.prop.Phi)) = 0;
ebsd.prop.phi2(isnan(ebsd.prop.phi2)) = 0;

if isfield(ebsd.prop,'fit')
    ebsd.prop.fit(isnan(ebsd.prop.fit)) = 0;
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


%% In case of the ANG file format, pre-rotate the ebsd data
if ~flagOIFormat && ~flagcprStruct
    disp('FUCK2')
    rot = rotation.byAxisAngle(zvector,90*degree); % counterclockwise
    ebsd = rotate(ebsd,rot,'keepEuler');
    rot = rotation.byAxisAngle(xvector,180*degree);
    ebsd = rotate(ebsd,rot,'keepXY');
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

% In case the ebsd variable only contains indexed data, use the gridified
% version of ebsd variable
ebsdGrid = ebsd.gridify;

% Transpose row & column data first
% Then flip column data from left-to-right
%% C1 = phaseIndex
% if (flagOIFormat && flagcprStruct) || (~flagOIFormat && ~flagcprStruct)
    gridData.phase = fliplr(ebsdGrid.phase.');
% else %if flagOIFormat && ~flagcprStruct
%     gridData.phase = fliplr(ebsdGrid.phase);
% end
%%

%% C2 = Euler1
% if (flagOIFormat && flagcprStruct) || (~flagOIFormat && ~flagcprStruct)
    gridData.phi1 = fliplr(ebsdGrid.prop.phi1.');
% else
%     gridData.phi1 = fliplr(ebsdGrid.prop.phi1);
% end
%%

%% C3 = Euler2
% if (flagOIFormat && flagcprStruct) || (~flagOIFormat && ~flagcprStruct)
    gridData.Phi = fliplr(ebsdGrid.prop.Phi.');
% else
%     gridData.Phi = fliplr(ebsdGrid.prop.Phi);
% end
%%

%% C4 = Euler3
% if (flagOIFormat && flagcprStruct) || (~flagOIFormat && ~flagcprStruct)
    gridData.phi2 = fliplr(ebsdGrid.prop.phi2.');
% else
%     gridData.phi2 = fliplr(ebsdGrid.prop.phi2);
% end
%%

%% C5 = MAD
% if flagOIFormat && flagcprStruct && isfield(ebsdGrid.prop,'mad')
%     disp('FUCK3')
    gridData.mad = fliplr(ebsdGrid.prop.mad.');
% elseif flagOIFormat && ~flagcprStruct && isfield(ebsdGrid.prop,'mad')
%     gridData.mad = fliplr(ebsdGrid.prop.mad);
% elseif isfield(ebsdGrid.prop,'fit')
%     gridData.mad = fliplr(ebsdGrid.prop.fit.');
% else
%     gridData.mad = zeros(size(fliplr(ebsdGrid.isIndexed.')));
% end
%%

%% C6 = BC
% if flagOIFormat && flagcprStruct && isfield(ebsdGrid.prop,'bc')
%     disp('FUCK4')
    gridData.bc = fliplr(ebsdGrid.prop.bc.');
% elseif flagOIFormat && ~flagcprStruct && isfield(ebsdGrid.prop,'bc')
%     gridData.bc = fliplr(ebsdGrid.prop.bc);
% elseif isfield(ebsdGrid.prop,'iq')
%     iq = round(255 * mat2gray(ebsdGrid.prop.iq));
%     gridData.bc = fliplr(iq.');
% elseif isfield(ebsdGrid.prop,'imagequality')
%     imagequality = round(255 * mat2gray(ebsdGrid.prop.imagequality));
%     gridData.bc = fliplr(imagequality.');
% else
%     gridData.bc = zeros(size(fliplr(ebsdGrid.isIndexed.')));
% end
%%

%% C7 = BS
% if flagOIFormat && flagcprStruct && isfield(ebsdGrid.prop,'bs')
%     disp('FUCK5')
    gridData.bs = fliplr(ebsdGrid.prop.bs.');
% elseif flagOIFormat && ~flagcprStruct && isfield(ebsdGrid.prop,'bs')
%     gridData.bs = fliplr(ebsdGrid.prop.bs);
% elseif isfield(ebsdGrid.prop,'ci')
%     ci = round(255 * mat2gray(ebsdGrid.prop.ci));
%     gridData.bs = fliplr(ci.');
% elseif isfield(ebsdGrid.prop,'confidenceindex')
%     confidenceindex = round(255 * mat2gray(ebsdGrid.prop.confidenceindex));
%     gridData.bs = fliplr(confidenceindex.');
% else
%     gridData.bs = zeros(size(fliplr(ebsdGrid.isIndexed.')));
% end
%%

%% C8 = Number of bands
% if flagOIFormat && flagcprStruct && isfield(ebsdGrid.prop,'bands')
%     disp('FUCK6')
    gridData.bands = fliplr(ebsdGrid.prop.bands.');
% elseif flagOIFormat && ~flagcprStruct && isfield(ebsdGrid.prop,'bands')
%     gridData.bands = fliplr(ebsdGrid.prop.bands);
% else
%     numBands = 6 * ones(size(ebsdGrid.isIndexed)); % assign the OI minimum of 6 bands to indexed points
%     numBands(ebsdGrid.isIndexed == 0) = 1; % assign zero bands to zero solution points
%     gridData.bands = fliplr(numBands.');
% end
%%

%% C9 = Error
% if flagOIFormat && flagcprStruct && isfield(ebsdGrid.prop,'error')
%     disp('FUCK7')
    gridData.error = fliplr(ebsdGrid.prop.error.');
% elseif flagOIFormat && ~flagcprStruct && isfield(ebsdGrid.prop,'error')
%     gridData.error = fliplr(ebsdGrid.prop.error);
% else
%     gridData.error = zeros(size(fliplr(ebsdGrid.isIndexed.')));
% end
%%

%% C10 = is or is not indexed
% As per OI convention: 0 = indexed, 1 = zero solution
% if (flagOIFormat && flagcprStruct) || (~flagOIFormat && ~flagcprStruct)
%     disp('FUCK8')
    gridData.isIndexed = fliplr(double(~ebsdGrid.isIndexed).');
% else
%     gridData.isIndexed = fliplr(double(~ebsdGrid.isIndexed));
% end
%%


%% Organise map information
% Convert into single columns and as per the required data variable
% formats for writing to the *.crc file
% classType = {'int8' 'single' 'single' 'single' 'single' 'int8' 'int8' 'int8' 'int8' 'single' 'single' ... 'single'};
% byteLength = [1 4 4 4 4 1 1 1 1 4 4 ... 4];
ebsdData{1} = uint8(gridData.phase(:));
ebsdData{2} = single(gridData.phi1(:));
ebsdData{3} = single(gridData.Phi(:));
ebsdData{4} = single(gridData.phi2(:));
ebsdData{5} = single(gridData.mad(:));
ebsdData{6} = uint8(gridData.bc(:));
ebsdData{7} = uint8(gridData.bs(:));
ebsdData{8} = uint8(gridData.bands(:));
ebsdData{9} = uint8(gridData.error(:));
ebsdData{10} = single(gridData.isIndexed(:));


%% Find the classes of the column data
for ii = 1:length(ebsdData)
    classType{ii} = class(ebsdData{ii});
end
%%


%% Define the total number of data records to write
data2Write = length(ebsdData{1})*length(classType);
toc
%%



%% Write *.cpr file
tic
screenPrint('Step','Start writing *.cpr file');
cprName = fullfile(filePath,[fileName '.cpr']);
fid = fopen(cprName,'W');

for ii=1:length(headerNames)
    % Upper case the first alphabet of first-level field names and convert
    % to a string
    % headerString = [upper(headerNames{ii}(1)), headerNames{ii}(2:end)];
    headerString = strrep(headerNames{ii},'_',' ');
    % Write the first-level field name of the structure as a string
    % into the file
    fwrite(fid,['[',headerString,']']);
    % Write a carriage return for a new line into the file
    fwrite(fid,newline);

    % Check if the first-level field name is a nested structure
    if isstruct(eval(['cprStruct.' headerNames{ii}]))
        % Find the second level field names of the structure
        subheaderNames = fieldnames(eval(['cprStruct.' headerNames{ii}]));
        for jj=1:length(subheaderNames)
            % Upper case the first alphabet of second-level field names
            % and convert to a string
            % subheaderString = [upper(subheaderNames{jj}(1)), subheaderNames{jj}(2:end)];
            subheaderString = strrep(subheaderNames{jj},'_',' ');

            % Check if the second-level field contains a string value
            subheaderValue_isString = eval(['ischar(','cprStruct.' headerNames{ii} '.' subheaderNames{jj},')']);
            % Check if the second-level field contains a numeric value
            subheaderValue_isNumeric = eval(['isnumeric(','cprStruct.' headerNames{ii} '.' subheaderNames{jj},')']);
            % Define the second-level field value as a string
            if(subheaderValue_isString)
                subheaderValue = eval(['cprStruct.' headerNames{ii} '.' subheaderNames{jj}]);
                subheaderValue = strrep(subheaderValue,'_',' ');
            end
            if(subheaderValue_isNumeric)
                subheaderValue = eval(['num2str(','cprStruct.' headerNames{ii} '.' subheaderNames{jj},')']);
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
screenPrint('Step','End writing *.cpr file');
toc
%%



%% Write *.crc file
tic
screenPrint('Step','Start writing *.crc file');
crcName = fullfile(filePath,[fileName '.crc']);
fid = fopen(crcName,'W');

% Write individual data records to the *.crc file
for ii=1:length(ebsdData{1})
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
screenPrint('Step','End writing *.crc file');
toc

screenPrint('SegmentEnd','Export ebsd data to *.cpr/crc files complete');
end
%%



%% screenPrint - Print to command window
function screenPrint(mode,varargin)
switch mode
    case 'SegmentStart'
        titleStr = varargin{1};
        fprintf('\n------------------------------------------------------');
        fprintf(['\n     ',titleStr,' \n']);
        fprintf('------------------------------------------------------\n');
    case 'Step'
        titleStr = varargin{1};
        fprintf([' -> ',titleStr,'\n']);
    case 'SubStep'
        titleStr = varargin{1};
        fprintf(['    - ',titleStr,'\n']);
    case 'SegmentEnd'
        titleStr = varargin{1};
        fprintf([' -> ',titleStr,'\n']);
        fprintf('------------------------------------------------------\n');
end
end
%%


% %% Calculate the ebsd map step size
% function stepSize = calcStepSize(inebsd)
% xx = [inebsd.unitCell(:,1);inebsd.unitCell(1,1)]; % repeat the 1st x co-ordinate to close the unit pixel shape
% yy = [inebsd.unitCell(:,2);inebsd.unitCell(1,2)]; % repeat the 1st y co-ordinate to close the unit pixel shape
% unitPixelArea = polyarea(xx,yy);
% if size(inebsd.unitCell,1) == 6 % hexGrid
%     stepSize = sqrt(unitPixelArea/sind(60));
% else % squareGrid
%     stepSize = sqrt(unitPixelArea);
% end
% end
% %%



% %% Regrid the ebsd data
% function outebsd = regrid(inebsd,stepSize)
% % Re-calculating the grid values as multiples of the calculated step size
% % this step mitigates any rounding-off errors during subsequent gridding
% % operations
% outebsd = inebsd;
% outebsd.prop.x = stepSize.*floor(outebsd.prop.x./stepSize);
% outebsd.prop.y = stepSize.*floor(outebsd.prop.y./stepSize);
% end



% %% Interpolate NaNs
% % From https://au.mathworks.com/matlabcentral/answers/34346-interpolating-nan-s
% function out = interpolateNaNs(in)
% in_notNaN = ~isnan(in);
% inLength = (1:numel(in)).';
% pp = interp1(inLength(in_notNaN),in(in_notNaN),'linear','pp');
% out = fnval(pp,inLength);
% % plot(iLength,in,'ko',iLength,out,'b-');
% % box on; grid on;
% end
% %%



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