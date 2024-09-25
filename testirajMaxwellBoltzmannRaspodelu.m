function testirajMaxwellBoltzmannRaspodelu()
% Testni skript
k = 1.380649e-23; % Bolcmanova konstanta u J/K
m = 6.6464731e-27; % Masa atoma He u kg
T = 300; % Temperatura u Kelvinima
n = 100000; % Broj slučajnih brzina koje treba generisati

% Poziv funkcije za generisanje brzina
brzine = maxwellBoltzmannBrzina(m, T, n);

intenziteti = sqrt(brzine(:, 1).^2 + brzine(:, 2).^2);

% Iscrtavanje histograma brzina
figure(11);
histogram(intenziteti, 'Normalization', 'pdf');
title('Histogram brzina po Maksvel-Bolcmanovoj raspodeli');
xlabel('Brzina (m/s)');
ylabel('Gustina verovatnoće');

% Dodavanje teoretske Maksvel-Bolcmanove raspodeli za poređenje
v = linspace(0, max(intenziteti), 1000);
f_v = sqrt((m/(2*pi*k*T))^3) * 4*pi*v.^2 .* exp(-m*v.^2/(2*k*T));
hold on;
plot(v, f_v, 'r-', 'LineWidth', 2);
legend('Simulirani podaci', 'Teorijska kriva');
hold off;

end