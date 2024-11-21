close all; clc; clear all; clear hidden;
startup_mtex

%% Call the calcScreenSize function

% Returns the screen sizes in all units.
% By default, this includes the height/width of the taskbar
c1 = calcScreenSize()

% Returns the screen sizes in scaled pixel units
% By default, this includes the height/width of the taskbar
c2 = calcScreenSize('unit','scaled')

% Returns the screen sizes in centimeter units by excluding height/width 
% of the taskbar
c3 = calcScreenSize('unit','centimeters','type', 'exclude')

% Returns the screen sizes in all units by excluding height/width 
% of the taskbar
c4 = calcScreenSize('type', 'exclude')