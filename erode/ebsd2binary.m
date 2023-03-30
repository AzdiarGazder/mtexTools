function outebsd = ebsd2binary(inebsd,varargin)
%% Function description:
% Converts ebsd data of a single grain to a binary ones or zeros.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  [outebsd] = ebsdBinary(inebsd)
%
%% Input:
%  inMap          - @EBSDsquare or @EBSDhex or @ebsd

%
%% Output:
%  outebsd         - @logical
%
%% Options:
% 'ones', 'zeros'  -  @char, specifies what to binarise ebsd data with
%%


% check for input ebsd data type
if ~isa(inebsd,'EBSDhex') || ~isa(inebsd,'EBSDsquare')
inebsd = gridify(inebsd);
else
    error('Input must be an @EBSDsquare, @EBSDhex or @ebsd variable.');
    return;
end

% check for binarise option
if ~isempty(varargin) && any(strcmpi(varargin,'ones'))
    padLogic = true;

elseif ~isempty(varargin) && any(strcmpi(varargin,'zeros'))
    padLogic = false;

elseif ~isempty(varargin) && (~any(strcmpi(varargin,'ones')) || ~any(strcmpi(varargin,'zeros')))
    error('Specify if binarising ebsd data is with ones or zeros.');
    return;
end


% gridify the ebsd data of the grain
ggrain = gridify(inebsd);

% create a gridded map using any ebsd property of the grain of interest
if any(ismember(fields(ggrain.prop),'imagequality'))
    outebsd = ggrain.prop.imagequality;
elseif any(ismember(fields(ggrain.prop),'iq'))
    outebsd = ggrain.prop.iq;
elseif any(ismember(fields(ggrain.prop),'bandcontrast'))
    outebsd = ggrain.prop.bandcontrast;
elseif any(ismember(fields(ggrain.prop),'bc'))
    outebsd = ggrain.prop.bc;
elseif any(ismember(fields(ggrain.prop),'bandslope'))
    outebsd = ggrain.prop.bandslope;
elseif any(ismember(fields(ggrain.prop),'bs'))
    outebsd = ggrain.prop.bs;
elseif any(ismember(fields(ggrain.prop),'oldId'))
    outebsd = ggrain.prop.oldId;
elseif any(ismember(fields(ggrain.prop),'grainId'))
    outebsd = ggrain.prop.grainId;
elseif any(ismember(fields(ggrain.prop),'confidenceindex'))
    outebsd = ggrain.prop.confidenceindex;
elseif any(ismember(fields(ggrain.prop),'ci'))
    outebsd = ggrain.prop.ci;
elseif any(ismember(fields(ggrain.prop),'fit'))
    outebsd = ggrain.prop.fit;
elseif any(ismember(fields(ggrain.prop),'semsignal'))
    outebsd = ggrain.prop.semsignal;
elseif any(ismember(fields(ggrain.prop),'mad'))
    outebsd = ggrain.prop.mad;
elseif any(ismember(fields(ggrain.prop),'error'))
    outebsd = ggrain.prop.error;
end

% replace NaNs with 0s
% now the gridded data comprises the grain ebsd property values surrounded by 0
outebsd(isnan(outebsd)) =  0;

% replace grain ebsd property values with 1s
% now the gridded data becomes a binary map
outebsd(outebsd > 0) =  1;

% check for binary output type
if padLogic == false
    outebsd = ~outebsd;
end

end