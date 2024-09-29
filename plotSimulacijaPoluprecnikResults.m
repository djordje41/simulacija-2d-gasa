function plotSimulacijaPoluprecnikResults()
    % plotSimulacijaPoluprecnikResults - Чита симулационе податке и приказује резултате.
    %
    % Ова функција чита претходно израчунате симулационе податке из CSV фајлова и MAT фајла,
    % затим креира графикон који приказује просечан број генерисаних валидних стања по времену
    % у зависности од полупречника диска.

    %% 1. Учитавање опсега полупречника диска из MAT фајла
    matData = load('simulacija_podaci_poluprecnik.mat', 'opsegPoluprecnikaDiskova');
    opsegPoluprecnikaDiskova = matData.opsegPoluprecnikaDiskova;

    %% 2. Читање података из CSV фајлова
    try
        boltzmannData = readmatrix('prosekStanjaPoVremenuBoltzmannPoluprecnik.csv');
        newtonOptData = readmatrix('prosekStanjaPoVremenuNewtonOptPoluprecnik.csv');
        newtonNoOptData = readmatrix('prosekStanjaPoVremenuNewtonNoOptPoluprecnik.csv');
        markovData = readmatrix('prosekStanjaPoVremenuMarkovPoluprecnik.csv');
    catch ME
        error('Грешка при читању CSV фајлова: %s', ME.message);
    end

    %% 3. Екстракција просечног броја генерисаних стања по времену
    % Претпоставља се да CSV фајлови имају две колоне: полупречник диска и просечан број стања по времену

    % Екстракција података
    boltzmannRadius = boltzmannData(:,1);
    prosekBoltzmann = boltzmannData(:,2);

    newtonOptRadius = newtonOptData(:,1);
    prosekNewtonOpt = newtonOptData(:,2);

    newtonNoOptRadius = newtonNoOptData(:,1);
    prosekNewtonNoOpt = newtonNoOptData(:,2);

    markovRadius = markovData(:,1);
    prosekMarkov = markovData(:,2);

    % Провера да ли се вредности полупречника слажу
    if ~isequal(boltzmannRadius, opsegPoluprecnikaDiskova) || ...
       ~isequal(newtonOptRadius, opsegPoluprecnikaDiskova) || ...
       ~isequal(newtonNoOptRadius, opsegPoluprecnikaDiskova) || ...
       ~isequal(markovRadius, opsegPoluprecnikaDiskova)
        warning('Вредности полупречника диска у CSV фајловима се не слажу са опсегом.');
    end

    %% 4. Плотовање резултата
    figure('Position', [200, 200, 800, 450]);
    hold on;

    % Плотовање Boltzmann симулатора
    plot(opsegPoluprecnikaDiskova, prosekBoltzmann, '-o', 'DisplayName', 'Direct sampling', 'Marker', 'o');

    % Плотовање Newton симулатора (оптимизованог)
    plot(opsegPoluprecnikaDiskova, prosekNewtonOpt, '-s', 'DisplayName', 'Newton optimized', 'Marker', 's');

    % Плотовање Newton симулатора (неоптимизованог)
    plot(opsegPoluprecnikaDiskova, prosekNewtonNoOpt, '-^', 'DisplayName', 'Newton unoptimized', 'Marker', '^');

    % Плотовање Markov ланца
    % plot(opsegPoluprecnikaDiskova, prosekMarkov, '-d', 'DisplayName', 'Markov chain', 'Marker', 'd');

    %% 5. Прилагођавање графикона
    xlabel('Poluprečnik diska [m]');
    ylabel('Prosečan broj generisanih validnih stanja po sekundi [s^{-1}]');
    title('Zavisnost prosečnog broja generisanih validnih stanja po sekundi od poluprečnika diska');
    legend('Location', 'best');
    grid on;
    hold off;

    %% 6. Чување графикона (опционално)
    % Сачувајте графикон као PNG фајл
    % saveas(gcf, 'rezultati_simulacije_poluprecnik.png');
end
