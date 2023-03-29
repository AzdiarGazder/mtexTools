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


outgrains = ingrains;

for ii = 1:length(outgrains)

    ggrain = gridify(inebsd(ingrains(ii)));

    % create a gridded map using any ebsd property of the grain of interest
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
    end

    % replace NaNs with zeros
    % here the grainMap comprises greyscale IQ/BC/BS values surrounded by 0s
    grainMap(isnan(grainMap)) =  0;

    % pad grainMap to the nearest square
    grainMap = pad(grainMap,'square','zeros');

    % fft of the square greyscale data (2D power spectrum)
    fftGray = abs(log2(fftshift(fft2(grainMap))));

    % binarise the greyscale data
    % here the grainMap comprises IQ/BC/BS values = 1 surrounded by 0s
    grainMap(grainMap>0) =  1;

    % fft of the square binary data (2D power spectrum)
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

