% Get all line objects from figure 101
lines = findobj(figure(101), 'Type', 'Line');

% Loop over the lines and extract X and Y data
for i = 1:length(lines)
    xData = get(lines(i), 'XData');
    yData = get(lines(i), 'YData');
    
    % Display or save the data
    disp(['Line ', num2str(i), ' X Data:']);
    disp(xData);
    disp(['Line ', num2str(i), ' Y Data:']);
    disp(yData);
    
    % Save the data into a file if needed
    filename = ['line_', num2str(i), '_data.csv'];
    csvwrite(filename, [xData', yData']);
end

% Read the data from the CSV files (replace 'line_1_data.csv' with your actual file names)
data1 = csvread('line_1_data.csv');  % Assuming this is for the first line
data2 = csvread('line_2_data.csv');  % Assuming this is for the second line

% Separate the X and Y data from both files
xData1 = data1(:, 1);
yData1 = data1(:, 2);

xData2 = data2(:, 1);
yData2 = data2(:, 2);

% First plot: X axis from 0 to 20
figure;
hold on;
plot(xData1(xData1 <= 20), yData1(xData1 <= 20), '-o', 'DisplayName', 'Boltzmann');
plot(xData2(xData2 <= 20), yData2(xData2 <= 20), '-x', 'DisplayName', 'Newton');
xlabel('Broj diskova');
ylabel('Prosečni broj generisanih validnih stanja po vremenu');
title('Prosečni broj generisanih stanja (0-20 diskova)');
legend show;
grid on;
hold off;

% Second plot: X axis from 20 to the end (200)
figure;
hold on;
plot(xData1(xData1 >= 20), yData1(xData1 >= 20), '-o', 'DisplayName', 'Boltzmann');
plot(xData2(xData2 >= 20), yData2(xData2 >= 20), '-x', 'DisplayName', 'Newton');
xlabel('Broj diskova');
ylabel('Prosečni broj generisanih validnih stanja po vremenu');
title('Prosečni broj generisanih stanja (20-200 diskova)');
legend show;
grid on;
hold off;
