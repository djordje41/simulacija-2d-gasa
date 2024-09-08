function statistikaBrojDiskova(posuda)
% Zavisnost srednjeg broja generisanih validnih stanja gasa od broja diskova i poluprecnika diska
simulatorBoltzmann = SimulatorBoltzmannoveStatistike(posuda);
simulatorNewton = SimulatorNewtonoveMehanike(posuda);

bolzmannBrojPokusaja = 100;

newtonVremeSimulacije = 2000;
newtonBrojDogadjaja = 100;
m = 6.6464731e-27; % Masa atoma He u [kg]

brojIteracija = 5;
opsegBrojaDiskova = 25 : 20 : 125;
poluprecnikDiska = 1.04e-13;

% Inicijalizacija matrica za cuvanje rezultata
vremeSimBoltzmann = zeros(length(opsegBrojaDiskova), 1);
brojStanjaBoltzmann = zeros(length(opsegBrojaDiskova), 1);

vremeSimNewton = zeros(length(opsegBrojaDiskova), 1);
brojStanjaNewton = zeros(length(opsegBrojaDiskova), 1);

% Iteracija kroz opseg broja diskova
for n = 1:length(opsegBrojaDiskova)
    brojDiskova = opsegBrojaDiskova(n);
    for i = 1 : brojIteracija
        % Najpre simuliramo Boltzmanna kako bi nam generisao validnu konfiguraciju za Newtona
        [rezultat, brojGenerisanihStanjaB, vremeSimulacijeB] = simulatorBoltzmann.simuliraj(brojDiskova, poluprecnikDiska, bolzmannBrojPokusaja);

        if (rezultat == false)
            disp("Nema rezultata za brojDiskova=" + brojDiskova + " i poluprecnikDiska=" + poluprecnikDiska + " i brojPokusaja=" + bolzmannBrojPokusaja + "\n");
            continue;
        end
        
        disp("-------------------------------------------");

        vremeSimBoltzmann(n) = vremeSimBoltzmann(n) + vremeSimulacijeB;
        brojStanjaBoltzmann(n) = brojStanjaBoltzmann(n) + brojGenerisanihStanjaB;

        % Simuliramo sada Newtona
        [brojGenerisanihStanja, vremeSimulacije] = simulatorNewton.simuliraj(poluprecnikDiska, m, newtonVremeSimulacije, newtonBrojDogadjaja, false);

        disp("-------------------------------------------");
        
        vremeSimNewton(n) = vremeSimNewton(n) + vremeSimulacije;
        brojStanjaNewton(n) = brojStanjaNewton(n) + brojGenerisanihStanja;
    end
end

% Izracunavanje prosecnog broja generisanih stanja po vremenu
prosekStanjaPoVremenuBoltzmann = brojStanjaBoltzmann ./ vremeSimBoltzmann;
prosekStanjaPoVremenuNewton = brojStanjaNewton ./ vremeSimNewton;

% Save results to new CSV files
csvwrite('prosekStanjaPoVremenuBoltzmann_new.csv', prosekStanjaPoVremenuBoltzmann);
csvwrite('prosekStanjaPoVremenuNewton_new.csv', prosekStanjaPoVremenuNewton);

% Plotovanje rezultata
figure(101);
hold on;
plot(opsegBrojaDiskova, prosekStanjaPoVremenuBoltzmann, '-o', 'DisplayName', 'Boltzmann');
plot(opsegBrojaDiskova, prosekStanjaPoVremenuNewton, '-x', 'DisplayName', 'Newton');
xlabel('Broj diskova');
ylabel('Prosecni broj generisanih validnih stanja po vremenu');
title('Zavisnost prosečnog broja generisanih validnih stanja od broja diskova');
legend show;
grid on;
hold off;
end

% Ovi podaci ispod predstavljaju rezultate samo Boltzmannove statistike
% koja nasumicno postavlja diskove u posudi. Neparne kolone predstavljaju
% vreme koje je bilo potrebno da se izgenerise broj validnih stanja diskova
% od 1000 pokusaja. Taj broj je u sledecoj susednoj koloni od vremena.
% data = [
%     0.49003, 996, 0.4381, 993, 0.40075, 997, 0.39778, 998, 0.43178, 997;  % 5 disks
%     6.0804, 904, 6.1941, 899, 6.1369, 914, 6.5432, 909, 6.3282, 911;      % 25 disks
%     17.9498, 723, 17.4967, 736, 18.1197, 739, 20.3513, 726, 17.8842, 713; % 45 disks
%     33.4608, 512, 33.918, 526, 33.6222, 517, 32.4682, 502, 33.5384, 523;  % 65 disks
%     47.2037, 328, 48.5305, 318, 49.1601, 307, 48.1982, 313, 47.9108, 308; % 85 disks
%     63.7921, 202, 61.7499, 173, 64.8104, 198, 60.8012, 150, 63.1673, 188; % 105 disks
%     80.3388, 99, 77.1543, 91, 83.1119, 81, 83.7373, 88, 82.6722, 72       % 125 disks
% ];
