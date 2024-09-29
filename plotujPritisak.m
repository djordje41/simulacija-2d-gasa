function plotujPritisak(posuda)
    % Read the data
    rezultati = csvread('newtonResultPressure.csv');
    
    impulsi = rezultati(1, :); % [kg·m/s]
    vremenskiTrenuci = rezultati(2, :); % [s]
    
    % Set the time interval in seconds
    pastSecond = 0.0001;
    
    cumulativeImpulse = zeros(size(impulsi));
    for i = 1:length(vremenskiTrenuci)
        % Find indices within the time window
        indices = vremenskiTrenuci >= (vremenskiTrenuci(i) - pastSecond) & ...
                   vremenskiTrenuci <= vremenskiTrenuci(i);
        cumulativeImpulse(i) = sum(impulsi(indices));
    end
    
    % Compute the force by dividing cumulative impulse by the time interval
    cumulativeForce = cumulativeImpulse ./ pastSecond; % [kg·m/s^2]
    
    % Compute the pressure by dividing force by the container's perimeter
    disp(posuda.obim);
    pressure = cumulativeForce ./ posuda.obim; % [kg/s^2]
    
    % Plot the pressure over time
    fig = figure(201);
    set(fig, 'Position', [200, 200, 800, 450]);
    plot(vremenskiTrenuci, pressure, '-');
    xlabel('Vreme [s]');
    ylabel('Pritisak [N/m]');
    title('Prikaz linijskog pritiska na zidove posude u vremenu');
    grid on;
end
