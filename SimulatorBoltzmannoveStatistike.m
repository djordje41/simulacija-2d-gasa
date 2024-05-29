classdef SimulatorBoltzmannoveStatistike
    properties
        posuda
    end
    
    methods
        function obj = SimulatorBoltzmannoveStatistike(posuda)
            obj.posuda = posuda;
        end
        
        function prvaValidnaKonfiguracija = simuliraj(obj, brojDiskova, poluprecnik, brojPokusaja)
            tic;
            
            prvaValidnaKonfiguracija = false;
            
            rezultantneKoordinate = zeros(brojDiskova, 10000);
            rezultatIndex = 1;
            
            for i = 1 : brojPokusaja
                obj.posuda.diskovi = obj.posuda.stvoriDiskovePoUzoru(brojDiskova, Disk(poluprecnik, 1, Brzina(0, 0), Koordinate(0, 0)));
                
                koordinate = obj.posuda.getKoordinateCentaraDiskova();
                
                if (~Disk.seceSeBaremJedan(obj.posuda.diskovi))
                    rezultantneKoordinate(:, rezultatIndex : rezultatIndex + 1) = koordinate;
                    rezultatIndex = rezultatIndex + 2;
                    
                    if (~prvaValidnaKonfiguracija)
                        csvwrite('coordinates.csv', koordinate);
                        prvaValidnaKonfiguracija = koordinate;
                    end
                end
            end
            
            rezultantneKoordinate = rezultantneKoordinate(:, 1 : rezultatIndex - 1);
            
            csvwrite('boltzmanResult.csv', rezultantneKoordinate);
            
            protekloVreme = toc;
            
            disp('Rezultati Boltzmanove metode: ');
            disp(['Broj pokusaja: ', num2str(brojPokusaja)]);
            disp(['Broj generisanih validnih stanja: ', num2str((rezultatIndex - 1) / 2)]);
            disp(['Proteklo vreme: ', num2str(protekloVreme), 's']);
        end
    end
end