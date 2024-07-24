%% Test Maxwell Boltzman raspodela
testirajMaxwellBoltzmannRaspodelu();

%% Inicijalizacija promenljivih
sirinaPosude = 0.1; %[m]
visinaPosude = 0.1; %[m]

m = 6.6464731e-27; % Masa atoma He u [kg]
poluprecnikDiska = 1.04e-13; % Poluprecnik atoma He u [m]

brojDiskova = 100;
bolzmannBrojPokusaja = 100;

newtonVremeSimulacije = 5000;
newtonBrojDogadjaja = 100;

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
simulatorNewtonoveMehanike.simuliraj(poluprecnikDiska, m, newtonVremeSimulacije, newtonBrojDogadjaja, false);

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

statistikaPoluprecnikBrojDiskova(posuda);
statistikaBrojaDiskova(posuda);

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
