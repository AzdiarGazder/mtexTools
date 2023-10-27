function [R, minMtheta, Mtheta, rhoTheta]  = calcLankford(ori,sS,varargin)
%% Function description:
% This function calculates the minimum Taylor factor (M) and the Lankford 
% coefficient or plastic anisotropy ratio (R-value or r-value) as a 
% function of the angle to the tensile direction (theta).
%
% The R-value, is the ratio of the true width strain to the true thickness 
% strain at a particular value of length strain.
%
% The normal anisotropy ratio (Rbar, or Ravg, or rm) defines the ability
% of the metal to deform in the thickness direction relative to 
% deformation in the plane of the sheet. 
% For Rbar values >= 1, the sheet metal resists thinning, improves cup 
% drawing, hole expansion, and other forming modes where metal thinning 
% is detrimental. 
% For Rbar < 1, thinning becomes the preferential metal flow direction, 
% increasing the risk of failure in drawing operations.
%
% A related parameter is the planar anisotropy parameter (deltaR) which is
% an indicator of the ability of a material to demonstrate non-earing 
% behavior. A deltaR value = 0 is ideal for can-making or deep drawing of 
% cylinders, as this indicates equal metal flow in all directions; thus 
% eliminating the need to trim ears during subsequent processing.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
% Dr. Manasij Kumar Yadava, 2023, manasijyatgmaildotcom
%
%% Acknowledgements:
% Dr. Manasij Kumar Yadava
% For developing the original script located at:
% https://github.com/manasijy/M_theta
% Theroretical exalanations from:
% https://ahssinsights.org/forming/mechanical-properties/r-value/
%
%% Syntax:
%  calcLankford(ori,sS)
%
%% Input:
%  ori          - @orientation
%  sS           - @slipSystem
%
%% Output:
% R             - @double, plastic anisotropy ratio (R-value) at 
%                 minimum Taylor factor (M) as a function of the angle 
%                 (theta) to the horizontal tensile direction.
% minMtheta     - @double, minimum Taylor factor (M) as a function of the 
%                 angle (theta) to the horizontal tensile direction.
% Mtheta        - @double, An array of Taylor factor as a function of the
%                 angle (theta) to the horizontal tensile direction.
% rhoTheta      - @double, An array of plastic strain (rho) as a function 
%                 of the angle (theta) to the horizontal tensile direction.
%
%% Options:
% silent        - @char, supress output
% weights       - @double, containing texture information
%

warning(sprintf(['\ncalcLankford assumes tensile direction = horizontal; rotation = out-of-plane']));

% Check for symmetrised slip system(s)
isSymmetrised = sum(eq(sS(1),sS)) > 1;
if ~isSymmetrised
    warning(sprintf('\nSymmetrised slip system(s) required.'));
    sS = sS.symmetrise;
end



%% Rotate the orientations incrementally about the pre-defined tensile axis
% Here horizontal || tensile axis || RD (nominally)
theta = linspace(0,90*degree,19); 
oriRot = (rotation.byAxisAngle(zvector,theta) * ori).'; % rowwise reshape into a single column vector



%% Define a strain tensor in the specimen reference frame (sRF)
% Method 1
% The strainTensor_sRF is not axi-symmetric since rho values are changing
rhoRange = linspace(0,1,11); % 0-100 % uniaxial tension 
strainTensor_sRF = strainTensor(zeros(3,3,length(rhoRange))); % define an empty strain tensor in the specimen reference frame (sRF)
strainTensor_sRF.M(1,1,:) = 1;
strainTensor_sRF.M(2,2,:) = -rhoRange;
strainTensor_sRF.M(3,3,:) = -(1 - rhoRange); 
% Method 2
% eps_sRF = velocityGradientTensor.uniaxial(xvector,rhoRange);

%% Transform the strain tensor from the specimen reference frame (sRF)
% to the crystal reference frame (xRF)
% Method 1
strainTensor_xRF = inv(oriRot) * strainTensor_sRF; % rows    = orientations
                                                   % columns = incrementally increasing strain tensors
strainTensor_xRF = strainTensor_xRF(:); % reshape columnwise into a single column vector
% Method 2
% strainTensor_xRF = inv(oriRot) * eps_sRF;

%% Calculate the Taylor factor as a function of the strain tensor for
% all orientations
% Taylor factor (M) = ori x theta x strain (or rho) range
[M,~,~] = calcTaylor(strainTensor_xRF,sS);%,'silent');
M = reshape(M,length(ori),length(theta),length(rhoRange));

% %% Average the Taylor factor over the texture
% weights = get_option(varargin,'weights',ones(size(ori)));
% weights = weights ./ sum(weights);
% weights = repmat(weights,1,length(theta),length(rhoRange));
% M = weights .* M;

%% Create the Mtheta array
Mtheta = permute(mean(M),[1 3 2]); 
Mtheta = reshape(Mtheta,[],size(mean(M),2),1);

%% Find the minimum Taylor factor and spin along the strain (or rho) range
[minMtheta,idx] = min(Mtheta); 

%% Find the corresponding R and rhoTheta values
Rrange = rhoRange ./ (1 - rhoRange);
R = Rrange(idx);
rhoTheta = rhoRange(idx);

disp('Done!')

disp('---')
disp(['M at 0°  to RD = ',num2str(minMtheta(1))]);
disp(['M at 45° to RD = ',num2str(minMtheta(10))]);
disp(['M at 90° to RD = ',num2str(minMtheta(19))]);
disp('---')
disp(['R at 0°  to RD = ',num2str(R(1))]);
disp(['R at 45° to RD = ',num2str(R(10))]);
disp(['R at 90° to RD = ',num2str(R(19))]);
disp('---')
Rbar = 0.5 * (R(1) + R(19) + 2*R(10));
disp(['Rbar = ',num2str(Rbar)]);
disp('---')
deltaR = 0.5 * (R(1) + R(19) - 2*R(10));
disp(['deltaR = ',num2str(deltaR)]);
disp('---')
end



