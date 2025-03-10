%% Clear workspace
close all; clc; clear all; clear hidden;


%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','intoPlane');
setMTEXpref('maxSO3Bandwidth',96);


%% Import the dataset
disp('Importing the ebsd dataset...');
% fName = '80CR_850C_625C_192h_1.ctf';
% fName = 'SS316L_recycledPowder_2.ctf';
ebsd = EBSD.load(fName,'interface','ctf',...
    'convertEuler2SpatialReferenceFrame');

% % Rename the phases
% ebsd.CSList{2}.mineral = 'fcc';
% ebsd.CSList{3}.mineral = 'bcc';
% ebsd.CSList{4}.mineral = 'hcp';
% ebsd.CSList{5}.mineral = 'sigma';
% ebsd.CSList{6}.mineral = 'CoFeV';

% Plot the ebsd phase map with the jitter error
figH = figure;
plot(ebsd);
set(figH,'Name','Phase map: With jitter error (Uncorrected)','NumberTitle','on');

% Plot the band contrast map with the jitter error
figH = figure;
plot(ebsd,ebsd.bc);
colormap(gray);
set(figH,'Name','Band contrast map: With jitter error (Uncorrected)','NumberTitle','on');

% Plot the band slope map with the jitter error
figH = figure;
plot(ebsd,ebsd.bs);
colormap(parula);
set(figH,'Name','Band slope map: With jitter error (Uncorrected)','NumberTitle','on');

drawnow;
disp('Done!');
disp('-----');
%%


%% Jitter correct the ebsd map
tic
ebsd = jitterCorrect(ebsd,'angle',0.5*degree);
toc

% Plot the ebsd phase map without jitter error
figH = figure;
plot(ebsd);
set(figH,'Name','Phase map: Without jitter error (Corrected)','NumberTitle','on');

% Plot the band contrast map without the jitter error
figH = figure;
plot(ebsd,ebsd.bc);
colormap(gray);
set(figH,'Name','Band contrast map: Without jitter error (Corrected)','NumberTitle','on');

% Plot the band slope map without the jitter error
figH = figure;
plot(ebsd,ebsd.bs);
colormap(parula);
set(figH,'Name','Band slope map: With jitter error (Corrected)','NumberTitle','on');
%%


%% Save a new *.ctf file
disp('Saving the corrected ebsd dataset...');
gebsd = gridify(ebsd);
currentFolder = pwd;
fName = [fName(1:end-4),'_jC.ctf'];
pfName = [currentFolder,'\',fName];
export_ctf(gebsd,pfName);
disp('-----');
%%


%% Next steps:
% - Import the outputted map in Channel-5
% - Fill-in the zero solutions (not indexed) 
% - Export a new *.ctf map from Channel-5
%%
