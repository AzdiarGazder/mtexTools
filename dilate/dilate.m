function outebsd = dilate(inebsd,ingrain)
%% Function description:
% Dilates the ebsd data surrounding individual, multiple contiguous or 
% multiple discrete grains of interest by one pixel.
%
%% Note to users:
% Requires the calcStepSize.m, ebsd2binary.m and pad.m functions to run.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgments:
% The original image dilation algorithm by Aaron Angel can be found at:
% https://www.imageeprocessing.com/2012/09/image-dilation-without-using-imdilate.html
%
%% Syntax:
%  [ebsd] = dilate(ebsd,grain)
%
%% Input:
%  ebsd        - @EBSD
%  grain       - @grain2d
%
%% Output:
%  ebsd        - @EBSD
%%

% check for input variables contents
if isempty(inebsd) || isempty(ingrain)
    return;
end

% check for input variable types
if ~isa(inebsd,'EBSD')
    error('Input must be @ebsd and @grain2d variable.');
    return;
end

if ~isa(ingrain,'grain2d')
    error('Input must be @ebsd and @grain2d variable.');
    return;
end


% calculate the ebsd map step size
stepSize = calcStepSize(inebsd);

% gridify the ebsd map data
gebsd = gridify(inebsd);
xMap = stepSize.*floor(gebsd.prop.x./stepSize);
yMap = stepSize.*floor(gebsd.prop.y./stepSize);

% gridify the ebsd data of the grain of interest
ggrain = gridify(gebsd(ingrain));
xGrain = stepSize.*floor(ggrain.prop.x./stepSize);
yGrain = stepSize.*floor(ggrain.prop.y./stepSize);

% binarise the gridded ebsd data of the grain
grainMap = ebsd2binary(ggrain,'ones');

% pad the grainMap with a row and column of zeros on all the four sides
padMap = pad(grainMap,'size',[1 1],'zeros');

% define a structuring element array for dilation
% strucElement = [1 1 1; 1 1 1; 1 1 1];
strucElement = [0 1 0; 1 1 1; 0 1 0];

% define a blank grainMap for dilation
dilateMap = false(size(grainMap));

% perform the dilation
for ii = 1:size(padMap,1)-2
    for jj = 1:size(padMap,2)-2
        % perform the logical "AND" operation
        dilateMap(ii,jj) = sum(sum(strucElement & padMap(ii:ii+2, jj:jj+2)));
    end
end

% convert the logical map to a numeric map
dilateMap = double(dilateMap);

[rIdx,cIdx] = find(dilateMap == 1); % rows and columns of pixels = 1
idx = sub2ind(size(ggrain),rIdx,cIdx); % the indices of pixels = 1
[logChk,~] = inpolygon(xMap,yMap,xGrain(idx),yGrain(idx));

% define a new ebsd variable with dilated ebsd map data
temp_outebsd = gebsd(logChk);

% un-gridify the dilated ebsd map data
outebsd = EBSD(temp_outebsd);

end
