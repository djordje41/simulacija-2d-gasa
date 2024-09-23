classdef SimulatorNewtonoveMehanike
    properties
        posuda
    end
    
    methods
        function obj = SimulatorNewtonoveMehanike(posuda)
            obj.posuda = posuda;
        end
        
        function [brojGenerisanihStanja, vremeSimulacije] = simuliraj(obj, poluprecnikDiska, masaDiska, vreme, maxBrojDogadjaja, prikaziDebug, optimize)
            if nargin < 4
                maxBrojDogadjaja = -1;
            end
            
            if nargin < 5
                prikaziDebug = false;
            end
            
            if nargin < 6
                optimize = true;
            end

            koordinate = csvread("coordinates.csv");
            
            % Pokreni merenje vremena
            tic;
            
            [brojKoordinata, ~] = size(koordinate);
            
            % prvi red (+1) ce nam posluziti za cuvanje trenutka u vremenu
            rezultantneKoordinate = zeros(brojKoordinata + 1, 10000);
            
            rezultantanPritisak = zeros(2, 10000);
            indexPritisak = 1;
            vremePritisak = 0;
            
            rezultantneKoordinate(2 : end, 1 : 2) = koordinate;
            
            for i = 1 : brojKoordinata
                V = maxwellBoltzmannBrzina(masaDiska, 300, 1);
                
                diskovi(i) = Disk(poluprecnikDiska, masaDiska, Brzina(V(1), V(2)), ...
                    Koordinate(koordinate(i, 1), koordinate(i, 2)));
            end
            
            obj.posuda.diskovi = diskovi;
            
            if optimize
                obj.posuda = obj.posuda.inicijalizujNadolazecaVremenaSudara();
                obj.posuda = obj.posuda.azurirajVremenaNadolazecihSudara(); 
            end
            
            brojRezultataIndex = 3;
            brojDogadjaja = 0;
            ukupnoVreme = vreme;
                 
            while vreme > 0 && (maxBrojDogadjaja == -1 || brojDogadjaja < maxBrojDogadjaja)
                if prikaziDebug
                    disp("Proteklo vreme: " + (ukupnoVreme - vreme));
                    disp("-");
                end
                
                [vremeDiskZid, index] = obj.posuda.vremeDoSledecegSudaraSaZidom(optimize);
                [vremeDiskDisk, index1, index2] = obj.posuda.vremeDoSledecegSudaraDvaDiska(optimize);
                
                vremena = [vremeDiskZid vremeDiskDisk];
                
                vremena = vremena(vremena ~= - 1);
                
                if (isempty(vremena))
                    disp("Nema narednog sudara");
                    break;
                end
                
                vremeTranslacije = min(vremena);
                
                korigovanoVremeTranslacijeDisk = vremeTranslacije;
                korigovanoVremeTranslacijeZid = vremeTranslacije;
                
                if (vremeTranslacije == vremeDiskDisk)
                    d1 = obj.posuda.diskovi(index1).transliraj(korigovanoVremeTranslacijeDisk);
                    d2 = obj.posuda.diskovi(index2).transliraj(korigovanoVremeTranslacijeDisk);
                    pocetnoSmanjenje = 0.5e-13;
                    
                    while (d1.sece(d2) || ~d1.dodiruje(d2))
                        if (d1.sece(d2))
                            if (prikaziDebug)
                                disp('sece')
                                disp(1000000000000000 * (d1.koordinate.rastojanje(d2.koordinate) - (d1.poluprecnik + d2.poluprecnik))); 
                            end
                            korigovanoVremeTranslacijeDisk = korigovanoVremeTranslacijeDisk - pocetnoSmanjenje;
                        elseif (~d1.dodiruje(d2))
                            if (prikaziDebug)
                                disp('ne dodiruje')
                                disp(1000000000000000 * (d1.koordinate.rastojanje(d2.koordinate) - (d1.poluprecnik + d2.poluprecnik)));
                            end
                            korigovanoVremeTranslacijeDisk = korigovanoVremeTranslacijeDisk + pocetnoSmanjenje;
                        end
                        
                        pocetnoSmanjenje = pocetnoSmanjenje / 1.1;
                        d1 = obj.posuda.diskovi(index1).transliraj(korigovanoVremeTranslacijeDisk);
                        d2 = obj.posuda.diskovi(index2).transliraj(korigovanoVremeTranslacijeDisk);
                    end
                end
                
                if (vremeTranslacije == vremeDiskZid)
                    d1 = obj.posuda.diskovi(index).transliraj(korigovanoVremeTranslacijeZid);
                    pocetnoSmanjenje = 0.5e-13;

                    while (~obj.posuda.diskDodirujeZid(d1) || obj.posuda.diskViri(d1))
                        if (obj.posuda.diskViri(d1))
                            if (prikaziDebug)
                                disp('Viri')
                            end
                            korigovanoVremeTranslacijeZid = korigovanoVremeTranslacijeZid - pocetnoSmanjenje;
                        elseif (~obj.posuda.diskDodirujeZid(d1))
                            if (prikaziDebug)
                                disp('Ne dodiruje')
                            end
                            korigovanoVremeTranslacijeZid = korigovanoVremeTranslacijeZid + pocetnoSmanjenje;
                        end
                        
                        pocetnoSmanjenje = pocetnoSmanjenje / 1.1;
                        d1 = obj.posuda.diskovi(index).transliraj(korigovanoVremeTranslacijeZid);
                    end
                end
                
                vremeTranslacije = min(korigovanoVremeTranslacijeZid, korigovanoVremeTranslacijeDisk);
                
                if optimize
                    obj.posuda = obj.posuda.smanjiVremenaNadolazecihSudara(vremeTranslacije); 
                end

                for i = 1 : brojKoordinata
                    obj.posuda.diskovi(i) = obj.posuda.diskovi(i).transliraj(vremeTranslacije);
                end
                
                for i = Disk.diskoviKojiSeSeku(obj.posuda.diskovi)
                    disp(i.brzina)
                    disp(i.koordinate)
                end
                 
                if (vremeDiskDisk ~= -1 && (vremeDiskZid >= vremeDiskDisk || vremeDiskZid == -1))
                    if (prikaziDebug)
                        disp("Sudar dva diska");
                    end
                    [obj.posuda.diskovi(index1), obj.posuda.diskovi(index2)] = ... 
                        obj.posuda.diskovi(index1).izvrsiSudar3(obj.posuda.diskovi(index2));
                    
                    if optimize
                        obj.posuda = obj.posuda.azurirajVremenaNadolazecihSudara([index1, index2]); 
                    end
                end
                
                if (vremeDiskZid ~= -1 && (vremeDiskZid <= vremeDiskDisk || vremeDiskDisk == -1))
                    if (prikaziDebug)
                        disp("Sudar diska sa zidom"); 
                    end
                    % Ovde cuvamo podatke koje cemo koristiti za racunanje
                    % pritiska gasa na zidove posude
                    vremePritisak = vremePritisak + vremeTranslacije;
                    impulsNaZid = obj.posuda.impulsNaZid(obj.posuda.diskovi(index));
                    rezultantanPritisak(1, indexPritisak) = impulsNaZid;
                    rezultantanPritisak(2, indexPritisak) = vremePritisak;
                    indexPritisak = indexPritisak + 1;
                    
                    % Azuriramo brziju diska koji se sudario sa zidom
                    obj.posuda.diskovi(index) = obj.posuda.sudariSaZidom(obj.posuda.diskovi(index));
                    
                    if optimize
                        obj.posuda = obj.posuda.azurirajVremenaNadolazecihSudara(index); 
                    end
                end
                
                vreme = vreme - vremeTranslacije;
                brojDogadjaja = brojDogadjaja + 1;
                
                rezultantneKoordinate(2 : end, brojRezultataIndex : brojRezultataIndex + 1) = obj.posuda.getKoordinateCentaraDiskova();
                rezultantneKoordinate(1, brojRezultataIndex : brojRezultataIndex + 1) = ukupnoVreme - vreme;
                
                brojRezultataIndex = brojRezultataIndex + 2;
            end
            
            rezultantneKoordinate = rezultantneKoordinate(:, 1 : brojRezultataIndex - 1);
            rezultantanPritisak = rezultantanPritisak(:, 1 : indexPritisak - 1);
            
            vremeSimulacije = toc;
            brojGenerisanihStanja = floor(brojRezultataIndex / 2);
            
            fprintf('Ukupno vreme simulacije: %.6f sekunde\n', vremeSimulacije);
            fprintf('Ukupan broj validnih pozicija diskova: %d\n', floor(brojRezultataIndex / 2));
             
            csvwrite('newtonResult.csv', rezultantneKoordinate);
            csvwrite('newtonResultPressure.csv', rezultantanPritisak);
        end
    end
end