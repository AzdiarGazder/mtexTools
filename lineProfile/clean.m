function out_ebsd = clean(in_ebsd)
%% Function description:
% This function performs linear interpolation on ebsd property data 
% containing NaNs.
%
%% Modified by:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Original post:
% https://au.mathworks.com/matlabcentral/answers/34346-interpolating-nan-s
%
%% Syntax:
%  out = interpolateNaNs(in)
%
%% Input:
%  in        - @double
%
%% Output:
%  out       - @double
%
%%

% Check if input ebsd map data is gridded
flagGrid = false;
if isa(in_ebsd,'EBSDsquare') || isa(in_ebsd,'EBSDhex')
    flagGrid = true;
    out_ebsd = EBSD(in_ebsd);
end

% TO-DO: Currently unable to write to access-protected data
% fields = fieldnames(out_ebsd.rotations);
% for ii = 1:length(fields)
%     temp = eval(['out_ebsd.rotations.',fields{ii}]);
%     if isa(['out_ebsd.rotations.',fields{ii}],'double') && sum(isnan(temp)) > 0
%         temp = interpolateNaNs(temp);
%         eval(['out_ebsd.rotations.',fields{ii} '= temp']);
%     end
% end

fields = fieldnames(out_ebsd.prop);
for ii = 1:length(fields)
    temp = eval(['out_ebsd.prop.',fields{ii}]);
    if isa(['out_ebsd.prop.',fields{ii}],'double') && sum(isnan(temp)) > 0
        temp = interpolateNaNs(temp);
        eval(['out_ebsd.prop.',fields{ii} '= temp']);
    end
end

% Re-grid output map data if the input ebsd map data was gridded
if flagGrid
    out_ebsd = gridify(out_ebsd);
end

end
%%




function out = interpolateNaNs(in)
%% Function description:
% This function performs linear interpolation on a column of data 
% containing NaNs.
%
%% Modified by:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Original post:
% https://au.mathworks.com/matlabcentral/answers/34346-interpolating-nan-s
%
%% Syntax:
%  out = interpolateNaNs(in)
%
%% Input:
%  in        - @double
%
%% Output:
%  out       - @double
% 
%%

in_notNaN = ~isnan(in);
inLength = (1:numel(in)).';
pp = interp1(inLength(in_notNaN),in(in_notNaN),'linear','pp');
out = fnval(pp,inLength);
% plot(iLength,in,'ko',iLength,out,'b-');
% box on; grid on;

end
%%