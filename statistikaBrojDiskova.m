function statistikaBrojDiskova(posuda)
% Zavisnost srednjeg broja generisanih validnih stanja gasa od broja diskova i poluprecnika diska
simulatorBoltzmann = SimulatorBoltzmannoveStatistike(posuda);
simulatorNewton = SimulatorNewtonoveMehanike(posuda);

bolzmannBrojPokusaja = 1000;

newtonVremeSimulacije = 2000;
newtonBrojDogadjaja = 500;
m = 6.6464731e-27; % Masa atoma He u [kg]

brojIteracija = 10;
opsegBrojaDiskova = 1 : 10 : 100;
poluprecnikDiska = 0.5;

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
            disp("Nema rezultata za brojDiskova=" + brojDiskova + " i poluprecnikDiska=" + poluprecnikDiska + "\n");
            continue;
        end

        vremeSimBoltzmann(n) = vremeSimBoltzmann(n) + vremeSimulacijeB;
        brojStanjaBoltzmann(n) = brojStanjaBoltzmann(n) + brojGenerisanihStanjaB;

        % Simuliramo sada Newtona
        [brojGenerisanihStanja, vremeSimulacije] = simulatorNewton.simuliraj(poluprecnikDiska, m, newtonVremeSimulacije, newtonBrojDogadjaja, false);

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
