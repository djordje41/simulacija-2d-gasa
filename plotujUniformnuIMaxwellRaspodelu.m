function plotujUniformnuIMaxwellRaspodelu()
% PLOTUJUNIFORMNUIMAXWELLRASPODELU Plots Maxwell and Uniform distributions
%   This function plots the Maxwell speed distribution from 0 to 6 sigma,
%   using the provided function 'maxellVrednostRaspodele'. It also plots
%   a uniform distribution with height equal to the maximum of the Maxwell
%   distribution over that range. The maximum value of the Maxwell
%   distribution is indicated on the plot, and the formulas for sigma,
%   most probable speed, and maximum value are displayed.

    % Physical constants
    kB = 1.380649e-23; % Boltzmann's constant in J/K

    % Parameters
    masa = 1.6735575e-27; % Mass of a hydrogen atom in kg (adjust as needed)
    temperatura = 300;    % Temperature in Kelvin (adjust as needed)

    % Calculate sigma (standard deviation of speed)
    sigma = sqrt(kB * temperatura / masa);

    % Velocity range from 0 to 6*sigma
    v = linspace(0, 6*sigma, 1000);

    % Preallocate array for Maxwell distribution values
    f_v = zeros(size(v));

    % Compute Maxwell distribution values using the provided function
    for i = 1:length(v)
        f_v(i) = maxellVrednostRaspodele(masa, temperatura, v(i));
    end

    % Find the maximum value and its corresponding speed
    [max_fv, idx_max] = max(f_v);
    v_max = v(idx_max);

    % Most probable speed v_p
    v_p = sqrt(2 * kB * temperatura / masa);

    % Define the uniform distribution over [0, 6*sigma] with height equal to max_fv
    u_v = max_fv * ones(size(v));

    % Plotting the distributions
    figure;
    plot(v, f_v, 'b-', 'LineWidth', 2); % Maxwell distribution
    hold on;
    plot(v, u_v, 'r--', 'LineWidth', 2); % Uniform distribution

    % Indicate the maximum point on the Maxwell distribution
    plot(v_max, max_fv, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8);

    % Set plot limits
    ylim([0, max_fv * 1.4]); % Extend Y-axis to accommodate formulas
    xlim([0, 6 * sigma]);    % X-axis from 0 to 6 sigma

    % Add labels and legend
    xlabel('Brzina v (m/s)'); % 'Velocity v (m/s)'
    ylabel('Funkcija raspodele f(v)'); % 'Distribution function f(v)'
    title('Upoređivanje Maxwell-ove i uniformne raspodele brzina'); % 'Comparison of Maxwell and Uniform Speed Distributions'

    legend('Maxwell-ova raspodela', 'Uniformna raspodela', 'Maksimum Maxwell-ove raspodele', ...
        'Location', 'Best'); % 'Maxwell distribution', 'Uniform distribution', 'Maximum point'

    grid on;

    % Display formulas on the plot using LaTeX
    text_x = 0.6 * max(v); % Position to display the text
    text_y = 0.9 * max_fv;

    formula_sigma = sprintf('$$\\sigma = \\sqrt{\\frac{kT}{m}}$$');
    formula_vp = sprintf('$$v_p = \\sqrt{\\frac{2kT}{m}}$$');
%     formula_fmax = sprintf('$$f_{\\text{max}} = \\frac{2\\sqrt{2}}{\\sqrt{\\pi}} e^{-1} \\sqrt{\\frac{m}{kT}}$$');

    text(text_x, text_y, formula_sigma, 'Interpreter', 'latex', 'FontSize', 12);
    text(text_x, text_y - 0.1 * max_fv, formula_vp, 'Interpreter', 'latex', 'FontSize', 12);
%     text(text_x, text_y - 0.2 * max_fv, formula_fmax, 'Interpreter', 'latex', 'FontSize', 12);

    % Adjust text positions if necessary
    % Display numerical values as well
%     numerical_values = sprintf('$$\\sigma = %.2f\\, \\text{m/s}$$\n$$v_p = %.2f\\, \\text{m/s}$$\n$$f_{\\text{max}} = %.2e$$', ...
%         sigma, v_p, max_fv);
%     text(0.6 * max(v), 0.5 * max_fv, numerical_values, 'Interpreter', 'latex', 'FontSize', 12);

    hold off;

    % Display the maximum value in the command window
    fprintf('Maksimalna vrednost Maxwell-ove raspodele je f(v) = %.4e pri v = %.2f m/s\n', max_fv, v_max);
end
