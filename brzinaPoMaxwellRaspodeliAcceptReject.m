function brzine = brzinaPoMaxwellRaspodeliAcceptReject(brojBrzina, masa, temperatura)
%BRZINAPOMAXELLRASPODELIACCEPTREJECT generise brojBrzina nasumicnih
%intenziteta brzina po Maxwell-ovoj raspodeli po intenzitetima brzina
%koristeci accept/reject metodu.
    kB = 1.380649e-23; %Boltzmann-ova konstanta

    sigma = sqrt(kB * temperatura / masa);
    
    najverovatnijaBrzina = sqrt(2 * kB * temperatura / masa);

    maksimalnaVrednostRaspodele = maxellVrednostRaspodele(masa, temperatura, najverovatnijaBrzina);
    
    brzine = zeros(brojBrzina, 1);
    
    for i = 1 : brojBrzina
        generisanaBrzina = -1;
        
        while generisanaBrzina == -1
            generisanaBrzina = rand * 5 * sigma;
            accept = rand * maksimalnaVrednostRaspodele;
            
            if (accept < maxellVrednostRaspodele(masa, temperatura, generisanaBrzina))
                break;
            else
                generisanaBrzina = -1;
            end
        end
        
        brzine(i) = generisanaBrzina;
    end
end

