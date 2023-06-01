function [modODF,modes,vol] = calcModelTexture(expODF,ori,psi)
%% Function description:
% Returns a model ODF based on a user specified number of ideal 
% orientations used as seeds.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
% 
%% Syntax:
%  calcModelTexture(expODF,ori,psi)
%
%% Input:
%  odf          - @SO3FunRBF or @SO3FunHarmonic
%  ori          - @orientation
%  psi          - @SO3DeLaValleePoussinKernel 
%                 calculated optimal kernal for the experimental ODF
%%


%% Find the orientation component and volume fraction of the ideal
% for ii = 1:4
%     if ii == 1 % Coarse: from the full list of ideal orientations & their symmetric counterparts
% %         phi1 = eA(:,1)*degree; PHI = eA(:,2)*degree; phi2 = eA(:,3)*degree;
% %         ori =
%         unique(orientation.byEuler(phi1,PHI,phi2,expODF.CS,specimenSymmetry('orthorhombic')));  
%         ori = unique(orientation.byEuler(ori.phi1,ori.Phi,ori.phi2,expODF.CS,specimenSymmetry('orthorhombic')));
%         ori = symmetrise(ori);
%     elseif ii == 2 % Semi-refined: from the condensed list of ideal orientations & their symmetric counterparts
%         clear phi1 PHI phi2 ori
%         phi1 = modes.phi1; PHI = modes.Phi; phi2 = modes.phi2;
%         ori = symmetrise(orientation.byEuler(phi1,PHI,phi2,expODF.CS,specimenSymmetry('orthorhombic')));
%     elseif ii >= 3 % Refined: from the condensed list of ideal orientations
%         clear phi1 PHI phi2 ori
%         phi1 = modes.phi1; PHI = modes.Phi; phi2 = modes.phi2;
%         ori = orientation.byEuler(phi1,PHI,phi2,expODF.CS,specimenSymmetry('orthorhombic'));
%     end
%     % using ideal orientations as seeds for the experimental ODF
%     [modes,vol,~] = calcComponents(expODF,...
%         'seed',ori(:),...
%         'maxIter',500,...
%         'resolution',psi.halfwidth/2,...
%         'exact');
% %             'tolerance',2*psi.halfwidth,...
% end
% % Normalise the volume fraction
% vol = vol./sum(vol);


for ii = 1:5
    if ii == 1 % Coarse: from the full list of ideal symmetric orientations
%         phi1 = eA(:,1)*degree; PHI = eA(:,2)*degree; phi2 = eA(:,3)*degree;
%         ori = unique(orientation.byEuler(phi1,PHI,phi2,expODF.CS,specimenSymmetry('orthorhombic')));
        ori = unique(orientation.byEuler(ori.phi1,ori.Phi,ori.phi2,expODF.CS,specimenSymmetry('orthorhombic')));
        ori = symmetrise(ori);
        % using ideal symmetric orientations as seeds
        [modes,vol,~] = calcComponents(expODF,...
            'seed',ori(:),...
            'maxIter',500,...
            'resolution',psi.halfwidth/2,...
            'exact');
        % normalise the volume fraction
        vol = vol./sum(vol);

    elseif ii >= 2 % Semi-refined: from the list of coarse symmetric orientations
        clear phi1 PHI phi2 ori
        phi1 = modes.phi1; PHI = modes.Phi; phi2 = modes.phi2;
        ori = symmetrise(orientation.byEuler(phi1,PHI,phi2,expODF.CS,specimenSymmetry('orthorhombic')));
        % using coarse symmetric orientations as seeds
        [modes,vol,~] = calcComponents(expODF,...
            'seed',ori(:),...
            'maxIter',500,...
            'resolution',psi.halfwidth/2,...
            'exact');
        % normalise the volume fraction
        vol = vol./sum(vol);

%     elseif ii >= 3 % Refined: from the list of semi-refined orientations
%         clear phi1 PHI phi2 ori
% %         [modes,~,id2] = unique(modes,'tolerance',2*psi.halfwidth); 10*degree);
% %         vol = accumarray(id2,vol);
%         phi1 = modes.phi1; PHI = modes.Phi; phi2 = modes.phi2;
%         ori = orientation.byEuler(phi1,PHI,phi2,expODF.CS,specimenSymmetry('orthorhombic'));
%         % using unique semi-refined orientations and volume fractions as seeds
%         [modes,vol,~] = calcComponents(expODF,...
%             'seed',ori(:),...
%             'weights',vol,...
%             'maxIter',500,...
%             'resolution',psi.halfwidth/2,...
%             'exact');
%         % normalise the volume fraction
%         vol = vol./sum(vol);
    end
end



%% Create a model ODF
hwidth = 2*psi.halfwidth;
modODF = vol(1) * unimodalODF(modes(1),'halfwidth',hwidth);
for ii = 2:length(modes)
    tempODF =  vol(ii) * unimodalODF(modes(ii),'halfwidth',hwidth);
    modODF = modODF + tempODF;
end