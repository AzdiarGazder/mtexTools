function [sXX_sYY, sXX_sZZ, sYY_sZZ] = calcYieldLocus(ori,varargin)
%% Function description:
% This code calculates the yield locus of an orientation set using the 
% equality of external work done with the virtual work via the Taylor 
% model (default and works for all crystal systems), and the Bishop-Hill 
% analysis (works for cubic systems with 24 slip systems only).
%
% In the case of the Taylor model, Mtf is calculated as the work done 
% (i.e.- it is the sum of all shears normalised by norm(strainTensor)). 
% Thereafter, for the yield locus, normalisation with the e_11 component 
% is required. 
%
% In the case of Bishop-Hill (BH) analysis, the script calculates the most 
% appropriate BH stress states for a given external strain using the 
% maximum work principle. The  output M is the maximum work normalised 
% with eXX. 
%
% The priniciple of equivalence of external work to the virtual work is 
% utilised to determine the yield locus sections. For e.g. - to determine 
% the sigmaXX - sigmaYY section (where sigmaZZ = 0), the external work is 
% (sigmaXX * eXX) + (sigmaYY * eYY) while the virtual work is W determined
% from the Taylor or Bishop-Hill methods. Equating both gives equations of
% straight lines with slopes depending on rho values. The yield locus is 
% the inner envelop of these lines.
%
%% Authors:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
% Dr. Manasij Kumar Yadava, 2023, manasijyatgmaildotcom
%
%% Acknowledgements:
% Dr. Manasij Kumar Yadava
% For developing the original script located at:
% https://github.com/manasijy/Yield_locus_programs
%
%% Syntax:
%  calcYieldLocus(ori,'method','taylor',sS)
%  calcYieldLocus(ori,'method','bishopHill',stressStates)
%
%% Input:
%  ori          - @orientation
%
%% Output:
% sXX_sYY       - @double
% sXX_sZZ       - @double
% sYY_sZZ       - @double
%
%% Options:
%  method       - @char defining the method used to compute the yield
%                 locus. Method types = 'taylor' (default), 'bishopHill'
%  sS           - @slipSystem, A list of active slip system(s) for Taylor
%                 -based calculations.
%  stressStates - @struc array containing the cell list of Bishop-Hill
%                 stress states and active slip system(s).
%

% Check if the user has specified a yield locus calculation method type
methodType = get_option(varargin,'method','taylor'); % define the default method

switch(methodType)
    case('bishopHill')
        for p = length(varargin):-1:1 % find the position of the structure variable
            if isa(varargin{p},'struct')
                pos = p;
                break
            end
        end
        if exist('pos','var')
            stressStates = varargin{pos};
        else
            error('Bishop-Hill stress states were not defined.' )
            return
        end
    
    case('taylor')
        for p = length(varargin):-1:1  % find the position of the slip system variable
            if isa(varargin{p},'slipSystem')
                pos = p;
                break
            end
        end
        if exist('pos','var')
            sS = varargin{pos};
            % Check for symmetrised slip system(s)
            isSymmetrised = sum(eq(sS(1),sS)) > 1;
            if ~isSymmetrised
                warning(sprintf('\nSymmetrised slip system(s) required.'));
                sS = sS.symmetrise;
            end
        else
            error('Slip system(s) were not defined.' )
            return
        end
end


% check for MTEX version
chkVersion = '5.10.0';
chkVerParts = getVersionParts(chkVersion);
fid = fopen('VERSION','r');
curVersion = fgetl(fid);
fclose(fid);
curVersion = erase(curVersion, 'MTEX ');
curVerParts = getVersionParts(curVersion);

if curVerParts(1) ~= chkVerParts(1)     % major version
    flagVersion = curVerParts(1) < chkVerParts(1);
elseif curVerParts(2) ~= chkVerParts(2) % minor version
    flagVersion = curVerParts(2) < chkVerParts(2);
else                                    % revision version
    flagVersion = curVerParts(3) < chkVerParts(3);
end



tic

%% Calculate the array of strain sets
allStrains = calcXYStrainMatrix(varargin);
% allStrains = calcXYStrainMatrix('points',90);

%% Define values of the strain tensor in the specimen reference frame (sRF)
strainTensor_sRF = strainTensor(zeros(3,3,length(allStrains))); % define an empty strain tensor in the specimen reference frame (sRF)
strainTensor_sRF.M(1,1,:) = allStrains(:,1);
strainTensor_sRF.M(2,2,:) = allStrains(:,2);
strainTensor_sRF.M(3,3,:) = allStrains(:,3);

%% Convert the orientation(s) to direction cosine matrices
g = matrix(ori);
% g = pagetranspose(g); % use transpose to match the original script

%% Initialise the output variables
M = zeros(1, length(allStrains));
rho = zeros(1, length(allStrains));

%% Calculate the maximum work for a given rho value
% The following loop calculates the average maximum work for a given
% applied strain set.
% For each strain set, the maximum work is calculated for each
% orientation. The maximum work values of each orientation is averaged for
% each strain set.
for ii = 1:length(allStrains)

    % Transform the strain tensor from the specimen reference frame
    % (sRF) to the crystal reference frame (xRF)
    strainTensor_xRF = inv(ori) * strainTensor_sRF(ii);

    switch(methodType)
        case('bishopHill')
            % Calulate the plastic work for an orientation for all B-H states
            W = -(strainTensor_xRF.M(1, 1, :) .* stressStates.B) +...
                (strainTensor_xRF.M(2, 2, :) .* stressStates.A)  +...
                ((strainTensor_xRF.M(2, 3, :) + strainTensor_xRF.M(3, 2, :)) .* stressStates.F)  +...
                ((strainTensor_xRF.M(1, 3, :) + strainTensor_xRF.M(3, 1, :)) .* stressStates.G)  +...
                ((strainTensor_xRF.M(1, 2, :) + strainTensor_xRF.M(2, 1, :)) .* stressStates.H);
            % Find the appropriate Bishop-Hill stress state(s) that maximise
            % the virtual work (irrespective of sign) for an orientation
            Wmax = max(abs(W), [], 2);
            % Calculate the normalised average plastic work for a given strain set
            M(ii) = mean(Wmax) / strainTensor_sRF.M(1,1,ii);
            rho(ii) = -allStrains(ii,2) / allStrains(ii,1);

        case('taylor')
            % Calculate the Taylor factor for all orientations
            [Mtf,~,~] = calcTaylor(strainTensor_xRF,sS,'silent');
            % Mtf is calculated as the work done (i.e.- it is the sum of
            % all shears normalised by norm(strainTensor)).
            % In the case of the YL, normalisation with the e_11
            % component is required.
            if flagVersion % for MTEX versions 5.10.0 and below
                M(ii) = (1/sqrt(6)) * abs(mean(Mtf) / strainTensor_sRF.M(1,1,ii));
            else % for MTEX versions 5.10.1 and above
                M(ii) = (1/sqrt(6)) * abs(mean(Mtf.* norm(strainTensor_xRF)) / strainTensor_sRF.M(1,1,ii));
            end
            rho(ii) = -allStrains(ii,2) / allStrains(ii,1);
    end

    progress(ii, length(allStrains));
end

% Re-order into single column arrays
M = M(:);
rho = rho(:);

% Only keep unique rows
output = [M, rho];
output = sortrows(output, (1:2));
[~, idxOutput, ~] = unique(output,'rows');
M = M(idxOutput);
rho = rho(idxOutput);


%% Calculate the yield locus of the 3 sections
% Note: The equality of external work done with the virtual work was used
% to determine the yield locus (YL).
theta = (0:1:360).*degree;

% Calculate the yield locus data points for the sigmaXX - sigmaYY section
% sigmaZZ = 0 on this section.
% (sigmaXX * eXX) + (sigmaYY * eYY) = W
% => sigmaXX - (-eYY / eXX) * sigmaYY = M
% => sigmaXX - (rho * sigmaYY) = M
% The above line defines a line for each rho value.
% The yield locus (YL) is the inner envelope of all these lines.
radiusXY = min(abs(M ./ (cos(theta) - rho .* sin(theta))));
[sigmaXX, sigmaYY] = pol2cart(theta, radiusXY);
sXX_sYY = [sigmaXX(:), sigmaYY(:)];

% Calculate the yield locus data points for the sigmaXX - sigmaZZ section
% sigmaYY = 0 on this section
% (sigmaXX * eXX) + (sigmaZZ * eZZ) = W
% => sigmaXX - (-eZZ / eXX) * sigmaZZ = M
% => sigmaXX - ((1-rho) * sigmaZZ) = M
% The above line defines a line for each rho value.
% The yield locus (YL) is the inner envelope of all these lines.
radiusXZ = min(abs(M./(cos(theta) -(1- rho) .* sin(theta))));
[sigmaXX, sigmaZZ] = pol2cart(theta, radiusXZ);
sXX_sZZ = [sigmaXX(:), sigmaZZ(:)];

% Calculate the yield locus data points for the sigmaYY - sigmaZZ section
% sigmaXX = 0 this section.
% (sigmaYY * eYY) + (sigmaZZ * eZZ) = W
% => sigmaYY + (eZZ / eYY) * sigmaZZ = W / eYY = (W / eXX) * (eXX / eYY)
% => sigmaYY + (eZZ / eYY) * sigmaZZ = -M / rho
% => sigmaYY + ((1-rho)/rho * sigmaZZ) = -M / rho
% The above line defines a line for each rho value.
% The yield locus (YL) is the inner envelope of all these lines.
radiusYZ = min(abs(M ./ ((rho - 1) .* sin(theta) - rho * cos(theta))));
[sigmaYY, sigmaZZ] = pol2cart(theta, radiusYZ);
sYY_sZZ = [sigmaYY(:), sigmaZZ(:)];
%%


end




function parts = getVersionParts(V)
parts = sscanf(V, '%d.%d.%d')';

if length(parts) < 3
    parts(3) = 0; % zero-fills to 3 elements
end

end
