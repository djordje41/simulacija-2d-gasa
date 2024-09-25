function statistikaPoluprecnikDiska(posuda)
    % Zavisnost srednjeg broja generisanih validnih stanja gasa od poluprečnika diska
    % pri fiksnom broju diskova

    simulatorBoltzmann = SimulatorBoltzmannoveStatistike(posuda);
    simulatorNewton = SimulatorNewtonoveMehanike(posuda);
    simulatorMarkov = SimulatorMarkovljevogLanca(posuda);

    newtonVremeSimulacije = 2000;
    newtonBrojDogadjaja = 100;
    m = 6.6464731e-27; % Masa atoma He u [kg]

    brojIteracija = 10;
    brojDiskova = 50; % Fiksni broj diskova

    % Definisanje opsega poluprečnika diska od minimalne vrednosti do 0.005 m
    minimalniPoluprecnik = 1e-5; % 0.00001 m
    maksimalniPoluprecnik = 0.005; % 0.005 m
    brojVrednostiPoluprecnika = 20; % Broj različitih vrednosti poluprečnika
    opsegPoluprecnikaDiskova = linspace(minimalniPoluprecnik, maksimalniPoluprecnik, brojVrednostiPoluprecnika);

    % Inicijalizacija matrica za čuvanje rezultata
    vremeSimBoltzmann = zeros(length(opsegPoluprecnikaDiskova), 1);
    brojStanjaBoltzmann = zeros(length(opsegPoluprecnikaDiskova), 1);

    vremeSimNewtonOpt = zeros(length(opsegPoluprecnikaDiskova), 1);
    brojStanjaNewtonOpt = zeros(length(opsegPoluprecnikaDiskova), 1);

    vremeSimNewtonNoOpt = zeros(length(opsegPoluprecnikaDiskova), 1);
    brojStanjaNewtonNoOpt = zeros(length(opsegPoluprecnikaDiskova), 1);

    vremeSimMarkov = zeros(length(opsegPoluprecnikaDiskova), 1);
    brojStanjaMarkov = zeros(length(opsegPoluprecnikaDiskova), 1);

    % Iteracija kroz opseg poluprečnika diskova
    for n = 1:length(opsegPoluprecnikaDiskova)
        poluprecnikDiska = opsegPoluprecnikaDiskova(n);
        for i = 1 : brojIteracija
            % --- Boltzmann Simulator ---
            boltzmannBrojPokusajaList = [100, 1000, 10000];
            uspehBoltzmann = false;
            for attempt = 1:length(boltzmannBrojPokusajaList)
                boltzmannBrojPokusaja = boltzmannBrojPokusajaList(attempt);
                [rezultat, brojGenerisanihStanjaB, vremeSimulacijeB] = ...
                    simulatorBoltzmann.simuliraj(brojDiskova, poluprecnikDiska, boltzmannBrojPokusaja);

                if rezultat == false
                    disp("Nema rezultata za brojDiskova=" + brojDiskova + ...
                        ", poluprečnikDiska=" + poluprecnikDiska + ...
                        ", brojPokusaja=" + boltzmannBrojPokusaja);
                else
                    uspehBoltzmann = true;
                    break;
                end
            end

            if uspehBoltzmann == false
                disp("Boltzmann simulator nije uspeo za poluprečnikDiska=" + poluprecnikDiska + ...
                     " nakon " + boltzmannBrojPokusaja + " pokušaja.");
                % Preskačemo ostale metode i prelazimo na sledeć u iteraciju
                continue;
            end

            disp("Boltzmann simulator završen za poluprečnikDiska=" + poluprecnikDiska);

            vremeSimBoltzmann(n) = vremeSimBoltzmann(n) + vremeSimulacijeB;
            brojStanjaBoltzmann(n) = brojStanjaBoltzmann(n) + brojGenerisanihStanjaB;

            % --- Newton Simulator with Optimization ---
            [brojGenerisanihStanjaOpt, vremeSimulacijeOpt] = ...
                simulatorNewton.simuliraj(poluprecnikDiska, m, newtonVremeSimulacije, newtonBrojDogadjaja, false, true); % true for optimization

            disp("Newton simulator (opt) završen za poluprečnikDiska=" + poluprecnikDiska);

            vremeSimNewtonOpt(n) = vremeSimNewtonOpt(n) + vremeSimulacijeOpt;
            brojStanjaNewtonOpt(n) = brojStanjaNewtonOpt(n) + brojGenerisanihStanjaOpt;

            % --- Newton Simulator without Optimization ---
            [brojGenerisanihStanjaNoOpt, vremeSimulacijeNoOpt] = ...
                simulatorNewton.simuliraj(poluprecnikDiska, m, newtonVremeSimulacije, newtonBrojDogadjaja, false, false); % false for no optimization

            disp("Newton simulator (no opt) završen za poluprečnikDiska=" + poluprecnikDiska);

            vremeSimNewtonNoOpt(n) = vremeSimNewtonNoOpt(n) + vremeSimulacijeNoOpt;
            brojStanjaNewtonNoOpt(n) = brojStanjaNewtonNoOpt(n) + brojGenerisanihStanjaNoOpt;

            % --- Markov Chain Simulator ---
            [brojGenerisanihStanjaM, vremeSimulacijeM] = ...
                simulatorMarkov.simuliraj(poluprecnikDiska, brojDiskova);

            disp("Markovljev lanac simulator završen za poluprečnikDiska=" + poluprecnikDiska);

            vremeSimMarkov(n) = vremeSimMarkov(n) + vremeSimulacijeM;
            brojStanjaMarkov(n) = brojStanjaMarkov(n) + brojGenerisanihStanjaM;
        end
        
        if brojStanjaBoltzmann(n) == 0
            break;
        end
    end

    % Izračunavanje prosečnog broja generisanih stanja po vremenu
    prosekStanjaPoVremenuBoltzmann = brojStanjaBoltzmann ./ vremeSimBoltzmann;
    prosekStanjaPoVremenuNewtonOpt = brojStanjaNewtonOpt ./ vremeSimNewtonOpt;
    prosekStanjaPoVremenuNewtonNoOpt = brojStanjaNewtonNoOpt ./ vremeSimNewtonNoOpt;
    prosekStanjaPoVremenuMarkov = brojStanjaMarkov ./ vremeSimMarkov;

    % Čuvanje rezultata u CSV fajlove
    csvwrite('prosekStanjaPoVremenuBoltzmannPoluprecnik.csv', [opsegPoluprecnikaDiskova', prosekStanjaPoVremenuBoltzmann]);
    csvwrite('prosekStanjaPoVremenuNewtonOptPoluprecnik.csv', [opsegPoluprecnikaDiskova', prosekStanjaPoVremenuNewtonOpt]);
    csvwrite('prosekStanjaPoVremenuNewtonNoOptPoluprecnik.csv', [opsegPoluprecnikaDiskova', prosekStanjaPoVremenuNewtonNoOpt]);
    csvwrite('prosekStanjaPoVremenuMarkovPoluprecnik.csv', [opsegPoluprecnikaDiskova', prosekStanjaPoVremenuMarkov]);

    % Opcionalno, čuvanje svih podataka za dodatnu analizu
    save('simulacija_podaci_poluprecnik.mat', 'opsegPoluprecnikaDiskova', ...
        'vremeSimBoltzmann', 'brojStanjaBoltzmann', ...
        'vremeSimNewtonOpt', 'brojStanjaNewtonOpt', ...
        'vremeSimNewtonNoOpt', 'brojStanjaNewtonNoOpt', ...
        'vremeSimMarkov', 'brojStanjaMarkov');

    % Plotovanje rezultata
    figure('Position', [200, 200, 800, 450]);
    hold on;

    plot(opsegPoluprecnikaDiskova, prosekStanjaPoVremenuBoltzmann, '-o', 'DisplayName', 'Direct sampling', 'Marker', 'o');
    plot(opsegPoluprecnikaDiskova, prosekStanjaPoVremenuNewtonOpt, '-s', 'DisplayName', 'Newton optimized', 'Marker', 's');
    plot(opsegPoluprecnikaDiskova, prosekStanjaPoVremenuNewtonNoOpt, '-^', 'DisplayName', 'Newton unoptimized', 'Marker', '^');
    plot(opsegPoluprecnikaDiskova, prosekStanjaPoVremenuMarkov, '-d', 'DisplayName', 'Markov chain', 'Marker', 'd');

    xlabel('Poluprečnik diska (m)');
    ylabel('Prosečan broj generisanih validnih stanja po vremenu');
    title('Zavisnost prosečnog broja generisanih validnih stanja od poluprečnika diska');
    legend show;
    grid on;
    hold off;
end
