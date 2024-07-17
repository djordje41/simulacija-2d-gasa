function testirajNewtonGrid(minN, korak, maxN, brojPonavljanja)
    %TESTIRAJNEWTONOVU Funkcija koja testira Newtonov simulator za različite vrednosti n
    %   Funkcija testira Newtonov simulator za različite vrednosti n, vrši više
    %   ponavljanja za svaku vrednost n, računa prosečan broj generisanih stanja po
    %   jedinici vremena i plotuje rezultat.

    %% Inicijalizacija promenljivih
    sirinaPosude = 0.1; %[m]
    visinaPosude = 0.1; %[m]

    m = 6.6464731e-27; % Masa atoma He u [kg]
    poluprecnikDiska = 1.04e-13; % Poluprecnik atoma He u [m]
    brojDiskova = 100;
    bolzmannBrojPokusaja = 10;

    newtonVremeSimulacije = 5000;
    newtonBrojDogadjaja = 300;

    %% Inicijalizacija posude
    posuda = Posuda(0, sirinaPosude, 0, visinaPosude, []);

    %% Simulacija Boltzmannove statistike
    simulatorBoltzmannoveStatistike = SimulatorBoltzmannoveStatistike(posuda);

    [rezultat, ~, ~] = simulatorBoltzmannoveStatistike.simuliraj(brojDiskova, poluprecnikDiska, bolzmannBrojPokusaja);

    if (rezultat == false)
        disp("Boltzmann-ov metod nije uspeo generisati niti jedan validan " + ...
            "raspored diskova sa zadatim parametrima i posudom.");
        return;
    end

    disp('----------------------------------');

    %% Promena parametra n i vršenje simulacija
    srednjiBrojGenerisanihStanjaPoVremenu = zeros(maxN - minN + 1, 1);

    for n = minN:korak:maxN
        ukupnoGenerisanihStanja = 0;
        ukupnoVreme = 0;
        
        for ponavljanje = 1:brojPonavljanja
            %% Simulacija Newton-ove mehanike
            simulatorNewtonoveMehanike = SimulatorNewtonoveMehanike(posuda, n);

            [brojGenerisanihStanja, vremeSimulacije] = simulatorNewtonoveMehanike.simuliraj(poluprecnikDiska, m, newtonVremeSimulacije, newtonBrojDogadjaja, false);
            
            ukupnoGenerisanihStanja = ukupnoGenerisanihStanja + brojGenerisanihStanja;
            ukupnoVreme = ukupnoVreme + vremeSimulacije;
        end
        
        srednjiBrojGenerisanihStanjaPoVremenu(n - minN + 1) = ukupnoGenerisanihStanja / ukupnoVreme;
    end

    %% Plotovanje rezultata
    figure;
    plot(minN:maxN, srednjiBrojGenerisanihStanjaPoVremenu, '-o');
    xlabel('Broj polja u mreži (n)');
    ylabel('Prosečan broj generisanih stanja po jedinici vremena');
    title('Zavisnost broja generisanih stanja po jedinici vremena od broja polja u mreži');
    grid on;

    disp('----------------------------------');
end
