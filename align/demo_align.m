%% Map alignment correction
close all; clc; clear all; clear hidden;

%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','intoPlane');


%% ---- USER INPUT ----
% crystal symmetry
CS = {...
    'notIndexed',...
    crystalSymmetry('m-3m', [3.7 3.7 3.7], 'mineral', 'Iron fcc', 'color', [0 0 1]),...
    crystalSymmetry('m-3m', [2.9 2.9 2.9], 'mineral', 'Iron bcc (old)', 'color', [1 0 0]),...
    crystalSymmetry('6/mmm', [2.5 2.5 4.1], 'X||a*', 'Y||b', 'Z||c*', 'mineral', 'Epsilon_Martensite', 'color', [1 1 0])};
% Import the dataset
ebsd = EBSD.load('TKD_18Cr_950C_2h_Def_111g_1.ctf',CS,'interface','ctf',...
    'convertEuler2SpatialReferenceFrame');


ebsd = align(ebsd,'pixels',15);
plot(ebsd,ebsd.bc)
return

ebsd = align(ebsd,'pixels',30);
plot(ebsd,ebsd.bc)


%-----------------
return
gebsd = gridify(ebsd);
currentFolder = pwd;
pfName = [currentFolder,'\alignedMap.ctf']
export_ctf(gebsd,pfName)



if verLessThan('MTEX','5.10.0')
    error('Simulink 4.0 or higher is required.')
end

v = ver("MTEX")


n = 'mtex';
pat = '(?<=[\\/]toolbox[\\/])[^\\/]+';
regexp(which(n), pat, 'match', 'once')