function outMori = angleAxis2Miller(inMori,varargin)
%% Function description:
% This function uses twin misorientations defined by their angle-axis 
% convention as input. It returns four Miller indices such that: the first 
% Miller index maps onto the second, and the third Miller index maps onto 
% the fourth. Here the first and second Miller indices correspond to K1 
% and K2, respectively whereas the third and fourth Miller indices 
% correspond to eta1 and eta2, respectively.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
% 
%% Syntax:
%  angleAxis2Miller(mori)
%
%% Input:
%  mori          - @orientation
%
%% Options:
%  mori         - @orientation
%%

if ~isa(inMori,'orientation')
    error('Input must be a misorientation of class ''orientation''');
end

outMori = inMori;

for ii = 1:length(outMori)

    % Calculate the closest rational parallel planes and directions
    [outMori.opt.K1(ii),...
        outMori.opt.K2(ii),...
        outMori.opt.eta1(ii),...
        outMori.opt.eta2(ii)] = round2Miller(inMori(ii));%,'maxIndex',15);

    % Return the mori based on the calculated closest rational parallel
    % planes and directions
    calcMori = orientation.map(outMori.opt.K1(ii),...
        outMori.opt.K2(ii),...
        outMori.opt.eta1(ii),...
        outMori.opt.eta2(ii));
    % Calculate the error between the input and calculated moris
    err = angle(inMori(ii),calcMori);

    % Display the output
    disp(' ');
    n1 = char(outMori.opt.K1(ii),'cell'); ln1 = max(cellfun(@length,n1));
    n2 = char(outMori.opt.K2(ii),'cell'); ln2 = max(cellfun(@length,n2));
    d1 = char(outMori.opt.eta1(ii),'cell'); ld1 = max(cellfun(@length,d1));
    d2 = char(outMori.opt.eta2(ii),'cell'); ld2 = max(cellfun(@length,n2));

    disp([fillStr('plane parallel',ln1+ln2+4,'left') '   ' ...
        fillStr('direction parallel',ld1+ld2+6) '   fit']);
    for kk = 1:length(n1)
        disp([fillStr(n1{kk},ln1,'left') ' || ' fillStr(n2{kk},ln2) '   ' ...
            fillStr(d1{kk},ld1,'left') ' || ' fillStr(d2{kk},ld2) '   ' ...
            '  ',xnum2str(err(kk)./degree,'precision',0.1),mtexdegchar']);
    end

    disp(' ');

    disp(['Misorientation angle  = ', num2str(angle(calcMori)/degree)])
    ax = char(char(round(axis(calcMori)),'cell'));
    disp(['Misorientation axis   = ',ax]);
    disp('----')
end
