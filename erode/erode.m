function outebsd = erode(inebsd,ingrain)
%% Function description:
% Erodes the ebsd data surrounding individual grains of interest by one
% pixel.
%
%% Note to users:
% Requires the calcStepSize.m, ebsd2binary.m and pad.m functions to run.
%
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgments:
% The original image erosion algorithm by Aaron Angel can be found at:
% https://www.imageeprocessing.com/2012/09/image-erosion-without-using-matlab.html
%
%% Syntax:
%  [ebsd] = erode(ebsd,grain)
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
    error('First input must be an EBSD variable.');
    return;
end

if ~isa(ingrain,'grain2d')
    error('Second input must be a grain2d variable.');
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

% pad the grainMap with ones on the left and right -sides
padMap = pad(grainMap,'size',[0 1],'ones');

% define a structuring element array for erosion
strucElement = [1 1 0];

% define a blank grainMap for erosion
erodeMap = false(size(grainMap));

% perform the erosion
for ii = 1:size(padMap,1)
    for jj = 1:size(padMap,2)-2
        In = padMap(ii, jj:jj+2);
        % find the position of the ones in the structuring element array
        In1 = (strucElement == 1);
        % check whether the elements in the window have the value = one in
        % the same positions of the structuring element
        if In(In1) == 1
            erodeMap(ii,jj) = 1;
        end
    end
end

% convert the logical map to a numeric map
erodeMap = double(erodeMap);

[rIdx,cIdx] = find(erodeMap == 1); % rows and columns of pixels = 1
idx = sub2ind(size(ggrain),rIdx,cIdx); % the indices of pixels = 1
[logChk,~] = inpolygon(xMap,yMap,xGrain(idx),yGrain(idx));

% define a new ebsd variable with eroded ebsd map data
temp_outebsd = gebsd(logChk);

% un-gridify the eroded ebsd map data
outebsd = EBSD(temp_outebsd);

end
