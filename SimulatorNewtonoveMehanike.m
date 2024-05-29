classdef SimulatorNewtonoveMehanike
    properties
        posuda
    end
    
    methods
        function obj = SimulatorNewtonoveMehanike(posuda)
            obj.posuda = posuda;
        end
        
        function simuliraj(obj, poluprecnikDiska, vreme)
            koordinate = csvread("coordinates.csv");
            
            % Pokreni merenje vremena
            tic;
            
            [brojKoordinata, ~] = size(koordinate);
            
            % prvi red (+1) ce nam posluziti za cuvanje trenutka u vremenu
            rezultantneKoordinate = zeros(brojKoordinata + 1, 10000);
            
            rezultantneKoordinate(2 : end, 1 : 2) = koordinate;
            
            for i = 1 : brojKoordinata
                diskovi(i) = Disk(poluprecnikDiska, 1, Brzina(5 - rand * 10, 5 - rand * 10), ...
                    Koordinate(koordinate(i, 1), koordinate(i, 2)));
            end
            
            obj.posuda.diskovi = diskovi;
            
            brojRezultataIndex = 3;
            
            ukupnoVreme = vreme;
                 
            while vreme > 0
%                 disp("Proteklo vreme: " + (ukupnoVreme - vreme));
%                 disp("-");
                
                [vremeDiskZid, index] = obj.posuda.vremeDoSledecegSudaraSaZidom();
                [vremeDiskDisk, index1, index2] = obj.posuda.vremeDoSledecegSudaraDvaDiska();
                
                vremena = [vremeDiskZid vremeDiskDisk];
                
                vremena = vremena(vremena ~= - 1);
                
                if (isempty(vremena))
                    disp("Nema narednog sudara");
                    return;
                end
                
                vremeTranslacije = min(vremena);
                
                korigovanoVremeTranslacijeDisk = vremeTranslacije;
                korigovanoVremeTranslacijeZid = vremeTranslacije;
                
                % Ovde vrsimo korekciju vremena translacije zbog toga sto
                % matlab gresi u 15. decimali i moze se desiti da diskovu
                % malo udju jedan u drugi, ovde malo korigujemo vreme
                % translacije kako diskovi ne bi usli jedan u drugi, vec
                % kako bi bili veoma blizu jedan drugog sto cemo tretirati
                % kao sudar.
                if (vremeTranslacije == vremeDiskDisk)
                    d1 = obj.posuda.diskovi(index1).transliraj(korigovanoVremeTranslacijeDisk);
                    d2 = obj.posuda.diskovi(index2).transliraj(korigovanoVremeTranslacijeDisk);
                    pocetnoSmanjenje = 1e-13;
                    
                    while (d1.sece(d2) || ~d1.dodiruje(d2))
                        if (d1.sece(d2))
%                             disp('sece')
%                             disp(1000000000000000 * (d1.koordinate.rastojanje(d2.koordinate) - (d1.poluprecnik + d2.poluprecnik)));
                            korigovanoVremeTranslacijeDisk = korigovanoVremeTranslacijeDisk - pocetnoSmanjenje;
                        elseif (~d1.dodiruje(d2))
%                             disp('ne dodiruje')
%                             disp(1000000000000000 * (d1.koordinate.rastojanje(d2.koordinate) - (d1.poluprecnik + d2.poluprecnik)));
                            korigovanoVremeTranslacijeDisk = korigovanoVremeTranslacijeDisk + pocetnoSmanjenje;
                        end
                        
                        pocetnoSmanjenje = pocetnoSmanjenje / 2;
                        d1 = obj.posuda.diskovi(index1).transliraj(korigovanoVremeTranslacijeDisk);
                        d2 = obj.posuda.diskovi(index2).transliraj(korigovanoVremeTranslacijeDisk);
                    end
                end
                
                % Ovde radimo nesto slicno samo za zid
                if (vremeTranslacije == vremeDiskZid)
                    d1 = obj.posuda.diskovi(index).transliraj(korigovanoVremeTranslacijeZid);
                    pocetnoSmanjenje = 1e-13;

                    while (~obj.posuda.diskDodirujeZid(d1) || obj.posuda.diskViri(d1))
                        if (obj.posuda.diskViri(d1))
%                             disp('Viri')
                            korigovanoVremeTranslacijeZid = korigovanoVremeTranslacijeZid - pocetnoSmanjenje;
                        elseif (~obj.posuda.diskDodirujeZid(d1))
%                             disp('Ne dodiruje')
                            korigovanoVremeTranslacijeZid = korigovanoVremeTranslacijeZid + pocetnoSmanjenje;
                        end
                        
                        pocetnoSmanjenje = pocetnoSmanjenje / 2;
                        d1 = obj.posuda.diskovi(index).transliraj(korigovanoVremeTranslacijeZid);
                    end
                end
                
                vremeTranslacije = min(korigovanoVremeTranslacijeZid, korigovanoVremeTranslacijeDisk);

                for i = 1 : brojKoordinata
                    obj.posuda.diskovi(i) = obj.posuda.diskovi(i).transliraj(vremeTranslacije);
                end
                
                for i = Disk.diskoviKojiSeSeku(obj.posuda.diskovi)'
                    disp(i.brzina)
                    disp(i.koordinate)
                end
                 
                if (vremeDiskDisk ~= -1 && (vremeDiskZid >= vremeDiskDisk || vremeDiskZid == -1))
%                     disp("Sudar dva diska");
                    [obj.posuda.diskovi(index1), obj.posuda.diskovi(index2)] = ... 
                        obj.posuda.diskovi(index1).izvrsiSudar3(obj.posuda.diskovi(index2));
                end
                
                if (vremeDiskZid ~= -1 && (vremeDiskZid <= vremeDiskDisk || vremeDiskDisk == -1))
%                     disp("Sudar diska sa zidom");
                    obj.posuda.diskovi(index) = obj.posuda.sudariSaZidom(obj.posuda.diskovi(index));
                end
                
                vreme = vreme - vremeTranslacije;
                
                rezultantneKoordinate(2 : end, brojRezultataIndex : brojRezultataIndex + 1) = obj.posuda.getKoordinateCentaraDiskova();
                rezultantneKoordinate(1, brojRezultataIndex : brojRezultataIndex + 1) = ukupnoVreme - vreme;
                
                brojRezultataIndex = brojRezultataIndex + 2;
            end
            
            rezultantneKoordinate = rezultantneKoordinate(:, 1 : brojRezultataIndex - 1);
            
            vremeSimulacije = toc;
            
            fprintf('Ukupno vreme simulacije: %.6f sekude\n', vremeSimulacije);
            fprintf('Ukupan broj validnih pozicija diskova: %d\n', round(brojRezultataIndex / 2));
             
            csvwrite('newtonResult.csv', rezultantneKoordinate);
        end
    end
end