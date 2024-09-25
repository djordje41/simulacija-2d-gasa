function vrednost = maxellVrednostRaspodele(masa, temperatura, brzina)
%MAXELLVREDNOSTRASPODELE Vraca vrednost raspodele po intenzitetima brzina
%za zadate parametre.
    kB = 1.380649e-23; % Boltzmann-ova konstanta

    % Izracunavanje vrednosti raspodele
    vrednost = 4 * pi * (masa / (2 * pi * kB * temperatura))^(3/2) * ...
        brzina^2 * exp(-(masa * brzina^2) / (2 * kB * temperatura));
end