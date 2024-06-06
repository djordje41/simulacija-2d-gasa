function plotujPritisak(posuda)
    rezultati = csvread('newtonResultPressure.csv');
    
    impulsi = rezultati(1, :); %[kg*m/s]
    vremenskiTrenuci = rezultati(2, :); %[s]
    
    pastSecond = 1; % in seconds
    cumulativeImpulse = zeros(size(impulsi));
    for i = 1:length(vremenskiTrenuci)
        indices = vremenskiTrenuci >= (vremenskiTrenuci(i) - pastSecond) & ...
            vremenskiTrenuci <= vremenskiTrenuci(i);
        cumulativeImpulse(i) = sum(impulsi(indices));
    end
    
    cumulativeImpulse = cumulativeImpulse ./ posuda.obim;

    % Plot the cumulative sum of impulses
    figure(201);
    plot(vremenskiTrenuci, cumulativeImpulse, 'b.-');
    xlabel('Vreme [s]');
    ylabel('Pritisak [kg/s^2]');
    title('Prikaz linijskog pritiska na zidove posude u vremenu');
    grid on;
end

