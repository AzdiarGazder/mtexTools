function stressStates = calcBHStressStates(sS,varargin)
%% Function description:
% This function calculates the Bishop-Hill stress states based on the user
% defined slip system.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
% Dr. Manasij Kumar Yadava, 2023, atiitkdotacdotin
%
%% Acknowledgements:
% Dr. Manasij Kumar Yadava
% For developing the original script located at:
% https://github.com/manasijy/Yield_locus_programs
%
%% Syntax:
%  calcBHStressStates(sS)
%
%% Input:
%  none
%
%% Output:
% A structure array containing the cell list of stress states and active
% slip system(s).
%
%% Options:
%  none
%
%%

% Check for symmetrised slip system(s)
% Forward slip systems must form the top half and the backward slip 
% systems must form the bottom half of the symmetrised slip system list
isSymmetrised = sum(eq(sS(1),sS)) > 1;
if ~isSymmetrised
    warning(sprintf('\nSymmetrised and ordered slip system(s) required.'));
    sS = sS.symmetrise('antipodal');
    sS = [sS; -sS];
end

% Define the number of constraints
constraints = get_option(varargin, 'constraints', 5); 

% Check if file requires saving
saveFile = check_option(varargin, 'save');
% Check if the user has specified a file name
if saveFile
    fileName = get_option(varargin, 'save', 'bishopHill_stressStates.txt');
end



disp('Calculating Bishop-Hill stress states...')
tic
R = linspace(-1, 1, constraints);  % define **EQUALLY** spaced R-values

[A, B, C, F, G, H] = ndgrid(R, R, R, R, R, R); % define a matrix of all possible combinations
% where the stress states
% A = (sigma(2,2) - sigma(3,3)) / sqrt(6*tau);
% B = (sigma(3,3) - sigma(1,1)) / sqrt(6*tau);
% C = (sigma(1,1) - sigma(2,2)) / sqrt(6*tau);
% F = sigma(2,3) / sqrt(6*tau);
% G = sigma(3,1) / sqrt(6*tau);
% H = sigma(1,2) / sqrt(6*tau);


% activity(:,num) decides slip system (sS) activity.
% The comment at the end of each line describes the
% sS notation in Hosford's convention
activity = zeros(length(A(:)), 1);
activity(:,1) =  -(A(:) - G(:) + H(:));  % -a1
activity(:,2) =   (B(:) + F(:) - H(:));  %  a2
activity(:,3) =  -(C(:) - F(:) + G(:));  % -a3
activity(:,4) =   (C(:) - F(:) - G(:));  % -c3
activity(:,5) =   (B(:) + F(:) + H(:));  %  c2
activity(:,6) =  -(A(:) + G(:) - H(:));  % -c1
activity(:,7) =   (C(:) + F(:) + G(:));  %  d3
activity(:,8) =   (B(:) - F(:) + H(:));  %  d2
activity(:,9) =  -(A(:) - G(:) - H(:));  % -d1
activity(:,10) = -(C(:) + F(:) - G(:));  % -b3
activity(:,11) = -(B(:) - F(:) - H(:));  % -b2
activity(:,12) =  (A(:) + G(:) + H(:));  %  b1

allCombinations = [A(:), B(:), C(:), F(:), G(:), H(:), activity];

% A valid condition is defined as:
% (A + B + C == 0) &&
% (all(abs(a) <= 1) && 
% (sum(abs(a) == 1) >= constraints))
validCombinations = allCombinations((sum(allCombinations(:, 1:3), 2) == 0) &...
    (all(abs(allCombinations(:,7:end)) <= 1, 2)) &...
    (sum(abs(allCombinations(:,7:end)) == 1, 2) >= constraints), :);
validCombinations = sortrows(validCombinations,1:size(validCombinations,2)); % defines the order as per the original script

% Define an empty structure variable
stressStates = struct();
for tt = 1:size(validCombinations,1)
        stressStates.A(tt) = validCombinations(tt,1);
        stressStates.B(tt) = validCombinations(tt,2);
        stressStates.C(tt) = validCombinations(tt,3);
        stressStates.F(tt) = validCombinations(tt,4);
        stressStates.G(tt) = validCombinations(tt,5);
        stressStates.H(tt) = validCombinations(tt,6);

        stressStates.SS1(tt) = validCombinations(tt,7);
        stressStates.SS2(tt) = validCombinations(tt,8);
        stressStates.SS3(tt) = validCombinations(tt,9);
        stressStates.SS4(tt) = validCombinations(tt,10);
        stressStates.SS5(tt) = validCombinations(tt,11);
        stressStates.SS6(tt) = validCombinations(tt,12);
        stressStates.SS7(tt) = validCombinations(tt,13);
        stressStates.SS8(tt) = validCombinations(tt,14);
        stressStates.SS9(tt) = validCombinations(tt,15);
        stressStates.SS10(tt) = validCombinations(tt,16);
        stressStates.SS11(tt) = validCombinations(tt,17);
        stressStates.SS12(tt) = validCombinations(tt,18);

        sSactive_forward = sS(validCombinations(tt,7:end) == 1); % specifies the list of forward active slip systems
        sSactive_backward = sS(validCombinations(tt,7:end) == -1 + (length(sS) / 2)); % specifies the list of backward active slip systems
        stressStates.sSactive{tt} = [sSactive_forward, sSactive_backward];
end
disp('Done!')
toc


% Save values to text file
if saveFile
    disp('Writing Bishop-Hill stress states to a *.txt file....')
    tic
    fid = fopen(fileName,'w');
    % Define a header
    fprintf(fid,' No A    B    C    F    G    H    SS1  SS2  SS3  SS4  SS5  SS6  SS7  SS8  SS9  SS10 SS11 SS12 \n\n');

    % Write values line-wise to file
    for ii = 1:length(stressStates.A)
        temp(ii,:) = [ii, stressStates.A(ii),    stressStates.B(ii),    stressStates.C(ii),...
            stressStates.F(ii),    stressStates.G(ii),    stressStates.H(ii),...
            stressStates.SS1(ii),  stressStates.SS2(ii),  stressStates.SS3(ii),...
            stressStates.SS4(ii),  stressStates.SS5(ii),  stressStates.SS6(ii),...
            stressStates.SS7(ii),  stressStates.SS8(ii),  stressStates.SS9(ii),...
            stressStates.SS10(ii), stressStates.SS11(ii), stressStates.SS12(ii)];

        fprintf(fid,[' %2d %+3.1f %+3.1f %+3.1f ' ...
            '%+3.1f %+3.1f %+3.1f ' ...
            '%+3.1f %+3.1f %+3.1f ' ...
            '%+3.1f %+3.1f %+3.1f ' ...
            '%+3.1f %+3.1f %+3.1f ' ...
            '%+3.1f %+3.1f %+3.1f \n'],...
            temp(ii,1),  temp(ii,2),  temp(ii,3),  temp(ii,4),  ...
            temp(ii,5),  temp(ii,6),  temp(ii,7),...
            temp(ii,8),  temp(ii,9),  temp(ii,10),...
            temp(ii,11), temp(ii,12), temp(ii,13),...
            temp(ii,14), temp(ii,15), temp(ii,16),...
            temp(ii,17), temp(ii,18), temp(ii,19));
    end
    fclose(fid);
    disp('Done!')
    toc
end

end
