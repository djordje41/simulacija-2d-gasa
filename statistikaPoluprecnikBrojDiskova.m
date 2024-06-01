function statistikaPoluprecnikBrojDiskova(posuda)
% Zavisnost srednjeg broja generisanih validnih stanja gasa od broja diskova i poluprecnika diska
simulatorBoltzmannoveStatistike = SimulatorBoltzmannoveStatistike(posuda);
simulatorNewtonoveMehanike = SimulatorNewtonoveMehanike(posuda);

brojIteracija = 10;

opsegBrojaDiskova = 1 : 3 : 30;
opsegPoluprecnika = 3 : 3 : 16;

% Inicijalizacija matrica za cuvanje rezultata
ukupnoVremeSimulacijeBoltzmann = zeros(length(opsegBrojaDiskova), length(opsegPoluprecnika));
ukupanBrojGenerisanihStanjaBoltzmann = zeros(length(opsegBrojaDiskova), length(opsegPoluprecnika));

ukupnoVremeSimulacijeNewton = zeros(length(opsegBrojaDiskova), length(opsegPoluprecnika));
ukupanBrojGenerisanihStanjaNewton = zeros(length(opsegBrojaDiskova), length(opsegPoluprecnika));

% Iteracija kroz opsege broja diskova i poluprecnika diska
for n = 1:length(opsegBrojaDiskova)
    brojDiskova = opsegBrojaDiskova(n);
    for r = 1:length(opsegPoluprecnika)
        poluprecnikDiska = opsegPoluprecnika(r);
        for i = 1 : brojIteracija
            % Najpre simuliramo Boltzmanna kako bi nam generisao validnu konfiguraciju za Newtona
            [rezultat, brojGenerisanihStanjaB, vremeSimulacijeB] = simulatorBoltzmannoveStatistike.simuliraj(brojDiskova, poluprecnikDiska, bolzmannBrojPokusaja);

            if (rezultat == false)
                disp("Nema rezultata za brojDiskova=" + brojDiskova + " i poluprecnikDiska=" + poluprecnikDiska + "\n");
                continue;
            end

            ukupnoVremeSimulacijeBoltzmann(n, r) = ...
                ukupnoVremeSimulacijeBoltzmann(n, r) + vremeSimulacijeB;

            ukupanBrojGenerisanihStanjaBoltzmann(n, r) = ...
                ukupanBrojGenerisanihStanjaBoltzmann(n, r) + brojGenerisanihStanjaB;

            % Simuliramo sada Newtona
            [brojGenerisanihStanja, vremeSimulacije] = simulatorNewtonoveMehanike.simuliraj(poluprecnikDiska, newtonVremeSimulacije, true);

            ukupnoVremeSimulacijeNewton(n, r) = ...
                ukupnoVremeSimulacijeNewton(n, r) + vremeSimulacije;

            ukupanBrojGenerisanihStanjaNewton(n, r) = ...
                ukupanBrojGenerisanihStanjaNewton(n, r) + brojGenerisanihStanja; 
        end
    end
end

% Izracunavanje prosecnog broja generisanih stanja po vremenu
prosecniBrojGenerisanihStanjaPoVremenuBoltzmann = ukupanBrojGenerisanihStanjaBoltzmann ./ ukupnoVremeSimulacijeBoltzmann;
prosecniBrojGenerisanihStanjaPoVremenuNewton = ukupanBrojGenerisanihStanjaNewton ./ ukupnoVremeSimulacijeNewton;

% Save results to CSV files
csvwrite('prosecniBrojGenerisanihStanjaPoVremenuBoltzmann.csv', prosecniBrojGenerisanihStanjaPoVremenuBoltzmann);
csvwrite('prosecniBrojGenerisanihStanjaPoVremenuNewton.csv', prosecniBrojGenerisanihStanjaPoVremenuNewton);

% Plotovanje rezultata - Boltzmann
figure;
surf(opsegPoluprecnika, opsegBrojaDiskova, prosecniBrojGenerisanihStanjaPoVremenuBoltzmann);
xlabel('Poluprecnik diska [m]');
ylabel('Broj diskova');
zlabel('Prosecni broj generisanih validnih stanja po vremenu');
title('Zavisnost prosečnog broja generisanih validnih stanja od broja diskova i poluprečnika diska (Boltzmann)');
colorbar;

% Plotovanje rezultata - Newton
figure;
surf(opsegPoluprecnika, opsegBrojaDiskova, prosecniBrojGenerisanihStanjaPoVremenuNewton);
xlabel('Poluprecnik diska [m]');
ylabel('Broj diskova');
zlabel('Prosecni broj generisanih validnih stanja po vremenu');
title('Zavisnost prosečnog broja generisanih validnih stanja od broja diskova i poluprečnika diska (Newton)');
colorbar;

% Plotovanje rezultata - Newton vs Boltzmann
prosecniBrojGenerisanihStanjaNewtonVsBoltzmann = prosecniBrojGenerisanihStanjaPoVremenuNewton ./ prosecniBrojGenerisanihStanjaPoVremenuBoltzmann;

figure;
surf(opsegPoluprecnika, opsegBrojaDiskova, prosecniBrojGenerisanihStanjaNewtonVsBoltzmann);
xlabel('Poluprecnik diska [m]');
ylabel('Broj diskova');
zlabel('Odnos Newton/Boltzmann');
title('Odnos prosečnog broja generisanih validnih stanja Newton/Boltzmann');
colorbar;

% Plotovanje rezultata - Combined Plot for Newton and Boltzmann
figure;
hold on;
surf(opsegPoluprecnika, opsegBrojaDiskova, prosecniBrojGenerisanihStanjaPoVremenuBoltzmann, 'FaceAlpha', 0.5, 'DisplayName', 'Boltzmann');
surf(opsegPoluprecnika, opsegBrojaDiskova, prosecniBrojGenerisanihStanjaPoVremenuNewton, 'FaceAlpha', 0.5, 'DisplayName', 'Newton');
xlabel('Poluprecnik diska [m]');
ylabel('Broj diskova');
zlabel('Prosecni broj generisanih validnih stanja po vremenu');
title('Zavisnost prosečnog broja generisanih validnih stanja od broja diskova i poluprečnika diska (Combined)');
legend show;
colorbar;
hold off;
end

