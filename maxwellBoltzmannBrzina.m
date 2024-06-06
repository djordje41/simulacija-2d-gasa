function v = maxwellBoltzmannBrzina(m, T, n)
    % maxwellBoltzmannBrzina generiše n slučajnih brzina koje prate
    % Maksvel-Bolcmanovu raspodelu za gas na temperaturi T sa masom čestice m.
    %
    % Ulazni parametri:
    %   m - masa čestice (kg)
    %   T - temperatura (K)
    %   n - broj slučajnih brzina koje treba generisati
    %
    % Izlaz:
    %   v - niz generisanih brzina (m/s)

    % Konstante
    k = 1.380649e-23; % Bolcmanova konstanta u J/K

    % Parametar skale za Maksvel-Bolcmanovu raspodelu
    a = sqrt(k * T / m);

    % Generisanje slučajnih brzina
    intenziteti = a * sqrt(chi2rnd(3, n, 1));
    
    % Generisanje slučajnih smerova
    theta = 2*pi*rand(n, 1);

    % Računanje x i y komponente brzine
    vx = intenziteti .* cos(theta);
    vy = intenziteti .* sin(theta);
    
    v = [vx vy];
end
