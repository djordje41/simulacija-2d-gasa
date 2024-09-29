function plotSimulacijaResults()
    % plotSimulacijaResults - Чита симулационе податке и приказује резултате осим Марков ланца.
    %
    % Ова функција чита претходно израчунате симулационе податке из CSV фајлова и MAT фајла,
    % затим креира графикон који приказује просечан број генерисаних валидних стања по времену
    % у зависности од броја дискова, искључујући резултате од Марков ланца.

    %% 1. Учитавање броја дискова из MAT фајла
    matData = load('simulacija_podaci.mat', 'opsegBrojaDiskova');
    opsegBrojaDiskova = matData.opsegBrojaDiskova;

    %% 2. Читање података из CSV фајлова
    try
        prosekBoltzmann = readmatrix('prosekStanjaPoVremenuBoltzmann.csv');
        prosekNewtonOpt = readmatrix('prosekStanjaPoVremenuNewtonOpt.csv');
        prosekNewtonNoOpt = readmatrix('prosekStanjaPoVremenuNewtonNoOpt.csv');
    catch ME
        error('Грешка при читању CSV фајлова: %s', ME.message);
    end

    %% 3. Плотовање резултата
    figure('Position', [200, 200, 800, 450]);
    hold on;

    % Плотовање Boltzmann Simulator
    plot(opsegBrojaDiskova, prosekBoltzmann, '-o', 'DisplayName', 'Direct sampling', 'Marker', 'o');

    % Плотовање Newton Simulator (Оптимизовано)
    plot(opsegBrojaDiskova, prosekNewtonOpt, '-s', 'DisplayName', 'Newton optimized', 'Marker', 's');

    % Плотовање Newton Simulator (Неоптимизовано)
    plot(opsegBrojaDiskova, prosekNewtonNoOpt, '-^', 'DisplayName', 'Newton unoptimized', 'Marker', '^');

    %% 4. Прилагођавање графикона
    xlabel('Broj diskova');
    ylabel('Prosečan broj generisanih validnih stanja po sekundi [s^{-1}]');
    title('Zavisnost prosečnog broja generisanih validnih stanja po sekundi od broja diskova');
    legend('Location', 'best');
    grid on;
    hold off;

    %% 5. Чување графикона (опционално)
    % Сачувајте графикон као PNG фајл
    % saveas(gcf, 'rezultati_simulacije.png');
end
