function testirajMaxwellBoltzmannRaspodelu()
% Testni skript
k = 1.380649e-23; % Bolcmanova konstanta u J/K
m = 1e-20; % Masa čestice (npr. atoma argona) u kg
T = 300; % Temperatura u Kelvinima
n = 100000; % Broj slučajnih brzina koje treba generisati

% Poziv funkcije za generisanje brzina
brzine = maxwellBoltzmannBrzina(m, T, n);

% Iscrtavanje histograma brzina
figure(11);
histogram(brzine, 'Normalization', 'pdf');
title('Histogram brzina po Maksvel-Bolcmanovoj raspodeli');
xlabel('Brzina (m/s)');
ylabel('Gustina verovatnoće');

% Dodavanje teoretske Maksvel-Bolcmanove raspodeli za poređenje
v = linspace(0, max(brzine), 1000);
f_v = sqrt((m/(2*pi*k*T))^3) * 4*pi*v.^2 .* exp(-m*v.^2/(2*k*T));
hold on;
plot(v, f_v, 'r-', 'LineWidth', 2);
legend('Simulirani podaci', 'Teorijska kriva');
hold off;

end