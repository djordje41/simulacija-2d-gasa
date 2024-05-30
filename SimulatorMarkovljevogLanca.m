classdef SimulatorMarkovljevogLanca
    %SIMULATORMARKOVLJEVOGLANCA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        posuda
    end
    
    methods
        function obj = SimulatorMarkovljevogLanca(posuda)
            %SIMULATORMARKOVLJEVOGLANCA Construct an instance of this class
            %   Detailed explanation goes here
            obj.posuda = posuda;
        end
        
        function outputArg = simuliraj(obj, poluprecnikDiska, brojPokusaja)
            koordinate = csvread("coordinates.csv");
            
            % Pokreni merenje vremena
            tic;
            
            [brojKoordinata, ~] = size(koordinate);
            
            rezultantneKoordinate = zeros(brojKoordinata, (brojPokusaja + 1) * 2);
            
            rezultantneKoordinate(1 : end, 1 : 2) = koordinate;
            
            for i = 1 : brojKoordinata
                diskovi(i) = Disk(poluprecnikDiska, 1e-20, Brzina(0, 0), ...
                    Koordinate(koordinate(i, 1), koordinate(i, 2)));
            end
            
            brojValidnihStanja = 1;
            indexRezultata = 3;
            
            for i = 1 : brojPokusaja
                randomIndex = ceil(rand * brojKoordinata);
                
                kopijaKoordinata = diskovi(randomIndex).koordinate;
                
                % Neka se centar diska pomera pravolinijski od 0 do R
                % (precnik diska)
                rastojanje = rand * 2 * poluprecnikDiska;
                
                % Racunamo sada polarni ugao (od 0 do 2pi)
                rho = rand * 2 * pi;
                
                deltaX = rastojanje * cos(rho);
                deltaY = rastojanje * sin(rho);
                
                diskovi(randomIndex).koordinate = Koordinate(...
                    diskovi(randomIndex).koordinate.x + deltaX, ...
                    diskovi(randomIndex).koordinate.y + deltaY);
                
                if (~diskovi(randomIndex).seceBaremJedan(diskovi([1:randomIndex-1, randomIndex+1:end])))
                    brojValidnihStanja = brojValidnihStanja + 1;
                    
                    for j = 1 : brojKoordinata
                        rezultantneKoordinate(j, indexRezultata : indexRezultata + 1) = ...
                            [diskovi(j).koordinate.x, diskovi(j).koordinate.y];
                    end
                    
                    indexRezultata = indexRezultata + 2;
                end
            end
            
            rezultantneKoordinate = rezultantneKoordinate(:, 1 : indexRezultata - 1);
            
            csvwrite('markovChainResult.csv', rezultantneKoordinate);
            
            protekloVreme = toc;
            
            disp('Rezultati Markovljevog lanca: ');
            disp(['Broj pokusaja: ', num2str(brojPokusaja)]);
            disp(['Broj generisanih validnih stanja: ', num2str(brojValidnihStanja - 1)]);
            disp(['Proteklo vreme: ', num2str(protekloVreme), 's']);
        end
    end
end

