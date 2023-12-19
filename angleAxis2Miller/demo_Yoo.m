%% Demonstration description:
% This demonstration recreates "Fig 4: Variation of twinning shear with the
% axial ratio for the seven hexagonal metals" shown in the reference:
% MH Yoo, Slip, twinning, and fracture in hexagonal close-packed metals,
% Metallurgical Transactions A, vol 12A, p. 409-418, 1981.

clear all; clear hidden; close all; clc

s = zeros(length(1.4: 0.05: 2),4);
cnt = 1;
for caRatio = 1.4: 0.05: 2
    % Define an hcp crystal system
    CS = crystalSymmetry('6/mmm', [1 1 caRatio], 'X||a', 'Y||b*', 'Z||c*');

    % The twin shear, s, is calculated using formulas in Table 3 of:
    % JW Christian & S Mahajan, Deformation twinning, Progress in Materials
    % Science, vol. 39, pp. 1-157, 1995
    % % For {1 0 1 -2} twins
    s(cnt,1) = abs((caRatio^2 - 3) / (sqrt(3) * caRatio));
    % For {1 1 -2 1} twins
    s(cnt,2) = abs(caRatio^-1);
    % For {1 1 -2 2} twins
    s(cnt,3) = abs(2 * (caRatio^2 - 2)/(3 * caRatio));
    % For {1 0 -1 1} twins
    s(cnt,4) = abs(((4 * caRatio^2) - 9) / (4 * sqrt(3) * caRatio));

    cnt = cnt + 1;
end

figure
for ii = 1:4
    plot((1.4: 0.05: 2)',s(:,ii),'LineWidth',2);
    hold all;
end

% Beryllium lattice parameters:
% a = 2.2858 Å
% c = 3.5843 Å
% c/a ratio = 1.5681
plot([1.5681; 1.5681],[0; 0.7],'--k','lineWidth',2);
text(1.56,0.7,'Be','FontSize',14);


% Titanium lattice parameters:
% a = 2.95 Å
% c = 4.683 Å
% c/a ratio = 1.5875
plot([1.5875; 1.5875],[0; 0.7],'--k','lineWidth',2);
text(1.58,0.7,'Ti','FontSize',14);


% Zirconium lattice parameters:
% a = 3.2276 Å
% c = 5.1516 Å
% c/a ratio = 1.5961
plot([1.5961; 1.5961],[0; 0.7],'--k','lineWidth',2);
text(1.59,0.7,'Zr','FontSize',14);


% Rhenium lattice parameters:
%  a = 2.761 Å
%  c = 4.456 Å
% c/a ratio = 1.6139
plot([1.6139; 1.6139],[0; 0.7],'--k','lineWidth',2);
text(1.61,0.7,'Re','FontSize',14);


% Magnesium lattice parameters:
% a = 3.17
% c = 5.14
% c/a ratio = 1.6215
plot([1.6215; 1.6215],[0; 0.7],'--k','lineWidth',2);
text(1.62,0.7,'Mg','FontSize',14);


% Zinc lattice parameters:
% a = 2.66 Å
% c = 4.95 Å
% c/a ratio = 1.8609
plot([1.8609; 1.8609],[0; 0.7],'--k','lineWidth',2);
text(1.86,0.7,'Zn','FontSize',14);


% Cadmium lattice parameters:
% a = 2.97 Å
% c = 5.61 Å
% c/a ratio = 1.8889
plot([1.8889; 1.8889],[0; 0.7],'--k','lineWidth',2);
text(1.88,0.7,'Cd','FontSize',14);


legend('(10-12)[-1011]',...
    '(11-21)[-1-126]',...
    '(11-22)[11-2-3], (11-2-4)[22-43]',...
    '(10-11)[10-1-2], (10-13)[30-3-2]',...
    'Location','northeast');

xlabel('\gamma = c/a, axial ratio');
ylabel('g, twinning shear');
xlim([1.4 2]);
ylim([0 0.8]);
