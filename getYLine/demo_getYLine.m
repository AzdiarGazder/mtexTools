close all; clc; clear all; clear hidden;

%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('FontSize',14);
set(0,'DefaultFigureWindowStyle','normal');


uiwait(helpdlg({'LEFT single click = select first point','LEFT double click = select second point'}));
figure;
hold on;
axis([-1 1 -1 1]);  % set x and y axes to range from -1 to 1
grid on;
xlabel('X-axis');
ylabel('Y-axis');

% Drawing a horizontal line using getYLine
disp('Click to define a horizontal polyline using getYLine...');
[x1, y1] = getYLine()  % x-coordinate = free; y-coordinate = fixed

% Plot the horizontal polyline
plot(x1, y1, 'r-', 'LineWidth', 2);  

% Display the legend and the line on the figure
legend('Horizontal Line (getYLine)');
hold off;


