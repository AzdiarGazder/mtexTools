%% Demonstration description:
% This script demonstrates how to apply the inflection and threshold 
% algorithms to automatically segment and quantify the deformed, recovered, 
% newly nucleated and growing grain fractions of a partially 
% recrystallised EBSD map.
% This script is the latest developmental iteration of the multi-condition 
% segmentation method first desribed in:
% AA Gazder et al., Evolution of recrystallization texture in a 0.78 wt.% 
% Cr extra-low-carbon steel after warm and cold rolling, Acta Materialia,
% 59(12), p. 4847-4865, 2011.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
% 
%% Syntax:
%  demo_rcrxSegmenter_inflectThreshold
%
%% Input:
%  none
%
%% Output:
% Output in the command window:
% - the statistics related to the various subsets
%
% Figures comprising:
% - Plots: the maps of various subsets
% - Map: EBSD maps of the various subsets
%
%% Options:
%  none
%
%%


%% Clear workspace
close all; clc; clear all; clear hidden;

%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','intoPlane');
setMTEXpref('maxSO3Bandwidth',96);


%% Define the critical angle for a high-angle boundary
criticalAngle = 7.5; % in degrees (min = 5; ideal = 7.5; max = 15)

%% Import the dataset
ebsd = EBSD.load('FL35.ctf','interface','ctf',...
    'convertEuler2SpatialReferenceFrame');
ebsd = ebsd('indexed');

%% Store the crystal symmetry
CS = ebsd.CSList{2};
fR = fundamentalRegion(CS,CS);

%% Calculate the grains
% Identify grains
disp('Identifying grains...')
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',2*degree);
% [grains,ebsd.grainId,ebsd.mis2mean] =  calcGrains(ebsd('indexed'),'FMC',1);
disp('Done!')
% Remove small clusters
disp('Deleting small grain clusters...')
ebsd(grains(grains.grainSize < 3)) = [];
disp('Done!')
% Re-calculate the grains
disp('Re-calculating grains while interpolating zero solutions...')
[grains, ebsd.grainId] = calcGrains(ebsd,'angle',2*degree);
% [grains,ebsd.grainId,ebsd.mis2mean] =  calcGrains(ebsd('indexed'),'FMC',1);
disp('Done!')
% Remove small irregular grains
disp('Deleting irregular grains...')
grains(grains.grainSize < grains.boundarySize / 2) = [];
disp('Done!')




%% STEP 1: Apply the sphericity criterion to the full map
% Calculate sphericity
psi = grains.area ./ grains.perimeter('withInclusion') ./ grains.equivalentRadius;

% Calculate the inflection point of the sphericity cdf
out1 = calcInflection(psi);

% Define a logical array using the inflection point as the critical
% conditionality for segmentation
lA1 = psi >= out1.x(out1.id);

% Segment the unrecrystallised and recrystallised grain subsets
grains_unrcrx = grains(~lA1);
grains_rcrx = grains(lA1);

% Plot the unrecrystallised and recrystallised grain subsets
figH = figure;
plot(grains_unrcrx,psi(~lA1))
setColorRange([min(psi(~lA1)) max(psi(~lA1))])
mtexColorbar jet
set(figH,'Name','Unrecrystallised grain fraction','NumberTitle','on');
% ----
figH = figure;
plot(grains_rcrx,psi(lA1))
setColorRange([min(psi(lA1)) max(psi(lA1))])
mtexColorbar jet
set(figH,'Name','Recrystallised grain fraction','NumberTitle','on');

% Segment the unrecrystallised and recrystallised ebsd subsets
idx = ismember(ebsd.grainId,grains_unrcrx.id);
ebsd_unrcrx = ebsd(idx);
idx = ismember(ebsd.grainId,grains_rcrx.id);
ebsd_rcrx =  ebsd(idx);

% Plot the unrecrystallised and recrystallised ebsd subsets
figH = figure;
plot(ebsd_unrcrx,ebsd_unrcrx.orientations);
set(figH,'Name','Unrecrystallised ebsd fraction','NumberTitle','on');
% ----
figH = figure;
plot(ebsd_rcrx,ebsd_rcrx.orientations);
set(figH,'Name','Recrystallised ebsd fraction','NumberTitle','on');
%%




%% NEW STEP 2: Simultanesouly apply the aspect ratio, shape factor, paris 
% and GOS criteria to the unrecrystallised fraction
aR_unrcrx = aspectRatio(grains_unrcrx);
sF_unrcrx = shapeFactor(grains_unrcrx);
p_unrcrx = paris(grains_unrcrx);
GOS_unrcrx = grains_unrcrx.prop.GOS./degree;

% Calculate the inflection points of the various cdfs
out21 = calcInflection(aR_unrcrx);
out22 = calcInflection(sF_unrcrx);
out23 = calcInflection(p_unrcrx);
out24 = calcInflection(GOS_unrcrx);

% Define logical arrays using the inflection points as the critical
% conditionality for segmentation
lA21 = aR_unrcrx >= out21.x(out21.id);
lA22 = sF_unrcrx >= out22.x(out22.id);
lA23 = p_unrcrx >= out23.x(out23.id);
lA24 = GOS_unrcrx >= out24.x(out24.id);

% Define one array as the conditionality for segmentation
lA2 = lA21 | lA22 & lA23 & lA24;

% Segment the deformed and recovered grain subsets
grains_def = grains_unrcrx(lA2);
grains_rec = grains_unrcrx(~lA2);

% Plot the deformed and recovered grain subsets
figH = figure;
plot(grains_def,grains_def.meanOrientation)
mtexColorbar jet
set(figH,'Name','Deformed grain fraction','NumberTitle','on');
% ----
figH = figure;
plot(grains_rec,grains_rec.meanOrientation)
mtexColorbar jet
set(figH,'Name','Recovered grain fraction','NumberTitle','on');

% Segment the deformed and recovered ebsd subsets
idx = ismember(ebsd.grainId,grains_def.id);
ebsd_def = ebsd(idx);
idx = ismember(ebsd.grainId,grains_rec.id);
ebsd_rec =  ebsd(idx);

% Plot the deformed and recovered ebsd subsets
figH = figure;
plot(ebsd_def,ebsd_def.orientations);
set(figH,'Name','Deformed ebsd fraction','NumberTitle','on');
% ----
figH = figure;
plot(ebsd_rec,ebsd_rec.orientations);
set(figH,'Name','Recovered ebsd fraction','NumberTitle','on');
%%




%% STEP 3: Apply the size criterion to the recrystallised fraction
% Define a variable for the grain size
grainSize_rcrx = grains_rcrx.grainSize;

% Calculate the grain size threshold of the PDF using 3-sigma confidence
% levels
out3 = calcThreshold(grainSize_rcrx,'pdf','sigma',3);

% Define a logical array using the threshold value as the critical
% conditionality for segmentation
lA3 = grainSize_rcrx >= out3.x(out3.id);

% Segment the small (newly nucleated) and large (growing grains) subsets
grains_nuc = grains_rcrx(~lA3);
grains_grow = grains_rcrx(lA3);

% Plot the newly nucleated and growing grain subsets
figH = figure;
plot(grains_nuc,grainSize_rcrx(~lA3))
setColorRange([min(grainSize_rcrx(~lA3)) max(grainSize_rcrx(~lA3))])
mtexColorbar jet
set(figH,'Name','Newly nucleated grain fraction','NumberTitle','on');
% ----
figH = figure;
plot(grains_grow,grainSize_rcrx(lA3))
setColorRange([min(grainSize_rcrx(lA3)) max(grainSize_rcrx(lA3))])
mtexColorbar jet
set(figH,'Name','Growing grain fraction','NumberTitle','on');

% Segment the newly nucleated and growing grain ebsd subsets
idx = ismember(ebsd.grainId,grains_nuc.id);
ebsd_nuc = ebsd(idx);
idx = ismember(ebsd.grainId,grains_grow.id);
ebsd_grow =  ebsd(idx);

% Plot the newly nucleated and growing grain ebsd subsets
figH = figure;
plot(ebsd_nuc,ebsd_nuc.orientations);
set(figH,'Name','Newly nucleated ebsd fraction','NumberTitle','on');
% ----
figH = figure;
plot(ebsd_grow,ebsd_grow.orientations);
set(figH,'Name','Growing grain ebsd fraction','NumberTitle','on');
%%




%% STEP 4: Calculate the area fractions of the various subsets
% Calculate the area fractions
area_total = sum(area(grains));
areaFraction_unrcrx = sum(area(grains_unrcrx)) / area_total;
areaFraction_rcrx = sum(area(grains_rcrx)) / area_total;
areaFraction_def = sum(area(grains_def)) / area_total;
areaFraction_rec = sum(area(grains_rec)) / area_total;
areaFraction_nuc = sum(area(grains_nuc)) / area_total;
areaFraction_grow = sum(area(grains_grow)) / area_total;

% Display the area fractions
disp('====');
disp('Grain area fractions of the subsets:');
disp('====');
disp(['Unrecrystallised = ', num2str(areaFraction_unrcrx)]);
disp(['Recrystallised   = ', num2str(areaFraction_rcrx)]);
disp('----');
disp(['Deformed         = ', num2str(areaFraction_def)]);
disp(['Recovered        = ', num2str(areaFraction_rec)]);
disp(['Newly nucleated  = ', num2str(areaFraction_nuc)]);
disp(['Growing grains   = ', num2str(areaFraction_grow)]);
disp('====');
%%

%% STEP 5: Calculate the grain statistics
% Step 5.1: Calculate the equivalent circle diameter of the various subsets
ecd_unrcrx = 0.816.* 2.* grains_unrcrx.equivalentRadius;
ecd_rcrx = 0.816.* 2.* grains_rcrx.equivalentRadius;
ecd_def = 0.816.* 2.* grains_def.equivalentRadius;
ecd_rec = 0.816.* 2.* grains_rec.equivalentRadius;
ecd_nuc = 0.816.* 2.* grains_nuc.equivalentRadius;
ecd_grow = 0.816.* 2.* grains_grow.equivalentRadius;

% Display the grain equivalent circle diameters of the various subsets
disp('====');
disp('Grain equivalent circle diameters (d_ecd, um) of the subsets:');
disp('====');
disp(['Unrecrystallised = ', num2str(mean(ecd_unrcrx)), ' ± ',num2str(std(ecd_unrcrx))]);
disp(['Recrystallised   = ', num2str(mean(ecd_rcrx)), ' ± ',num2str(std(ecd_rcrx))]);
disp('----');
disp(['Deformed         = ', num2str(mean(ecd_def)), ' ± ',num2str(std(ecd_def))]);
disp(['Recovered        = ', num2str(mean(ecd_rec)), ' ± ',num2str(std(ecd_rec))]);
disp(['Newly nucleated  = ', num2str(mean(ecd_nuc)), ' ± ',num2str(std(ecd_nuc))]);
disp(['Growing grains   = ', num2str(mean(ecd_grow)), ' ± ',num2str(std(ecd_grow))]);
disp('====');
%%

% Step 5.2: Calculate the aspect ratio of the various subsets
% aR_unrcrx = aspectRatio(grains_unrcrx); % calculated previously in Step 2
aR_rcrx = aspectRatio(grains_rcrx);
aR_def = aspectRatio(grains_def);
aR_rec = aspectRatio(grains_rec);
aR_nuc = aspectRatio(grains_nuc);
aR_grow = aspectRatio(grains_grow);

% Display the grain aspect ratio of the various subsets
disp('====');
disp('Grain aspect ratio (λ) of the subsets:');
disp('====');
disp(['Unrecrystallised = ', num2str(mean(aR_unrcrx)), ' ± ',num2str(std(aR_unrcrx))]);
disp(['Recrystallised   = ', num2str(mean(aR_rcrx)), ' ± ',num2str(std(aR_rcrx))]);
disp('----');
disp(['Deformed         = ', num2str(mean(aR_def)), ' ± ',num2str(std(aR_def))]);
disp(['Recovered        = ', num2str(mean(aR_rec)), ' ± ',num2str(std(aR_rec))]);
disp(['Newly nucleated  = ', num2str(mean(aR_nuc)), ' ± ',num2str(std(aR_nuc))]);
disp(['Growing grains   = ', num2str(mean(aR_grow)), ' ± ',num2str(std(aR_grow))]);
disp('====');
%%



%% STEP 6: Calculate the grain boundary fractions of the various subsets
gB_total = grains.boundary;
gB_unrcrx = grains_unrcrx.boundary;
gB_rcrx = grains_rcrx.boundary;
gB_def = grains_def.boundary;
gB_rec = grains_rec.boundary;
gB_nuc = grains_nuc.boundary;
gB_grow = grains_grow.boundary;
%%

% Step 6.1: Calculate the grain boundary area fractions of the various subsets
gBFraction_total = sum(gB_total.segLength);
gBFraction_unrcrx = sum(gB_unrcrx.segLength) / gBFraction_total;
gBFraction_rcrx = sum(gB_rcrx.segLength) / gBFraction_total;
gBFraction_def = sum(gB_def.segLength) / gBFraction_total;
gBFraction_rec = sum(gB_rec.segLength) / gBFraction_total;
gBFraction_nuc = sum(gB_nuc.segLength) / gBFraction_total;
gBFraction_grow = sum(gB_grow.segLength) / gBFraction_total;

% Display the grain boundary area fractions of the various subsets
disp('====');
disp('Grain boundary length fractions of the subsets:');
disp('====');
disp(['Unrecrystallised = ', num2str(gBFraction_unrcrx)]);
disp(['Recrystallised   = ', num2str(gBFraction_rcrx)]);
disp('----');
disp(['Deformed         = ', num2str(gBFraction_def)]);
disp(['Recovered        = ', num2str(gBFraction_rec)]);
disp(['Newly nucleated  = ', num2str(gBFraction_nuc)]);
disp(['Growing grains   = ', num2str(gBFraction_grow)]);
disp('====');
%%

% Step 6.2: Calculate the boundary specific interfacial area per unit
% volume  of the various subsets
Sv_unrcrx = (4/pi()) * sum(gB_unrcrx.segLength) / area_total;
Sv_rcrx = (4/pi()) * sum(gB_rcrx.segLength) / area_total;
Sv_def = (4/pi()) * sum(gB_def.segLength) / area_total;
Sv_rec = (4/pi()) * sum(gB_rec.segLength) / area_total;
Sv_nuc = (4/pi()) * sum(gB_nuc.segLength) / area_total;
Sv_grow = (4/pi()) * sum(gB_grow.segLength) / area_total;

% Display the boundary specific interfacial areas per unit volume  of the 
% various subsets
disp('====');
disp('Grain boundary specific interfacial areas per unit volume (Sv, um^-1) of the subsets:');
disp('====');
disp(['Unrecrystallised = ', num2str(Sv_unrcrx)]);
disp(['Recrystallised   = ', num2str(Sv_rcrx)]);
disp('----');
disp(['Deformed         = ', num2str(Sv_def)]);
disp(['Recovered        = ', num2str(Sv_rec)]);
disp(['Newly nucleated  = ', num2str(Sv_nuc)]);
disp(['Growing grains   = ', num2str(Sv_grow)]);
disp('====');
%%

% Step 6.3: Calculate the misorientation distributions of the various subsets
[~,binCenters,pdf_total] = calcPDF(gB_total.misorientation.angle./degree,'binWidth',1,'min',0,'max',ceil(fR.maxAngle./degree));
[~,~,pdf_unrcrx] = calcPDF(gB_unrcrx.misorientation.angle./degree,'binWidth',1,'min',0,'max',ceil(fR.maxAngle./degree));
[~,~,pdf_rcrx] = calcPDF(gB_rcrx.misorientation.angle./degree,'binWidth',1,'min',0,'max',ceil(fR.maxAngle./degree));
[~,~,pdf_def] = calcPDF(gB_def.misorientation.angle./degree,'binWidth',1,'min',0,'max',ceil(fR.maxAngle./degree));
[~,~,pdf_rec] = calcPDF(gB_rec.misorientation.angle./degree,'binWidth',1,'min',0,'max',ceil(fR.maxAngle./degree));
[~,~,pdf_nuc] = calcPDF(gB_nuc.misorientation.angle./degree,'binWidth',1,'min',0,'max',ceil(fR.maxAngle./degree));
[~,~,pdf_grow] = calcPDF(gB_grow.misorientation.angle./degree,'binWidth',1,'min',0,'max',ceil(fR.maxAngle./degree));

% Calculate the low and high angle boundary fractions of the various subsets
binCenters_LAGB = binCenters(binCenters < criticalAngle);
% ----
pdf_unrcrx_LAGB = pdf_unrcrx(binCenters < criticalAngle);
pdf_rcrx_LAGB = pdf_rcrx(binCenters < criticalAngle);
pdf_def_LAGB = pdf_def(binCenters < criticalAngle);
pdf_rec_LAGB = pdf_rec(binCenters < criticalAngle);
pdf_nuc_LAGB = pdf_nuc(binCenters < criticalAngle);
pdf_grow_LAGB = pdf_grow(binCenters < criticalAngle);
% ----
LAGBFraction_unrcrx = sum(pdf_unrcrx_LAGB) / sum(pdf_unrcrx);
LAGBFraction_rcrx = sum(pdf_rcrx_LAGB) / sum(pdf_rcrx);
LAGBFraction_def = sum(pdf_def_LAGB) / sum(pdf_def);
LAGBFraction_rec = sum(pdf_rec_LAGB) / sum(pdf_rec);
LAGBFraction_nuc = sum(pdf_nuc_LAGB) / sum(pdf_nuc);
LAGBFraction_grow = sum(pdf_grow_LAGB) / sum(pdf_grow);
% ----
pdf_unrcrx_HAGB = pdf_unrcrx(binCenters >= criticalAngle);
pdf_rcrx_HAGB = pdf_rcrx(binCenters >= criticalAngle);
pdf_def_HAGB = pdf_def(binCenters >= criticalAngle);
pdf_rec_HAGB = pdf_rec(binCenters >= criticalAngle);
pdf_nuc_HAGB = pdf_nuc(binCenters >= criticalAngle);
pdf_grow_HAGB = pdf_grow(binCenters >= criticalAngle);
% ----
HAGBFraction_unrcrx = sum(pdf_unrcrx_HAGB) / sum(pdf_unrcrx);
HAGBFraction_rcrx = sum(pdf_rcrx_HAGB) / sum(pdf_rcrx);
HAGBFraction_def = sum(pdf_def_HAGB) / sum(pdf_def);
HAGBFraction_rec = sum(pdf_rec_HAGB) / sum(pdf_rec);
HAGBFraction_nuc = sum(pdf_nuc_HAGB) / sum(pdf_nuc);
HAGBFraction_grow = sum(pdf_grow_HAGB) / sum(pdf_grow);

% Display the low and high angle boundary fractions of the various subsets
disp('====');
disp('Low and high -angle boundary fractions of the subsets:');
disp('====');
disp(['Unrecrystallised = ', num2str(LAGBFraction_unrcrx), ' (LAGB) | ', num2str(HAGBFraction_unrcrx),' (HAGB)']);
disp(['Recrystallised   = ', num2str(LAGBFraction_rcrx), ' (LAGB) | ', num2str(HAGBFraction_rcrx),' (HAGB)']);
disp('----');
disp(['Deformed         = ', num2str(LAGBFraction_def), ' (LAGB) | ', num2str(HAGBFraction_def),' (HAGB)']);
disp(['Recovered        = ', num2str(LAGBFraction_rec), ' (LAGB) | ', num2str(HAGBFraction_rec),' (HAGB)']);
disp(['Newly nucleated  = ', num2str(LAGBFraction_nuc), ' (LAGB) | ', num2str(HAGBFraction_nuc),' (HAGB)']);
disp(['Growing grains   = ', num2str(LAGBFraction_grow), ' (LAGB) | ', num2str(HAGBFraction_grow),' (HAGB)']);
disp('====');
%%

% Step 6.4: Calculate the Read-Shockley equation -based boundary stored 
% energy of the various subsets
storedEnergy = 0.617.* (binCenters./criticalAngle).* (1 - log(binCenters./criticalAngle));
[maxVal,maxIdx] = max(storedEnergy);
storedEnergy(maxIdx+1:end) = maxVal;
% ----
Eb_unrcrx = Sv_unrcrx * sum(storedEnergy.* pdf_unrcrx);
Eb_rcrx = Sv_rcrx * sum(storedEnergy.* pdf_rcrx);
Eb_def = Sv_def * sum(storedEnergy.* pdf_def);
Eb_rec = Sv_rec * sum(storedEnergy.* pdf_rec);
Eb_nuc = Sv_nuc * sum(storedEnergy.* pdf_nuc);
Eb_grow = Sv_grow * sum(storedEnergy.* pdf_grow);

% Display the boundary stored energy as per the Read-Shockley equation of
% the various subsets
disp('====');
disp('Estimated boundary stored energy (Eb, J.m^-3) of the subsets:');
disp('(as per the Read-Shockley equation)')
disp('====');
disp(['Unrecrystallised = ', num2str(Eb_unrcrx)]);
disp(['Recrystallised   = ', num2str(Eb_rcrx)]);
disp('----');
disp(['Deformed         = ', num2str(Eb_def)]);
disp(['Recovered        = ', num2str(Eb_rec)]);
disp(['Newly nucleated  = ', num2str(Eb_nuc)]);
disp(['Growing grains   = ', num2str(Eb_grow)]);
disp('====');
%%

% Step 6.6: Calculate the sub-boundary mobility of the various subsets
% Reference: H. Zurob, Y. Bréchet, J. Dunlop, Quantitative criterion for 
% recrystallization nucleation in single-phase alloys: Prediction of 
% critical strains and incubation times, Acta Materialia, 54(15), 
% p. 3983-3990, 2006.

% Calculate M(theta)
Mtheta = 1 - exp(-5.* (binCenters./ criticalAngle).^4);

% Calculate the average low angle misorientation of the various subsets
avgLAGB_unrcrx = sum((binCenters_LAGB.* pdf_unrcrx_LAGB) ./ sum(pdf_unrcrx_LAGB));
avgLAGB_rcrx = sum((binCenters_LAGB.* pdf_rcrx_LAGB) ./ sum(pdf_rcrx_LAGB));
avgLAGB_def = sum((binCenters_LAGB.* pdf_def_LAGB) ./ sum(pdf_def_LAGB));
avgLAGB_rec = sum((binCenters_LAGB.* pdf_rec_LAGB) ./ sum(pdf_rec_LAGB));
avgLAGB_nuc = sum((binCenters_LAGB.* pdf_nuc_LAGB) ./ sum(pdf_nuc_LAGB));
avgLAGB_grow = sum((binCenters_LAGB.* pdf_grow_LAGB) ./ sum(pdf_grow_LAGB));

% Calculate phi(theta) of the various subsets
phiTheta_unrcrx = (pi()/2).* (binCenters./ avgLAGB_unrcrx).* exp(-(pi()/4).* (binCenters./ avgLAGB_unrcrx).^2);
phiTheta_rcrx = (pi()/2).* (binCenters./ avgLAGB_rcrx).* exp(-(pi()/4).* (binCenters./ avgLAGB_rcrx).^2);
phiTheta_def = (pi()/2).* (binCenters./ avgLAGB_def).* exp(-(pi()/4).* (binCenters./ avgLAGB_def).^2);
phiTheta_rec = (pi()/2).* (binCenters./ avgLAGB_rec).* exp(-(pi()/4).* (binCenters./ avgLAGB_rec).^2);
phiTheta_nuc = (pi()/2).* (binCenters./ avgLAGB_nuc).* exp(-(pi()/4).* (binCenters./ avgLAGB_nuc).^2);
phiTheta_grow = (pi()/2).* (binCenters./ avgLAGB_grow).* exp(-(pi()/4).* (binCenters./ avgLAGB_grow).^2);

% Calculate the boundary mobility of the various subsets
mobility_unrcrx = sum(Mtheta.* phiTheta_unrcrx.* pdf_unrcrx);
mobility_rcrx = sum(Mtheta.* phiTheta_rcrx.* pdf_rcrx);
mobility_def = sum(Mtheta.* phiTheta_def.* pdf_def);
mobility_rec = sum(Mtheta.* phiTheta_rec.* pdf_rec);
mobility_nuc = sum(Mtheta.* phiTheta_nuc.* pdf_nuc);
mobility_grow = sum(Mtheta.* phiTheta_grow.* pdf_grow);

% Display the sub-boundary mobility of the various subsets
disp('====');
disp('Estimated sub-boundary mobility (um.s^-1) of the subsets:');
disp('====');
disp(['Unrecrystallised = ', num2str(mobility_unrcrx)]);
disp(['Recrystallised   = ', num2str(mobility_rcrx)]);
disp('----');
disp(['Deformed         = ', num2str(mobility_def)]);
disp(['Recovered        = ', num2str(mobility_rec)]);
disp(['Newly nucleated  = ', num2str(mobility_nuc)]);
disp(['Growing grains   = ', num2str(mobility_grow)]);
disp('====');
%%




%% STEP 7: Calculate the grain boundary fractions between the various subsets
% Grain boundaries shared between unrecrystallised and recrystallised subsets
[gBIdx,~] = ismember(gB_unrcrx.grainId,gB_rcrx.grainId,'rows');
gB_unrcrx_rcrx = gB_unrcrx(gBIdx);
% ----
% Grain boundaries shared between deformed and recovered subsets
[gBIdx,~] = ismember(gB_def.grainId,gB_rec.grainId,'rows');
gB_def_rec = gB_def(gBIdx);
% ----
% Grain boundaries shared between deformed and newly nucleated subsets
[gBIdx,~] = ismember(gB_def.grainId,gB_nuc.grainId,'rows');
gB_def_nuc = gB_def(gBIdx);
% ----
% Grain boundaries shared between deformed and growing grain subsets
[gBIdx,~] = ismember(gB_def.grainId,gB_grow.grainId,'rows');
gB_def_grow = gB_def(gBIdx);
% ----
% Grain boundaries shared between recovered and newly nucleated subsets
[gBIdx,~] = ismember(gB_rec.grainId,gB_nuc.grainId,'rows');
gB_rec_nuc = gB_rec(gBIdx);
% ----
% Grain boundaries shared between recovered and growing grain subsets
[gBIdx,~] = ismember(gB_rec.grainId,gB_grow.grainId,'rows');
gB_rec_grow = gB_rec(gBIdx);
% ----
% Grain boundaries shared between newly nucleated and growing grain subsets
[gBIdx,~] = ismember(gB_nuc.grainId,gB_grow.grainId,'rows');
gB_nuc_grow = gB_nuc(gBIdx);
%%

% Step 7.1: Calculate the grain boundary area fractions between the various subsets
gBFraction_total = sum(gB_total.segLength);
% ----
gBFraction_unrcrx_rcrx = sum(gB_unrcrx_rcrx.segLength) / gBFraction_total;
gBFraction_def_rec = sum(gB_def_rec.segLength) / gBFraction_total;
gBFraction_def_nuc = sum(gB_def_nuc.segLength) / gBFraction_total;
gBFraction_def_grow = sum(gB_def_grow.segLength) / gBFraction_total;
gBFraction_rec_nuc = sum(gB_rec_nuc.segLength) / gBFraction_total;
gBFraction_rec_grow = sum(gB_rec_grow.segLength) / gBFraction_total;
gBFraction_nuc_grow = sum(gB_nuc_grow.segLength) / gBFraction_total;

% Display the grain boundary area fractions between the various subsets
disp('====');
disp('Grain boundary length fractions between the subsets:');
disp('====');
disp(['Unrecrystallised-recrystallised = ', num2str(gBFraction_unrcrx_rcrx)]);
disp('----');
disp(['Deformed-recovered              = ', num2str(gBFraction_def_rec)]);
disp(['Deformed-newly nucleated        = ', num2str(gBFraction_def_nuc)]);
disp(['Deformed-growing grains         = ', num2str(gBFraction_def_grow)]);
disp('----');
disp(['Recovered-newly nucleated       = ', num2str(gBFraction_rec_nuc)]);
disp(['Recovered-growing grains        = ', num2str(gBFraction_rec_grow)]);
disp('----');
disp(['Newly nucleated-growing grains  = ', num2str(gBFraction_nuc_grow)]);
disp('====');
%%

% Step 7.2: Calculate the boundary specific interfacial area per unit
% volume between the various subsets
Sv_unrcrx_rcrx = (4/pi()) * sum(gB_unrcrx_rcrx.segLength) / area_total;
Sv_def_rec = (4/pi()) * sum(gB_def_rec.segLength) / area_total;
Sv_def_nuc = (4/pi()) * sum(gB_def_nuc.segLength) / area_total;
Sv_def_grow = (4/pi()) * sum(gB_def_grow.segLength) / area_total;
Sv_rec_nuc = (4/pi()) * sum(gB_rec_nuc.segLength) / area_total;
Sv_rec_grow = (4/pi()) * sum(gB_rec_grow.segLength) / area_total;
Sv_nuc_grow = (4/pi()) * sum(gB_nuc_grow.segLength) / area_total;

% Display the boundary specific interfacial areas per unit volume
disp('====');
disp('Grain boundary specific interfacial areas per unit volume (Sv, um^-1) between the subsets:');
disp('====');
disp(['Unrecrystallised-recrystallised = ', num2str(Sv_unrcrx_rcrx)]);
disp('----');
disp(['Deformed-recovered              = ', num2str(Sv_def_rec)]);
disp(['Deformed-newly nucleated        = ', num2str(Sv_def_nuc)]);
disp(['Deformed-growing grains         = ', num2str(Sv_def_grow)]);
disp('----');
disp(['Recovered-newly nucleated       = ', num2str(Sv_rec_nuc)]);
disp(['Recovered-growing grains        = ', num2str(Sv_rec_grow)]);
disp('----');
disp(['Newly nucleated-growing grains  = ', num2str(Sv_nuc_grow)]);
disp('====');
%%

% Step 7.3: Calculate the misorientation distributions between the various subsets
[~,~,pdf_unrcrx_rcrx] = calcPDF(gB_unrcrx_rcrx.misorientation.angle./degree,'binWidth',1,'min',0,'max',ceil(fR.maxAngle./degree));
[~,~,pdf_def_rec] = calcPDF(gB_def_rec.misorientation.angle./degree,'binWidth',1,'min',0,'max',ceil(fR.maxAngle./degree));
[~,~,pdf_def_nuc] = calcPDF(gB_def_nuc.misorientation.angle./degree,'binWidth',1,'min',0,'max',ceil(fR.maxAngle./degree));
[~,~,pdf_def_grow] = calcPDF(gB_def_grow.misorientation.angle./degree,'binWidth',1,'min',0,'max',ceil(fR.maxAngle./degree));
[~,~,pdf_rec_nuc] = calcPDF(gB_rec_nuc.misorientation.angle./degree,'binWidth',1,'min',0,'max',ceil(fR.maxAngle./degree));
[~,~,pdf_rec_grow] = calcPDF(gB_rec_grow.misorientation.angle./degree,'binWidth',1,'min',0,'max',ceil(fR.maxAngle./degree));
[~,~,pdf_nuc_grow] = calcPDF(gB_nuc_grow.misorientation.angle./degree,'binWidth',1,'min',0,'max',ceil(fR.maxAngle./degree));
%%

% Step 7.4: Calculate the Read-Shockley equation -based boundary stored 
% energy between the various subsets
storedEnergy = 0.617.* (binCenters./criticalAngle).* (1 - log(binCenters./criticalAngle));
[maxVal,maxIdx] = max(storedEnergy);
storedEnergy(maxIdx+1:end) = maxVal;
% ----
Eb_unrcrx_rcrx = Sv_unrcrx_rcrx * sum(storedEnergy.* pdf_unrcrx_rcrx);
Eb_def_rec = Sv_def_rec * sum(storedEnergy.* pdf_def_rec);
Eb_def_nuc = Sv_def_nuc * sum(storedEnergy.* pdf_def_nuc);
Eb_def_grow = Sv_def_grow * sum(storedEnergy.* pdf_def_grow);
Eb_rec_nuc = Sv_rec_nuc * sum(storedEnergy.* pdf_rec_nuc);
Eb_rec_grow = Sv_rec_grow * sum(storedEnergy.* pdf_rec_grow);
Eb_nuc_grow = Sv_nuc_grow * sum(storedEnergy.* pdf_nuc_grow);

% Display the boundary stored energy as per the Read-Shockley equation
% between the various subsets
disp('====');
disp('Estimated boundary stored energy (Eb, J.m^-3) between the subsets:');
disp('(as per the Read-Shockley equation)')
disp('====');
disp(['Unrecrystallised-recrystallised = ', num2str(Eb_unrcrx_rcrx)]);
disp('----');
disp(['Deformed-recovered              = ', num2str(Eb_def_rec)]);
disp(['Deformed-newly nucleated        = ', num2str(Eb_def_nuc)]);
disp(['Deformed-growing grains         = ', num2str(Eb_def_grow)]);
disp('----');
disp(['Recovered-newly nucleated       = ', num2str(Eb_rec_nuc)]);
disp(['Recovered-growing grains        = ', num2str(Eb_rec_grow)]);
disp('----');
disp(['Newly nucleated-growing grains  = ', num2str(Eb_nuc_grow)]);
disp('====');
%%



return
%% STEP 8: Calculate the orientation distribution functions of the various subsets
setInterp2Latex;

% Calculate the optimal kernel sizes
psi_def = calcKernel(ebsd_def.orientations,'method','ruleOfThumb');
psi_rec = calcKernel(ebsd_rec.orientations,'method','ruleOfThumb');
psi_nuc = calcKernel(ebsd_nuc.orientations,'method','ruleOfThumb');
psi_grow = calcKernel(ebsd_grow.orientations,'method','ruleOfThumb');

% Calculate the orientation distribution functions
odf_def = calcDensity(ebsd_def.orientations,'de la Vallee Poussin','kernel',psi_def);
odf_rec = calcDensity(ebsd_rec.orientations,'de la Vallee Poussin','kernel',psi_rec);
odf_nuc = calcDensity(ebsd_nuc.orientations,'de la Vallee Poussin','kernel',psi_nuc);
odf_grow = calcDensity(ebsd_grow.orientations,'de la Vallee Poussin','kernel',psi_grow);

% Plot the orientation distribution functions
figH = plotHODF(odf_def,specimenSymmetry('orthorhombic'),'sections',[0 45 90]*degree,'stepSize',5,'colormap',flipud(hot));
set(figH,'Name','ODFs of the deformed fraction','NumberTitle','on');
figH = plotHODF(odf_rec,specimenSymmetry('orthorhombic'),'sections',[0 45 90]*degree,'stepSize',5,'colormap',flipud(gray));
set(figH,'Name','ODFs of the recovered fraction','NumberTitle','on');
figH = plotHODF(odf_nuc,specimenSymmetry('orthorhombic'),'sections',[0 45 90]*degree,'stepSize',5,'colormap',viridis);
set(figH,'Name','ODFs of the newly nucleated fraction','NumberTitle','on');
figH = plotHODF(odf_grow,specimenSymmetry('orthorhombic'),'sections',[0 45 90]*degree,'stepSize',5,'colormap',jet);
set(figH,'Name','ODFs of the growing grains fraction','NumberTitle','on');
%%




%% STEP 9: Calculate the pole figures of the various subsets
% Plot the pole figures
setMTEXpref('xAxisDirection','north');
hpf = {Miller(1,1,0,CS),Miller(2,0,0,CS), Miller(2,1,1,CS)};
figH = plotHPF(odf_def,'poleFigures',hpf,specimenSymmetry('triclinic'),'stepSize',1,'colormap',flipud(hot));
set(figH,'Name','PFs of the deformed fraction','NumberTitle','on');
figH = plotHPF(odf_rec,'poleFigures',hpf,specimenSymmetry('triclinic'),'stepSize',1,'colormap',flipud(gray));
set(figH,'Name','PFs of the recovered fraction','NumberTitle','on');
figH = plotHPF(odf_nuc,'poleFigures',hpf,specimenSymmetry('triclinic'),'stepSize',1,'colormap',viridis);
set(figH,'Name','PFs of the newly nucleated fraction','NumberTitle','on');
figH = plotHPF(odf_grow,'poleFigures',hpf,specimenSymmetry('triclinic'),'stepSize',1,'colormap',jet);
set(figH,'Name','PFs of the growing grains fraction','NumberTitle','on');
setMTEXpref('xAxisDirection','east');

setInterp2Tex;
%%