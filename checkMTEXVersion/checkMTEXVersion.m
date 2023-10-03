function flagVersion = checkMTEXVersion(chkVersion) 
%% Function description:
% Compare versions of the current MTEX toolbox to a user-specified version 
% string of the form 'majorVersion.minorVersion.revisionVersion'.
% Returns true if the current toolbox version is less than the 
% user-specified version string.
% Returns false if the current toolbox version is greater than the 
% user-specified version string.

% split the check MTEX version into parts
chkVerParts = getVersionParts(chkVersion);

% split the current toolbox MTEX version into parts
fid = fopen('VERSION','r');
curVersion = fgetl(fid);
fclose(fid);
curVersion = erase(curVersion, 'MTEX ');
curVerParts = getVersionParts(curVersion);

% compare chkVerParts against curVerParts
if curVerParts(1) ~= chkVerParts(1)     % major version
    flagVersion = curVerParts(1) < chkVerParts(1);
elseif curVerParts(2) ~= chkVerParts(2) % minor version
    flagVersion = curVerParts(2) < chkVerParts(2);
else                                    % revision version
    flagVersion = curVerParts(3) < chkVerParts(3);
end

end


function parts = getVersionParts(V)
parts = sscanf(V, '%d.%d.%d')';

if length(parts) < 3
    parts(3) = 0; % zero-fills to 3 elements
end

end