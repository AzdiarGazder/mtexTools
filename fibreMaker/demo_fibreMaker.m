close all; clc; clear all; clear hidden;
startup_mtex

%% -----------------
% NOTES TO USERS
% % List of common fibers for fcc materials:
% % alpha             -fibre = <1 1 0> || ND
% % beta              -fibre = <1 1 0> tilted 60° from ND towards TD
% % gamma             -fibre = <1 1 1> || ND
% % tau               -fibre = <1 1 0> || TD
% % REF: https://doi.org/10.1016/j.actamat.2011.05.050
% % theta-fibre = <001> || ND


% List of common fibers for bcc materials:
% % alpha             -fibre = <1 1 0> || RD
% % eta               -fibre = <1 0 0> || RD
% % epsilon           -fibre = <1 1 0> || TD
% % gamma             -fibre = <1 1 1> || ND
% % gammaPrime        -fibre = <2 2 3> || ND
% % theta             -fibre = <1 0 0> || ND
% % zeta              -fibre = <1 1 0> || ND
% % {h 1 1} <1/h 1 2> -fibre
% % REF:  https://doi.org/10.1002/adem.201000075
% %  Notes: This fibre can be simplified as a nominal bcc alpha-fibre
% % whose <110> is tilted 20° from RD towards ND


% List of common fibres for hcp materials:
% % <0 0 0 1>         -fibre = <0 0 0 1>  || ND
% % <1 1 -2 0>        -fibre = <1 1 -2 0> || RD
% % <1 0 -1 0>        -fibre = <1 0 -1 0> || ND
% % hkil              -fibre = <0 0 0 1> tilted 20° from ND towards RD
%% ---------

% step 1: The definition of the commmon fibres listed above is based on the
% following fixed specimen coordinate system of sample directions
% parallel to the crystallographic directions:
RD = xvector; TD = yvector; ND = zvector;



%% UN-REMARK EACH SECTION AND RUN SEPARATELY
% % %-----------------
% % Example 1: Calculate the fcc beta fibre
% %
% % This fibre can be simplified as <110> directions tilted 60° from ND
% % towards TD
% %
% % Step 2: Define a nominal fcc crystal system
% CS = crystalSymmetry('SpaceId', 225, [3.6 3.6 3.6], [90 90 90]*degree, 'mineral', 'copper');
% % Step 3: Define a crystallographic direction
% cD = Miller({1,1,0},CS,'uvw');
% % Step 4: Define a sample direction tilted 60° from ND towards TD
% rotN = rotation('Euler',90*degree,60*degree,0*degree);
% sD = rotN * ND;
% % Step 5: Define the sample symmetry
% sS = specimenSymmetry('orthorhombic');
% % Step 6: Define a half-width
% hwidth = 5*degree;
% % Step 7: Define a file name
% pfName = 'fcc_beta.txt';
% % Step 8: Call the fibreMaker function
% fibreMaker(cD,sD,sS,'halfwidth',hwidth,'export',pfName)
% % %-----------------



% %-----------------
% Example 2: Calculate the bcc {h 1 1} <1/h 1 2> fibre
%
% This fibre can be simplified as a nominal bcc alpha -fibre
% whose <110> is tilted 20° from RD towards ND
%
% Step 2: Define a nominal bcc crystal system
CS = crystalSymmetry('SpaceId', 229, [2.86 2.86 2.86], [90 90 90]*degree, 'mineral', 'iron');
% Step 3: Define a crystallographic direction
cD = Miller({1,1,1},CS,'uvw');
% cD = Miller({1,1,0},CS,'uvw');
% Step 4: Define a tilt away a specimen co-ordinate system direction
% rotN = rotation('Euler',-20*degree,0*degree,0*degree);
% sD = rotN * RD;
sD = ND;
% Step 5: Define the sample symmetry
sS = specimenSymmetry('orthorhombic');
% Step 6: Define a half-width
hwidth = 5*degree;
% Step 7: Define a file name
% pfName = 'bcc_h11_1byh12.txt';
pfName = 'bcc_gammaFibre.txt';
% Step 8: Call the fibreMaker function
fibreMaker(cD,sD,sS,'halfwidth',hwidth,'export',pfName)
% %-----------------
%%





%% DO NOT EDIT/MODIFY BELOW THIS LINE
setInterp2Latex;

% Check for MTEX version
currentVersion = 5.9;
fid = fopen('VERSION','r');
MTEXversion = fgetl(fid);
fclose(fid);
MTEXversion = str2double(MTEXversion(5:end-2));

if MTEXversion >= currentVersion % for MTEX versions 5.9.0 and above
    %--- Load the texture file as an ODF
    odf = SO3Fun.load(pfName,'CS',CS,'resolution',hwidth,'Bunge',...
        'ColumnNames',{'Euler 1','Euler 2','Euler 3','weights'});

else % for MTEX versions 5.8.2 and below
    % Load the texture file as discrete orientations
    [ori,~] = orientation.load(pfName,CS,sS,'interface','generic',...
        'ColumnNames', {'phi1' 'Phi' 'phi2'}, 'Columns', [1 2 3], 'Bunge');
    ori = ori(:);
    % Calculate the orientation distribution function and define the specimen symmetry of the parent
    odf = calcDensity(ori,'halfwidth',hwidth,'points','all');
end
% [maxodf_value,~] = max(odf);
% odf = odf.*(100/maxodf_value); % scale ODF to maximum f(g) = 100

% Plot the pole figures
% hpf = {Miller(1,1,1,odf.CS),Miller(2,0,0,odf.CS), Miller(2,2,0,odf.CS)};
hpf = {Miller(1,1,0,odf.CS),Miller(2,0,0,odf.CS), Miller(2,1,1,odf.CS)};
plotHPF(odf,hpf,specimenSymmetry('triclinic'),'stepSize',50,'colormap',jet);

% Plot the orientation distribution function
plotHODF(odf,specimenSymmetry('orthorhombic'),'sections',[0 45 90]*degree,'stepSize',250,'colormap',jet);

setInterp2Tex;
%%