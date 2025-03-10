function ebsd = jitterCorrect(ebsd)
%% Function description:
% This function automatically removes jitter error from EBSD maps caused
% by charging of the sample during map acquisition.
% Here jitter refers to the small, random variations or noise in the
% horizontal positioning of indexed ebsd pixels during map acquisition.
% It is typically caused by charging and discharging of the sample under
% the electron beam. The jitter results in the non-uniform and incorrect
% placement of indexed pixels.
% Jitter affects the spatial coherence and the geometric accuracy of
% (sub)grains and their associated boundaries by distorting their shapes
% because the pixels are not sampled or positioned as intended. Thus, the
% jitter error is more commonly associated with temporal or spatial
% inconsistencies.
% In the case of band contrast and band slope values, the jitter error
% also causes pixel-level variations in grayscale intensity.
%
%% Author:
% Dr. Azdiar Gazder, 2025, azdiaratuowdotedudotau
%
%% Syntax:
%  jitterCorrect(ebsd)
%
%% Input:
% ebsd - @EBSD
%
%% Output:
% ebsd - @EBSD
%
% Figures comprising:
% - Map: The grain boundary segments as a function of azimuthal angle
% - Map: The grain boundary segments with azmuthal angle = 0 degrees
%
%% Options:
%  none
%
%%


% Get the number of phases in the ebsd map
numPhases = length(ebsd.CSList) - 1;
% Binary table with all combinations for a given number of variables
combo = binaryTable(numPhases);
% Get the rows whose sum is <= 2 (i.e. - keep rows with only 1 and 2 phase combinations)
combo = combo((sum(combo,2) >= 1 & sum(combo,2) <= 2),:);
% Replace the ones with (column number + 1)
% (column number + 1) is used because the first indexed phase is
% ebsd.CSList{2}
combo = combo .* ((1:size(combo,2)) + 1);
% Delete the zeros in each row
combo = arrayfun(@(xx) combo(xx, combo(xx,:) ~= 0), (1:size(combo,1))', 'UniformOutput', false);
% Duplicate the element in cells with one element
% Identify cells with one element
idx = cellfun(@(xx) numel(xx)==1, combo);
% For those cells, duplicate the single element
combo(idx) = cellfun(@(xx) [xx xx], combo(idx), 'UniformOutput', false);
% Convert to a double array
combo = sortrows(cell2mat(combo));


%% Calculate grains
disp('Calculating grains...');
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',2*degree,'unitCell');
disp('Done!');
disp('-----');
%%


%% Calculate grain boundaries
disp('Calculating all grain boundary combinations...');
sz = zeros(size(combo,1),1);
for ii = 1:size(combo,1)
    gB = grains.boundary(ebsd.CSList{combo(ii,1)}.mineral,ebsd.CSList{combo(ii,2)}.mineral);
    sz(ii) = size(gB,1);
    gB_all{ii,1} = gB;
end

% Sort the grain boundary combinations according to their number fraction
sz = sz(:);
[~,id] = sort(sz,'descend');
combo = combo(id,:);
gB_all = gB_all(id);
disp('Done!');
disp('-----');
%%


%% Perform jitter correction
disp('*****');
pixelId = cell(size(combo,1),1);
for ii = 1:size(combo,1)

    disp(['Identifying the jitter error pixels: Pass ',num2str(ii),' / ',num2str(size(combo,1))]) ;

    % Get one grain boundary combination
    gB = gB_all{ii};

    % Get the grain boundary directions
    gB_direction = gB.direction;

    % Get the grain boundary trace direction
    azimuthalAngle = atan(gB_direction.y./gB_direction.x);

    % Define the east as 0 degrees and calculate the azimuthal angles going
    % counter-clockwise
    azimuthalAngle(azimuthalAngle < 0) = azimuthalAngle(azimuthalAngle < 0) + pi();
    azimuthalAngle = mod(azimuthalAngle, pi());

    % Find all the interphase boundary segments with jitter error
    % In this dataset, they comprise horizontal boundary segments
    lA1 = azimuthalAngle == 0*degree;
    gB_0degree = gB(lA1);

    % Find the pixel Ids corresponding to all horizontal boundary segments
    % with azimuthal angle = 0 degrees
    temp_pixelId = gB_0degree.ebsdId;
    temp_pixelId = temp_pixelId(:);

    % Find the repeated pixelIds in the array
    % The horizontal pixels comprising the jitter error are enclosed by two
    % unique interphase boundaries - one located at the top of each pixel and
    % one located at the bottom of the same pixel.
    % Thus, the pixel Id of these pixels will be repeated in the pixelId array,
    % the first time for the top interphase boundary, and the second time for
    % the bottom interphase boundary.
    % By finding these pixel Ids, only the pixels comprising the jitter error
    % are isolated. The other pixels comprising horizontal boundary segments
    % with azimuthal angle = 0 degrees are left untouched.
    lA2 = isMultiple(temp_pixelId);
    temp_pixelId = temp_pixelId(lA2);

    pixelId{ii,1} = temp_pixelId;
end

pixelId = cell2mat(pixelId);
pixelId = pixelId(:);
uniquePixelId = unique(pixelId);

disp('Done!');
disp('-----');
%%


%% Assign zero solutions (not indexed) to the pixel Ids comprising the
% jitter error
disp('- Assigning zero solutions to the jitter error pixels');
ebsd(uniquePixelId).phaseId = 1;
disp('Done!');
disp('-----');
%%


%% Correct the band contrast and band slope values of the pixel Ids
% comprising the jitter error
disp('- Averaging BC and BS values of the jitter error pixels');
% Find the indices of pixels to the top and bottom of a pixel of interest
[Dl, Dr] = findNeighbours(ebsd,'type','vertical');

% Calculate the band contrast and slope for all pixels at once
tbBandContrast = arrayfun(@(id) ebsd(Dl(Dr == id)).bc, uniquePixelId, 'UniformOutput', false);
tbBandSlope = arrayfun(@(id) ebsd(Dl(Dr == id)).bs, uniquePixelId, 'UniformOutput', false);

% Vectorise the calculation of the mean values while ignoring NaNs
bcMean = cellfun(@(bc) sum(bc, 'omitnan') / max(sum(~isnan(bc)), 1), tbBandContrast);
bsMean = cellfun(@(bs) sum(bs, 'omitnan') / max(sum(~isnan(bs)), 1), tbBandSlope);

% Assign the calculated mean values back to the corresponding pixels
ebsd(uniquePixelId).bc = bcMean;
ebsd(uniquePixelId).bs = bsMean;

disp('Done!');
disp('-----');
%%

% end
disp('*****')