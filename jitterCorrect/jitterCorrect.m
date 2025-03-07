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
x = 0: (2^numPhases - 1);
combo = flipud(dec2bin(x', numPhases) == '0');
% Get the rows whose sum is 2 (i.e. - keep rows with only 2 phase combinations)
combo = combo(sum(combo,2)==2,:);
% Replace the ones with (column number + 1)
% (column number + 1) is used because the first indexed phase is
% ebsd.CSList{2}
combo = combo .* ((1:size(combo,2)) + 1);
% Delete the zeros in each row
combo = arrayfun(@(ii) combo(ii, combo(ii,:) ~= 0), (1:size(combo,1))', 'UniformOutput', false);
combo = sortrows(cell2mat(combo));


disp('Calculating grain boundary combinations...');
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',2*degree,'unitCell');
sz = zeros(size(combo,1),1);
for ii = 1:size(combo,1)
    gB = grains.boundary(ebsd.CSList{combo(ii,1)}.mineral,ebsd.CSList{combo(ii,2)}.mineral);
    sz(ii) = size(gB,1);
end
sz = sz(:);
[~,id] = sort(sz);
combo = combo(id,:);
disp('Done!');
disp('-----');


disp('*****');
for ii = 1:size(combo,1)

    disp(['Performing jitter correction: Pass ',num2str(ii),' / ',num2str(size(combo,1))]) ;

    %% Calculate grains
    disp('- Calculating grains');
    [grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',2*degree,'unitCell');

    %     disp('Done!');
    %     disp('-----');
    %%


    %% Delete the pixels comprising the jitter error
    disp('- Identifying the jitter error pixels');
    % Define the interphase boundaries with the jitter error
    gB = grains.boundary(ebsd.CSList{combo(ii,1)}.mineral,ebsd.CSList{combo(ii,2)}.mineral);

    % Get the grain boundary directions
    gB_direction = gB.direction;

    % Get the grain boundary trace direction
    azimuthalAngle = atan(gB_direction.y./gB_direction.x);

    % Define the east as 0 degrees and calculate the azimuthal angles going
    % counter-clockwise
    azimuthalAngle(azimuthalAngle < 0) = azimuthalAngle(azimuthalAngle < 0) + pi();
    azimuthalAngle = mod(azimuthalAngle, pi());

    %     % Plot the grain boundary segments as a function of azimuthal angle
    %     figH = figure;
    %     plot(gB,azimuthalAngle./degree,'linewidth',1);
    %     setColorRange([0 90]);
    %     mtexColorbar jet;
    %     set(figH,'Name','Interphase boundary map: Boundary segment azimuthal angles','NumberTitle','on');

    % Find all the interphase boundary segments with jitter error
    % In this dataset, they comprise horizontal boundary segments
    lA1 = azimuthalAngle == 0*degree;
    gB_0degree = gB(lA1);
    azimuthalAngle_0degree = azimuthalAngle(lA1);

    %     % Plot all grain boundary segments with azmuthal angle = 0 degrees
    %     figH = figure;
    %     plot(gB_0degree,azimuthalAngle_0degree./degree,'linewidth',1);
    %     setColorRange([0 90]);
    %     mtexColorbar jet;
    %     set(figH,'Name','Interphase boundary map: Boundary segments with azimuthal angle = 0 degrees','NumberTitle','on');

    % Find the pixel Ids corresponding to all horizontal boundary segments
    % with azimuthal angle = 0 degrees
    pixelId = gB_0degree.ebsdId;
    sz = size(pixelId);
    pixelId = pixelId(:);

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
    lA2 = isMultiple(pixelId);
    pixelId = pixelId(lA2);

    %     % Plot the grain boundary segments with azimuthal angle = 0 degrees
    %     % comprising the jitter error
    %     % Reshape the logical array to match the pixelId array
    %     lA3 = reshape(lA2,sz);
    %     lA3 = lA3(:,1) | lA3(:,2);
    %     figH = figure;
    %     plot(gB_0degree(lA3),azimuthalAngle_0degree(lA3),'linewidth',1);
    %     setColorRange([0 90]);
    %     mtexColorbar jet;
    %     set(figH,'Name','Interphase boundary map: Boundary segments comprising the jitter error','NumberTitle','on');

    %     drawnow;
    %     disp('Done!');
    %     disp('-----');
    %%


    %% Assign zero solutions (not indexed) to the pixel Ids comprising the
    % jitter error
    disp('- Assigning zero solutions to the pixels');
    uniquePixelId = unique(pixelId);
    ebsd(uniquePixelId).phaseId = 1;
    %     disp('Done!');
    %     disp('-----');
    %%


    %% Correct the band contrast and band slope values of the pixel Ids
    % comprising the jitter error
    disp('- Averaging BC and BS values of the pixels');
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

end
disp('*****')