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

% Drawing a vertical line using getXLine
disp('Click to define a vertical polyline using getXLine...');
[x1, y1] = getYLine()  % x-coordinate = fixed; y-coordinate = free

% Plot the vertical polyline
plot(x1, y1, 'b-', 'LineWidth', 2);

% Display the legend and the line on the figure
legend('Vertical Line (getXLine)');
hold off;


