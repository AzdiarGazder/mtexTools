close all; clc; clear all; clear hidden;

%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('FontSize',14);
set(0,'DefaultFigureWindowStyle','normal');

% create x and y data
x = linspace(-2*pi,2*pi,100);
y1 = sin(x);
y2 = cos(x);



% set the text interpreter type to LATEX
setInterp2Latex;

% plot the figure
figure
plot(x,y1,x,y2)
title('Line plot of sine and cosine between -2$\pi$ and 2$\pi$');
xlabel('$$ -2\pi < x < 2\pi $$');
ylabel('sine and cosine values');
legend({'y = sin($$ x $$)','y = cos($$ x $$)'},'Location','southwest');
ax = gca;
ax.FontSize = 13;



% re-set the text interpreter type to TEXT
setInterp2Tex;

% plot the figure
figure
plot(x,y1,x,y2)
title('Line plot of sine and cosine between -2\pi and 2\pi')
xlabel('-2\pi < x < 2\pi') 
ylabel('sine and cosine values') 
legend({'y = sin(x)','y = cos(x)'},'Location','southwest')
ax = gca;
ax.FontSize = 13;

