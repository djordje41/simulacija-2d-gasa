%% Test Maxwell Boltzman raspodela
testirajMaxwellBoltzmannRaspodelu();

%% Inicijalizacija promenljivih
sirinaPosude = 1000; %[m]
visinaPosude = 1000; %[m]

poluprecnikDiska = 50;
brojDiskova = 20;

bolzmannBrojPokusaja = 10000;

newtonVremeSimulacije = 5000;

% Ako zelite da se preskoci statistika (traje mnogo) ovo ostaje true
preskociStatistiku = true;

%% Inicijalizacija posude
posuda = Posuda(0, sirinaPosude, 0, visinaPosude, []);

%% Simulacija Bolcmanove statistike
simulatorBoltzmannoveStatistike = SimulatorBoltzmannoveStatistike(posuda);

[rezultat, ~, ~] = simulatorBoltzmannoveStatistike.simuliraj(brojDiskova, poluprecnikDiska, bolzmannBrojPokusaja);

if (rezultat == false)
    disp("Bolzmann-ov metod nije uspeo generisati niti jedan validan " + ...
        "raspored diskova sa zadatim parametrima i posudom.");
    
    % Kako bismo simulirali Newton-ovu mehaniku, moramo imati inicijalni
    % raspored diskova. Kako Bolzmann-ova metoda nije uspela generisati
    % barem jedan, ovde prekidamo dalje izvrsenje programa.
    return;
end

disp('----------------------------------');

%% Simulacija Newton-ove mehanike
simulatorNewtonoveMehanike = SimulatorNewtonoveMehanike(posuda);

disp('Rezultati Newtonove metode:');
simulatorNewtonoveMehanike.simuliraj(poluprecnikDiska, newtonVremeSimulacije, true);

disp('----------------------------------');

%% Simulacija Markovljevog lanca
simulatorMarkovljevogLanca = SimulatorMarkovljevogLanca(posuda);

brojPokusaja = 10000;
simulatorMarkovljevogLanca.simuliraj(poluprecnikDiska, brojPokusaja);

disp('----------------------------------');

%% Citanje i ispis rezultata
rezultat = csvread("newtonResult.csv");

vreme = rezultat(1, 1 : 2 : end);

brojDiskovaZaPrikaz = 100;

if (brojDiskovaZaPrikaz > brojDiskova)
    brojDiskovaZaPrikaz = brojDiskova;
end

% Ovo su samo x koordinate
XkoordinateDiskova = rezultat(2 : brojDiskovaZaPrikaz + 1, 1 : 2 : end);
YkoordinateDiskova = rezultat(2 : brojDiskovaZaPrikaz + 1, 2 : 2 : end);

[leviGrafik, desniGrafik] = konfiguracijaGrafika();

% Prikaz X koordinata diskova u vremenu
figure(1);
plot(vreme, XkoordinateDiskova);
xlabel('Vreme [s]');
ylabel('X koordinate centara diskova');
title('Grafik prikaza X koordinata svih diskova u vremenu trajanja simulacije.');
set(gcf, 'Position', leviGrafik);

% Prikaz Y koordinata diskova u vremenu
figure(2);
plot(vreme, YkoordinateDiskova);
xlabel('Vreme [s]');
ylabel('Y koordinate centara diskova');
title('Grafik prikaza Y koordinata svih diskova u vremenu trajanja simulacije.');
set(gcf, 'Position', desniGrafik);

%% Statistika

if (~preskociStatistiku)

% Zavisnost srednjeg broja generisanih validnih stanja gasa od broja diskova i poluprecnika diska

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

%% Crtanje diskova
return;
% Initialize figure
figure(3);
% hold on;
xlim([0 sirinaPosude]); % Set x-axis limits
ylim([0 visinaPosude]); % Set y-axis limits

[brojDiskova, brojPozicija] = size(XkoordinateDiskova);

% Main loop for animation
for frame = 1 : brojPozicija
    % Calculate new position of the circle
    x = XkoordinateDiskova(:, frame); % Update x coordinate
    y = YkoordinateDiskova(:, frame); % Update y coordinate

    hold on;
    plot(x, y, '+', 'MarkerSize', 2); % Plot circle
    
    % Pause to control animation speed (optional)
    pause(1); % Adjust the pause duration as needed
end
