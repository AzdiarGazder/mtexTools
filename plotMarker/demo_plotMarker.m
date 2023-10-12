clear all; close all;

% Create some random data
xData = sort(rand(20,3)*50);
yData = rand(20,3)*50;

%% Call the plotMarker function
% Note: Run each section sequentially


%% Single column X and Y data
% plotMarker(xData,yData,...
% 'lineStyle', '--', 'lineColor', [1 0 0], 'lineWidth',2,...
% 'marker','e',...
% 'innerMarker',...
% 'markerEdgeColor',[0 0 0],...
% 'markerFaceColor',[0 1 1],...
% 'markerSize',5);

% plotMarker(xData,yData,...
% 'lineStyle', '-.', 'lineColor', [1 0 1], 'lineWidth',2,...
% 'marker','^',...
% 'markerStep',180*degree,...
% 'markerEdgeColor',[0 0 1],...
% 'markerFaceColor',[0.5 0.75 0.25],...
% 'markerSize',3);
%%



%% Multi-column X & Y data 
% Create some random data
xData = sort(rand(20,3)*50);
yData = randi([-10  10],[20,3]);

lStyle = {'-','-.','--'};
lColor = [1 0 0;...
    0 1 0;...
    0 0 1];
lWidth = [1.5 2 2.25];

mType = {'c','e','s'};
mStep = [0 90 45].*degree;
mEC = [0 0 0];
    mFC = [1 0 0;...
    0 1 0;...
    0 0 1];
mSize = [5 2 2];

for ii = 1:size(xData,2)
    plotMarker(xData(:,ii),yData(:,ii),...
        'lineStyle', lStyle{ii}, 'lineColor', lColor(:,ii), 'lineWidth',lWidth(ii),...
        'marker',mType{ii},...
        'markerStep',mStep(ii),...
        'markerEdgeColor',mEC,...
        'markerFaceColor',mFC(:,ii),...
        'markerSize',mSize(ii));
    hold all;
end
xlim([0 ceil(max(xData,[],'all')/10)*10]);
ylim([-15 15]);
hold off;
%%

