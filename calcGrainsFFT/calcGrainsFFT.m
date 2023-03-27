function outgrains = calcFFT(inebsd,ingrains,varargin)
%% Function description:
% Returns the Fast Fourier Transforms (FFTs) of individual grains. Unless
% specified otherwise, the FFTs are calculated after padding each 
% grayscale/binary grain map to its nearest square. 
% The FFTs from grayscale and binary data are returned in grid format 
% within the 'grains.prop.fftGray' and 'grains.prop.fftBinary' structure 
% variables.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  [grains] = calcFFT(ebsd,grains)
%
%% Input:
%  ebsd         - @EBSD
%  grains       - @grain2d
%
%% Output:
%  grains       - @grain2d
%
%% Options:
%  'noPad'     -  @char, specifies no padding of the binary grain map/image
%%


% check for input variables contents
if isempty(inebsd) || isempty(ingrains)
    return;
end

% check for input variable types
if ~isa(inebsd,'EBSD')
    error('To create FFTs, first input must be an EBSD variable.');
    return;
end

if ~isa(ingrains,'grain2d')
    error('To create FFTs, second input must be a grain2d variable.');
    return;
end

% check for padding of the binary grain map/image before FFT
if ~isempty(varargin) && check_option(varargin,'noPad')
    padLogic = false;
elseif isempty(varargin) || (~isempty(varargin) && ~check_option(varargin,'noPad'))
    padLogic = true;
end



outgrains = ingrains;

for ii = 1:length(outgrains)

    ggrain = gridify(inebsd(ingrains(ii)));

    % create a grid of the grain
    if any(ismember(fields(ggrain.prop),'imagequality'))
        grainMap = ggrain.prop.imagequality;
    elseif any(ismember(fields(ggrain.prop),'iq'))
        grainMap = ggrain.prop.iq;
    elseif any(ismember(fields(ggrain.prop),'bandcontrast'))
        grainMap = ggrain.prop.bandcontrast;
    elseif any(ismember(fields(ggrain.prop),'bc'))
        grainMap = ggrain.prop.bc;
    elseif any(ismember(fields(ggrain.prop),'bandslope'))
        grainMap = ggrain.prop.bandslope;
    elseif any(ismember(fields(ggrain.prop),'bs'))
        grainMap = ggrain.prop.bs;
        %     elseif any(ismember(fields(ggrain.prop),'oldId'))
        %         grainMap = ggrain.prop.oldId;
        %     elseif any(ismember(fields(ggrain.prop),'grainId'))
        %         grainMap = ggrain.prop.grainId;
        %     elseif any(ismember(fields(ggrain.prop),'confidenceindex'))
        %         grainMap = ggrain.prop.confidenceindex;
        %     elseif any(ismember(fields(ggrain.prop),'ci'))
        %         grainMap = ggrain.prop.ci;
        %     elseif any(ismember(fields(ggrain.prop),'fit'))
        %         grainMap = ggrain.prop.fit;
        %     elseif any(ismember(fields(ggrain.prop),'semsignal'))
        %         grainMap = ggrain.prop.semsignal;
        %     elseif any(ismember(fields(ggrain.prop),'mad'))
        %         grainMap = ggrain.prop.mad;
        %     elseif any(ismember(fields(ggrain.prop),'error'))
        %         grainMap = ggrain.prop.error;
    end

    % replace NaNs with zeros
    % here the grainMap comprises the band contrast values surrounded by 0
    grainMap(isnan(grainMap)) =  0;

    % pad binary map to the nearest square (unless specified otherwise)
    % From https://au.mathworks.com/matlabcentral/answers/1853683-change-an-image-from-rectangular-to-square-by-adding-white-area
    if padLogic == true
        nrows = size(grainMap,1);
        ncols = size(grainMap,2);
        d = abs(ncols-nrows);    % find the difference between ncols and nrows
        if(mod(d,2) == 1)        % if the difference is an odd number
            if (ncols > nrows)   % add a row at the end
                grainMap = [grainMap; zeros(1, ncols)];
                nrows = nrows + 1;
            else                 % add a col at the end
                grainMap = [grainMap zeros(nrows, 1)];
                ncols = ncols + 1;
            end
        end
        if ncols > nrows
            grainMap = padarray(grainMap, [(ncols-nrows)/2 0]);
        else
            grainMap = padarray(grainMap, [0 (nrows-ncols)/2]);
        end
    end

    % fft of the greyscale data (2D power spectrum)
    fftGray = abs(log2(fftshift(fft2(grainMap))));

    % fft of the binary data (2D power spectrum)
    % here the grainMap comprises all band contrast values = 1 and surrounded by 0
    grainMap(grainMap>0) =  1;
    fftBinary = abs(log2(fftshift(fft2(grainMap))));

    % save the ffts to the grain variable
    outgrains.prop.fftGray{ii,1} = fftGray;
    outgrains.prop.fftBinary{ii,1} = fftBinary;

    % update progress
    progress(ii,length(outgrains));
    pause(0.0001);
end

% check if the user has not specified an output variable
if nargout == 0
    assignin('base','grains',outgrains);
end
end

