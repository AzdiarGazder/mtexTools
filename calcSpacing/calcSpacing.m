function d = calcSpacing(m,varargin)
%% Function description:
% This function calculates the interplanar spacing for a given set of
% Miller indices specifying the lattice plane. The Bravis lattice of the
% Miller indices is automatically identified.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%
%% Syntax:
%  calcSpacing(m)
%
%% Input:
%  ori          - @miller
%
%% Output:
% d             - @double, the interplanar spacing
%
%% Options:
%
%%

if ~isa(m,'Miller')
    error('Input variable must be of @Miller type.');
end

list = spaceGroups;
[ro,~] = find(strcmp(list,m.CS.pointGroup));
spaceId = list{ro,1};

a = m.CS.axes.x(1);
b = m.CS.axes.y(2);
c = m.CS.axes.z(3);

alpha = m.CS.alpha;
beta = m.CS.beta;
gamma = m.CS.gamma;

% % Reference: https://en.wikipedia.org/wiki/Crystal_structure
if spaceId >= 1 && spaceId <= 2          % triclinic
    d = sqrt(1 / ((((m.h^2 / a^2) * (sin(alpha))^2) +...
        ((m.k^2 / b^2) * (sin(beta))^2) +...
        ((m.l^2 / c^2) * (sin(gamma))^2) +...
        (((2 * m.k * m.l) / ( b * c)) * ((cos(beta)*cos(gamma)) - cos(alpha))) +...
        (((2 * m.h * m.l) / ( a * c)) * ((cos(gamma)*cos(alpha)) - cos(beta))) +...
        (((2 * m.h * m.k) / ( a * b)) * ((cos(alpha)*cos(beta)) - cos(gamma)))) /...
        (1 - (cos(alpha))^2 - (cos(beta))^2 - (cos(gamma))^2 + (2 * cos(alpha) * cos(beta) * cos(gamma)))));

elseif spaceId >= 3 && spaceId <= 15     % monoclinic
    d = sqrt(1 / (((m.h^2 / a^2) +...
        ((m.k^2 * (sin(beta))^2) / b^2) +...
        (m.l^2 / c^2) -...
        ((2*m.h*m.l*cos(beta)) /...
        (a*c))) * (csc(beta))^2));

elseif spaceId >= 16 && spaceId <= 74    % orthorhombic
    d = sqrt(1 / ((m.h^2 / a^2) +...
        (m.k^2 / b^2) +...
        (m.l^2 / c^2)));

elseif spaceId >= 75 && spaceId <= 142   % tetragonal
    d = sqrt(1 / (((m.h^2 + m.k^2) / a^2) +...
        (m.l^2 / c^2)));

elseif spaceId >= 143 && spaceId <= 167  % trigonal (rhombohedral)
    d = sqrt(1 / (((m.h^2 + m.k^2 + m.l^2) * (sin(alpha))^2) +...
        (2 * ((m.h * m.k) + (m.k * m.l) + (m.h * m.l))*((cos(alpha))^2 - cos(alpha))) /...
        (a^2 * (1 - (3*(cos(alpha))^2) + (2*(cos(alpha))^3)))));

elseif spaceId >= 168 && spaceId <= 194  % hexagonal
    d = sqrt(1 / (((4/3) * ((m.h^2 + m.h*m.k + m.k^2) / a^2)) +...
        (m.l^2 / c^2)));

elseif spaceId >= 195 && spaceId <= 230  % cubic
    d = sqrt(1 / ((m.h^2 + m.k^2 + m.l^2) / a^2));
end

end


%% Space groups list
function list = spaceGroups
list = {...
    1,    '1';
    2,    '-1';
    5,    '2';
    9,    'm';
    15,   '2/m';
    24,   '222';
    46,   'mm2';
    74,   'mmm';
    80,   '4';
    82,   '-4';
    88,   '4/m';
    98,   '422';
    110,  '4mm';
    122,  '-42m';
    142,  '4/mmm';
    146,  '3';
    148,  '-3';
    155,  '32';
    161,  '3m';
    167,  '-3m';
    173,  '6';
    174,  '-6';
    176,  '6/m';
    182,  '622';
    186,  '6mm';
    190,  '-6m2';
    194,  '6/mmm';
    199,  '23';
    206,  'm-3';
    214,  '432';
    220,  '-43m';
    230,  'm-3m'};
end
%%

