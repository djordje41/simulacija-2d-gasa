function statistikaBrojDiskova(posuda)
    % Zavisnost srednjeg broja generisanih validnih stanja gasa od broja diskova i poluprecnika diska
    simulatorBoltzmann = SimulatorBoltzmannoveStatistike(posuda);
    simulatorNewton = SimulatorNewtonoveMehanike(posuda);
    simulatorMarkov = SimulatorMarkovljevogLanca(posuda);

    boltzmannBrojPokusaja = 100;

    newtonVremeSimulacije = 2000;
    newtonBrojDogadjaja = 100;
    m = 6.6464731e-27; % Masa atoma He u [kg]

    markovBrojPokusaja = 100;

    brojIteracija = 10;
    opsegBrojaDiskova = [20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]; % Adjust as needed
    poluprecnikDiska = 3.1e-11; % Poluprecnik atoma helijuma

    % Inicijalizacija matrica za cuvanje rezultata
    vremeSimBoltzmann = zeros(length(opsegBrojaDiskova), 1);
    brojStanjaBoltzmann = zeros(length(opsegBrojaDiskova), 1);

    vremeSimNewtonOpt = zeros(length(opsegBrojaDiskova), 1);
    brojStanjaNewtonOpt = zeros(length(opsegBrojaDiskova), 1);

    vremeSimNewtonNoOpt = zeros(length(opsegBrojaDiskova), 1);
    brojStanjaNewtonNoOpt = zeros(length(opsegBrojaDiskova), 1);

    vremeSimMarkov = zeros(length(opsegBrojaDiskova), 1);
    brojStanjaMarkov = zeros(length(opsegBrojaDiskova), 1);

    % Iteracija kroz opseg broja diskova
    for n = 1:length(opsegBrojaDiskova)
        brojDiskova = opsegBrojaDiskova(n);
        for i = 1 : brojIteracija
            % --- Boltzmann Simulator ---
            [rezultat, brojGenerisanihStanjaB, vremeSimulacijeB] = ...
                simulatorBoltzmann.simuliraj(brojDiskova, poluprecnikDiska, boltzmannBrojPokusaja);

            if (rezultat == false)
                disp("Nema rezultata za brojDiskova=" + brojDiskova + ...
                    " i poluprecnikDiska=" + poluprecnikDiska + ...
                    " i brojPokusaja=" + boltzmannBrojPokusaja);
                continue;
            end

            disp("Boltzmann simulator zavrsen za brojDiskova=" + brojDiskova);

            vremeSimBoltzmann(n) = vremeSimBoltzmann(n) + vremeSimulacijeB;
            brojStanjaBoltzmann(n) = brojStanjaBoltzmann(n) + brojGenerisanihStanjaB;

            % --- Newton Simulator with Optimization ---
            [brojGenerisanihStanjaOpt, vremeSimulacijeOpt] = ...
                simulatorNewton.simuliraj(poluprecnikDiska, m, newtonVremeSimulacije, newtonBrojDogadjaja, false, true); % true for optimization

            disp("Newton simulator (opt) zavrsen za brojDiskova=" + brojDiskova);

            vremeSimNewtonOpt(n) = vremeSimNewtonOpt(n) + vremeSimulacijeOpt;
            brojStanjaNewtonOpt(n) = brojStanjaNewtonOpt(n) + brojGenerisanihStanjaOpt;

            % --- Newton Simulator without Optimization ---
            [brojGenerisanihStanjaNoOpt, vremeSimulacijeNoOpt] = ...
                simulatorNewton.simuliraj(poluprecnikDiska, m, newtonVremeSimulacije, newtonBrojDogadjaja, false, false); % false for no optimization

            disp("Newton simulator (no opt) zavrsen za brojDiskova=" + brojDiskova);

            vremeSimNewtonNoOpt(n) = vremeSimNewtonNoOpt(n) + vremeSimulacijeNoOpt;
            brojStanjaNewtonNoOpt(n) = brojStanjaNewtonNoOpt(n) + brojGenerisanihStanjaNoOpt;

            % --- Markov Chain Simulator ---
            [brojGenerisanihStanjaM, vremeSimulacijeM] = ...
                simulatorMarkov.simuliraj(poluprecnikDiska, markovBrojPokusaja);

            disp("Markovljev lanac simulator zavrsen za brojDiskova=" + brojDiskova);

            vremeSimMarkov(n) = vremeSimMarkov(n) + vremeSimulacijeM;
            brojStanjaMarkov(n) = brojStanjaMarkov(n) + brojGenerisanihStanjaM;
        end
    end

    % Izracunavanje prosecnog broja generisanih stanja po vremenu
    prosekStanjaPoVremenuBoltzmann = brojStanjaBoltzmann ./ vremeSimBoltzmann;
    prosekStanjaPoVremenuNewtonOpt = brojStanjaNewtonOpt ./ vremeSimNewtonOpt;
    prosekStanjaPoVremenuNewtonNoOpt = brojStanjaNewtonNoOpt ./ vremeSimNewtonNoOpt;
    prosekStanjaPoVremenuMarkov = brojStanjaMarkov ./ vremeSimMarkov;

    % Save results to CSV files
    csvwrite('prosekStanjaPoVremenuBoltzmann.csv', prosekStanjaPoVremenuBoltzmann);
    csvwrite('prosekStanjaPoVremenuNewtonOpt.csv', prosekStanjaPoVremenuNewtonOpt);
    csvwrite('prosekStanjaPoVremenuNewtonNoOpt.csv', prosekStanjaPoVremenuNewtonNoOpt);
    csvwrite('prosekStanjaPoVremenuMarkov.csv', prosekStanjaPoVremenuMarkov);

    % Optionally, save all raw data for further analysis
    save('simulacija_podaci.mat', 'opsegBrojaDiskova', ...
        'vremeSimBoltzmann', 'brojStanjaBoltzmann', ...
        'vremeSimNewtonOpt', 'brojStanjaNewtonOpt', ...
        'vremeSimNewtonNoOpt', 'brojStanjaNewtonNoOpt', ...
        'vremeSimMarkov', 'brojStanjaMarkov');

    % Plotovanje rezultata
    figure('Position', [200, 200, 850, 500]);
    hold on;

    plot(opsegBrojaDiskova, prosekStanjaPoVremenuBoltzmann, '-o', 'DisplayName', 'Direct sampling', 'Marker', 'o');
    plot(opsegBrojaDiskova, prosekStanjaPoVremenuNewtonOpt, '-s', 'DisplayName', 'Newton optimized', 'Marker', 's');
    plot(opsegBrojaDiskova, prosekStanjaPoVremenuNewtonNoOpt, '-^', 'DisplayName', 'Newton unoptimized', 'Marker', '^');
    plot(opsegBrojaDiskova, prosekStanjaPoVremenuMarkov, '-d', 'DisplayName', 'Markov chain', 'Marker', 'd');

    xlabel('Broj diskova');
    ylabel('Prosečan broj generisanih validnih stanja po sekundi [s^{-1}]');
    title('Zavisnost prosečnog broja generisanih validnih stanja po sekundi od broja diskova');
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
