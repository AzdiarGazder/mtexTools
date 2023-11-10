function out = randomEuler(n,varargin)
%% Function description:
% Generate uniformly distributed random Euler angles (φ1, φ, φ2) in the
% form of orientations, quaternions or rotation matrices.
%
%% USER NOTES:
% This function mimics Python's "scipy.stats.special_ortho_group" for 
% generating a random SO(3) matrix.

%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements:
% Dr. Dorian Depriester
% For the original Python -based "RandomEuler" function at:
% https://github.com/DorianDepriester/random_euler
%
%% Syntax:
% randomEuler(n,varargin)
%
%% Input:
% n         - @double, defiens the number of uniformly distributed random
%             Euler angles to output
%
%% Options:
% seed      - @orientation, @quaternion, or @double of size 3 x 3, a set
%             of Euler angles (defined as an orientation, quaternion or
%             rotation matrix) around which a specified number of
%             uniformly distributed random Euler angles are outputted
%
% deviation - @double, defines the angular deviation around the seed
%             Euler angles within which uniformly distributed random Euler
%             angles are outputted; default = 5*degrees
%
%%


if nargin < 1
    n = 1;
    varargin{1} = 'orientation';

elseif nargin == 1 && ~isa(n,'double')
    if isa(n,'char')
        varargin{1} = n;
    elseif isa(n,'string')
        varargin{1} = char(n);
    end
    n = 1;

end

seed = get_option(varargin, {'orientation','quaternion','rotationMatrix'}, []);
maxDev = get_option(varargin,'deviation', 5*degree);


if isa(seed,'orientation')
    seedOri = euler2mat(seed.phi1, seed.Phi, seed.phi2);
    phi1 = zeros(n,1); Phi = zeros(n,1); phi2 = zeros(n,1);
    % Generate n random orientations
    for ii = 1:n
        tempOutput = perturbOrientation(seedOri, maxDev, varargin{:});
        [phi1(ii,1), Phi(ii,1), phi2(ii,1)] = mat2euler(tempOutput);
    end
    out = orientation.byEuler([phi1(:), Phi(:), phi2(:)], seed.CS);


elseif isa(seed,'quaternion')
    eul = quat2eul([seed.a, seed.b, seed.c, seed.d]);
    seedOri = euler2mat(eul(1), eul(2), eul(3));
    phi1 = zeros(n,1); Phi = zeros(n,1); phi2 = zeros(n,1);
    % Generate n random orientations
    for ii = 1:n
        tempOutput = perturbOrientation(seedOri, maxDev, varargin{:});
        [phi1(ii,1), Phi(ii,1), phi2(ii,1)] = mat2euler(tempOutput);
    end
    out = eul2quat([phi1(:), Phi(:), phi2(:)]);


elseif isempty(seed)
    phi1 = zeros(n,1); Phi = zeros(n,1); phi2 = zeros(n,1);
    % Generate n random orientations
    for ii = 1:n
        tempOutput = perturbOrientation(seed, maxDev, varargin{:});
        [phi1(ii,1), Phi(ii,1), phi2(ii,1)] = mat2euler(tempOutput);
    end
    out = [phi1(:), Phi(:), phi2(:)];


elseif isequal(size(seed), [3, 3]) % rotationMatrix
    seedOri = seed;
    % Generate n random orientations
    for ii = 1:n
        out(:,:,ii) = perturbOrientation(seedOri, maxDev, varargin{:});
    end

else
    error('The seed orientation was not defined correctly. seed = @orientation, @quaternion, or @double of size 3 x 3.');

end


% ensure output when no seed is specified for the orientation, quaternion and rotation
% matrices cases
if isempty(seed) && any(contains(varargin,'orientation'))
    warning('No seed orientation specified. Uniformly distributed random Euler angle(s) (φ1, φ, φ2) will be returned.')

elseif isempty(seed) && any(contains(varargin,'quaternion'))
    warning('No seed quaternion specified. Uniformly distributed quaternion(s) (a, b, c, d) will be returned.')
    out = eul2quat([out(:,1), out(:,2), out(:,3)]);

elseif isempty(seed) && any(contains(varargin,'rotationMatrix'))
    warning('No seed rotation matrix specified. Uniformly distributed rotation matrix(ces) will be returned.')
    temp = out; out = zeros(3,3,size(temp,1));
    for ii = 1:size(temp,1)
        out(:,:,ii) =  euler2mat(temp(ii,1), temp(ii,2), temp(ii,3));
    end

end

end


%%
function outRotMat = perturbOrientation(inRotMat, maxDev, varargin)

% Options for randomRotation
dim = get_option(varargin,'dim',3);
size = get_option(varargin,'size',1);
randomState = get_option(varargin,'randomState',[]);
checkFinite = get_option(varargin,'checkFinite',true);
dType = get_option(varargin,'dType','double');
unpack = get_option(varargin,'unpack',false);

if isempty(randomState)
    stream = RandStream.create('mrg32k3a', 'Seed', 'shuffle');
elseif isnumeric(randomState)
    stream = RandStream.create('mrg32k3a', 'Seed', randomState);
else
    stream = randomState;
end

RandStream.setGlobalStream(stream);

M = zeros(dim, dim, size);

for ii = 1:size
    [U, ~, V] = svd(randn(dim));
    M(:, :, ii) = U * V';
end

if strcmp(dType, 'single')
    M = single(M);
end

if ~checkFinite
    M(isinf(M) | isnan(M)) = NaN;
end

if unpack
    M = mat2cell(M, dim, dim, ones(1, size));
end

% Options for perturbOrientation
if isempty(inRotMat)
    inRotMat = eye(dim);
end

[U, ~, V] = svd(randn(dim));
perturbation = U * V';
perturbation = maxDev * perturbation / norm(perturbation, 'fro');

% Ensure perturbation is skew-symmetric
perturbation = 0.5 * (perturbation - perturbation.');

pertMat = inRotMat * expm(perturbation);

outRotMat = pertMat;
end
%%



%%
function M = euler2mat(phi1, Phi, phi2)
R_phi1 = [cos(phi1), sin(phi1), 0;...
    -sin(phi1), cos(phi1), 0;...
    0,         0,         1];

R_Phi = [1,  0,        0;...
    0,  cos(Phi), sin(Phi);...
    0, -sin(Phi), cos(Phi)];

R_phi2 = [cos(phi2), sin(phi2), 0;...
    -sin(phi2), cos(phi2), 0;...
    0,         0,         1];

M = R_phi2 * R_Phi * R_phi1;
end
%%



%%
function [phi1, Phi, phi2] = mat2euler(M)

Phi = acos(M(3,3));

if Phi == 0
    phi1 = atan2(-M(2,1), M(1,1));
    phi2 = 0;
elseif Phi == pi
    phi1 = atan2(M(2,1), M(1,1));
    phi2 = 0;
else
    phi1 = atan2(M(3,1), -M(3,2));
    phi2 = atan2(M(1,3), M(2,3));
end

if phi1 < 0
    phi1 = phi1 + 2*pi;
end

if phi2 < 0
    phi2 = phi2 + 2*pi;
end
end
%%