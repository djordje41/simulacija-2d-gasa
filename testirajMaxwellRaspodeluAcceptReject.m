function testirajMaxwellRaspodeluAcceptReject()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Testni skript
k = 1.380649e-23; % Bolcmanova konstanta u J/K
m = 6.6464731e-27; % Masa atoma He u kg
T = 300; % Temperatura u Kelvinima
n = 100000; % Broj slučajnih brzina koje treba generisati

% Poziv funkcije za generisanje brzina
brzine = brzinaPoMaxwellRaspodeliAcceptReject(n, m, T);

% Iscrtavanje histograma brzina
fig = figure(11); % Kreiranje figure sa brojem 11
set(fig, 'Position', [200, 200, 800, 450]); % Postavljanje veličine figure
histogram(brzine, 'Normalization', 'pdf');
title('Histogram intenziteta brzina po Maksvelovoj raspodeli');
xlabel('Brzina [m/s]');
ylabel('Gustina verovatnoće [(m/s)^{-1}]');

% Dodavanje teoretske Maksvel-Bolcmanove raspodeli za poređenje
v = linspace(0, max(brzine), 1000);
f_v = m * v / (k * T) .* exp(-m*v.^2/(2*k*T));
hold on;
plot(v, f_v, 'r-', 'LineWidth', 2);
legend('Simulirani podaci', 'Teorijska kriva');
hold off;
end

