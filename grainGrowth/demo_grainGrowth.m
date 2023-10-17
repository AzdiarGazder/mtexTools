%% Demonstration description:
% This phase-field simulation script demonstrates 2D grain growth using
% the Allen-Cahn equation for non-conserved order parameters based on a
% model developed by:
% D. Fan, L-Q. Chen, Computer simulation of grain growth using a continuum
% field model, Acta Materialia, Volume 45, Issue 2, 1997, Pages 611-622.
% https://www.sciencedirect.com/science/article/pii/S1359645496002005
%
%% User notes:
% This demonstration script only works on maps with square grids.
% Please re-grid maps with hexagonal grids to square grids before using
% this script.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements:
% Dr. Abhinav Roy
% For the original script located at:
% https://github.com/abhinavroy1999/grain-growth-phase-field-code
%
%% Syntax:
%  demo_grainGrowth
%
%% Input:
%  none
%
%% Output:
%  none
%
%% Options:
%  Define simulation parameters in the appropriately marked section below
%%



%% Initialise Mtex
clc; clear all; clear hidden; close all;
startup_mtex;

% %% define Mtex plotting convention as X = right, Y = up
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('FontSize', 14);

%% Load mtex example data
mtexdata twins

%% Calculate teh step size and regrid map data
stepSize = calcStepSize(ebsd);
ebsd = regrid(ebsd,stepSize);

%% Calculate the grains
% identify grains
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',5*degree);
figure;
plot(grains,grains.meanOrientation)

%% Gridify the map data
gebsd = gridify(ebsd);
%%




%% Define the simulation parameters
% --- Do not modify ---
Nx = size(gebsd,2); Ny = size(gebsd,1); dx = stepSize; dy = stepSize;
halfNx = Nx/2; halfNy = Ny/2;
numGrains = length(grains);
startTime = 1;
delkx = 2*pi/(Nx*dx);       % condition for Fourier transformation along the x direction
delky = 2*pi/(Ny*dy);       % condition for Fourier transformation along the y direction
% ---

% --- User modifications allowed ---
endTime = 100;
timeStep = 1;               % time step for model
dt = 0.25;                  % time step for temporal evolution
A = 1E-2;                   % defining the value of A
L = 1E-3;                   % defining the relaxation coefficient
kappa = 1E1;                % defining the non-dimensional variable
% ---
%%




tic
h = figure;

%% Define the initial profile of the order parameters
phi = gebsd.grainId;
eta = zeros(Ny,Nx,numGrains);

%% Define the variables for the derivative of free energy density function
geta = zeros(Ny,Nx,numGrains);

%% Assign the values of order parameters to the grains
for ii = 1:numGrains
    eta(:,:,ii) = phi == ii;
end

for ii = 1:numGrains
    b(:,:,ii) = eta(:,:,ii).*(sum(eta, 3) - sum(eta(:,:,1:ii),3));
end
b = sum(b,3);

%%  Temporal evolution loop
geta = zeros(Ny,Nx,numGrains);
for timeLoop = startTime : endTime

    etaCubed = eta.^3;
    sumEta = sum(eta, 3) - eta;
    geta = -eta + etaCubed + (2.*eta .* sumEta);

    etahat = fft2(eta);

    getahat = fft2(geta);

    %% Evolution equation
    % Generate kx and ky values by implementing the periodic boundary
    % condition for the x and y directions
    kx = (((1:Nx) <= halfNx) .* ((1:Nx) - 1) + ((1:Nx) > halfNx) .* ((1:Nx) - 1 - Nx)) * delkx;
    ky = (((1:Ny) <= halfNy) .* ((1:Ny) - 1) + ((1:Ny) > halfNy) .* ((1:Ny) - 1 - Ny)) * delky;
    [kx, ky] = meshgrid(kx, ky);
    k2 = kx.^2 + ky.^2;
    % Pre-compute the factor
    factor = 2 * L * kappa * dt;
    % Vectorise the operation
    etahat = (etahat - (L * dt * getahat)) ./ (1 + factor * k2);

    eta = real(ifft2(etahat));

    if (rem(timeLoop,timeStep) == 0)
        for ii = 1:numGrains
            b(:,:,ii) = eta(:,:,ii).*(sum(eta,3) - sum(eta(:,:,1:ii),3));
        end
        b = sum(b,3);

        clf(h);
        plot(gebsd,b);

%         mesh(b);
%         view(2);
%         xlim([1 Nx]); ylim([1 Ny]);
%         xticks([]); yticks([]);
%         xticklabels([]); yticklabels([]);
%         box on;
%         ax = gca;
%         ax.LineWidth = 2;

        colorbar; colormap('jet');
        title(sprintf("timeStep = %d", timeLoop));
        drawnow;
%         fileName = sprintf("timeStep_%d.png", timeLoop);
%         print(fileName, '-dpng', '-r256');
    end
end
toc
hold off;
disp('Done!');
