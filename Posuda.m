classdef Posuda
    properties
        % x koordinata levog zida u metrima [m]
        leviZid (1, 1) double {mustBeNumeric}
        % x koordinata desnog zida u metrima [m]
        desniZid (1, 1) double {mustBeNumeric}
        % y koordinata gornjeg zida u metrima [m]
        gornjiZid (1, 1) double {mustBeNumeric}
        % y koordinata donjeg zida u metrima [m]
        donjiZid (1, 1) double {mustBeNumeric}
        
        diskovi
        
        dozvoljenaGreska = 1e-12;
    end
    
    methods
        % Konstruktor
        function obj = Posuda(leviZid, desniZid, donjiZid, gornjiZid, diskovi)
            mustBeLess = leviZid < desniZid;
            if ~mustBeLess
                error('leviZid must be less than desniZid.');
            end
            
            mustBeLess = donjiZid < gornjiZid;
            if ~mustBeLess
                error('gornjiZid must be less than donjiZid.');
            end
            
            obj.leviZid = leviZid;
            obj.desniZid = desniZid;
            obj.gornjiZid = gornjiZid;
            obj.donjiZid = donjiZid;
            obj.diskovi = diskovi;
        end
        
        % Ova funkcija vraca obim posude
        function obim = obim(obj)
            obim =  2 * (obj.gornjiZid - obj.donjiZid + obj.desniZid - obj.leviZid);
        end
        
        % Puni posudu sa diskovima
        function diskovi = stvoriDiskovePoUzoru(obj, brojDiskova, disk)
            % Generisemo nasumicne koordinate centara diskova tako da se one
            % nalaze unutar posude i ne vire iz nje
            randomX = (obj.desniZid - obj.leviZid - 2*disk.poluprecnik) * rand(1, brojDiskova) + obj.leviZid + disk.poluprecnik;
            randomY = (obj.gornjiZid - obj.donjiZid - 2*disk.poluprecnik) * rand(1, brojDiskova) + obj.donjiZid + disk.poluprecnik;
            
            diskovi = [];
            
            % Kreiramo objekte diskova i dodajemo ih u posudu
            for i = 1:brojDiskova
                disk = Disk(disk.poluprecnik, disk.masa, disk.brzina, Koordinate(randomX(i), randomY(i)));
                diskovi = [diskovi, disk];
            end
        end
        
        % Puni posudu sa diskovima
        function diskovi = stvoriDiskove(obj, brojDiskova)
            % Generisemo nasumicne koordinate centara diskova tako da se one
            % nalaze unutar posude
            randomX = (obj.desniZid - obj.leviZid) * rand(1, brojDiskova) + obj.leviZid;
            randomY = (obj.donjiZid - obj.gornjiZid) * rand(1, brojDiskova) + obj.gornjiZid;
            
            diskovi = [];
            
            % Kreiramo objekte diskova i dodajemo ih u posudu
            for i = 1:brojDiskova
                disk = Disk(1, 1, Brzina(1, 1), Koordinate(randomX(i), randomY(i)));
                diskovi = [diskovi, disk];
            end
        end
        
        % Vraca matricu [brDiskova, 2], prva kolona je x koordinata centra
        % diska a druga kolona je y koordinata diska
        function coordinates = getKoordinateCentaraDiskova(obj)
            numDisks = numel(obj.diskovi);
            coordinates = zeros(numDisks, 2);
            
            for i = 1:numDisks
                coordinates(i, 1) = obj.diskovi(i).koordinate.x;
                coordinates(i, 2) = obj.diskovi(i).koordinate.y;
            end
        end
        
        % Vraca true ako disk viri izvan posude, inace vraca false
        function viri = diskViri(obj, disk)
            viri = false;

            if (((disk.koordinate.x + disk.poluprecnik) > obj.desniZid) || ...
                ((disk.koordinate.x - disk.poluprecnik) < obj.leviZid) || ...
                ((disk.koordinate.y + disk.poluprecnik) > obj.gornjiZid) || ...
                ((disk.koordinate.y - disk.poluprecnik) < obj.donjiZid))
                viri = true; 
            end
        end
        
        % Vraca true ako disk viri izvan posude, inace vraca false
        function viri = viriBaremJedan(obj)
            viri = false;

            for disk = obj.diskovi
                if (obj.diskViri(disk))
                    viri = true;
                    return;
                end
            end
        end
        
        % Vraca true ako disk viri izvan posude, inace vraca false
        function dodiruje = diskDodirujeZid(obj, disk)
            dodiruje = false;
            
            diskViri = obj.diskViri(disk);
            
            if (diskViri) 
%                 disp("Disk viri izvan posude");
                return;
            end
            
            if (((disk.koordinate.x + disk.poluprecnik) >= obj.desniZid - obj.dozvoljenaGreska) || ...
                ((disk.koordinate.x - disk.poluprecnik) <= obj.leviZid + obj.dozvoljenaGreska) || ...
                ((disk.koordinate.y + disk.poluprecnik) >= obj.gornjiZid - obj.dozvoljenaGreska) || ...
                ((disk.koordinate.y - disk.poluprecnik) <= obj.donjiZid + obj.dozvoljenaGreska))
                dodiruje = true;
            end
        end
        
        % Funkcija racuna vreme do sudara diska sa zidom ove posude
        function vreme = vremeDoSudaraSaZidom(obj, disk)
            diskViri = obj.diskViri(disk);
            
            if (diskViri) 
%                 disp("Disk viri izvan posude");
                vreme = -1;
                return;
            end
            
            vremeDoSudaraX = -1;  % Vx == 0
            vremeDoSudaraY = -1;  % Vy == 0
            
            if (disk.brzina.Vx > 0)
                vremeDoSudaraX = (obj.desniZid - (disk.koordinate.x + disk.poluprecnik)) ...
                    / disk.brzina.Vx;
            elseif (disk.brzina.Vx < 0)
                vremeDoSudaraX = ((disk.koordinate.x - disk.poluprecnik) - obj.leviZid) ...
                    / (-disk.brzina.Vx);
            end
            
            if (disk.brzina.Vy > 0)
                vremeDoSudaraY = (obj.gornjiZid - (disk.koordinate.y + disk.poluprecnik)) ...
                    / disk.brzina.Vy;
            elseif (disk.brzina.Vy < 0)
                vremeDoSudaraY = ((disk.koordinate.y - disk.poluprecnik) - obj.donjiZid) ...
                    / (-disk.brzina.Vy);
            end
            
            vremeDoSudara = [vremeDoSudaraX vremeDoSudaraY];
            
            vremeDoSudara = vremeDoSudara(vremeDoSudara ~= -1);
            
            vreme = min(vremeDoSudara);
        end
        
        % Funkcija izvrsava sudar diska sa zidom
        function disk = sudariSaZidom(obj, disk)
            diskDodiruje = obj.diskDodirujeZid(disk);
            
            if (~diskDodiruje) 
%                 disp("Disk nije u kontaktu za zidom");
                return;
            end
            
            dodirujeGornji = ((disk.koordinate.y + disk.poluprecnik) >= obj.gornjiZid - obj.dozvoljenaGreska) && ...
                ((disk.koordinate.y + disk.poluprecnik) <= obj.gornjiZid);
            dodirujeDonji = ((disk.koordinate.y - disk.poluprecnik) <= obj.donjiZid + obj.dozvoljenaGreska) && ...
                ((disk.koordinate.y - disk.poluprecnik) >= obj.donjiZid);
            dodirujeDesni = ((disk.koordinate.x + disk.poluprecnik) >= obj.desniZid - obj.dozvoljenaGreska) && ...
                ((disk.koordinate.x + disk.poluprecnik) <= obj.desniZid);
            dodirujeLevi = ((disk.koordinate.x - disk.poluprecnik) <= obj.leviZid + obj.dozvoljenaGreska) && ...
                ((disk.koordinate.x - disk.poluprecnik) >= obj.leviZid);
            
            if (dodirujeGornji && disk.brzina.Vy > 0)
                disk.brzina.Vy = -disk.brzina.Vy;
            end
            if (dodirujeDonji && disk.brzina.Vy < 0)
                disk.brzina.Vy = -disk.brzina.Vy;
            end
            if (dodirujeDesni && disk.brzina.Vx > 0)
                disk.brzina.Vx = -disk.brzina.Vx;
            end
            if (dodirujeLevi && disk.brzina.Vx < 0)
                disk.brzina.Vx = -disk.brzina.Vx;
            end
        end
        
        % Funkcija odredjuje za koliko ce se desiti prvi sudar sa zidom
        % Ako funkcija vrati -1, znaci da nece biti sudara
        function [vreme, index] = vremeDoSledecegSudaraSaZidom(obj)
            vreme = inf;
            
            index = -1;
            
            [~, brojDiskova] = size(obj.diskovi);
            
            for i = 1 : brojDiskova
                vremeDoSudara = obj.vremeDoSudaraSaZidom(obj.diskovi(i));
                
                if ((vremeDoSudara ~= -1) && (vremeDoSudara < vreme))
                    vreme = vremeDoSudara;
                    index = i;
                end
            end
            
            if (vreme == inf)
                vreme = -1;
                index = -1;
            end
        end
        
        % Funkcija odredjuje za koliko ce se desiti prvi sudar dva diska
        % Ako funkcija vrati -1, znaci da nece biti sudara
        function [vreme, index1, index2] = vremeDoSledecegSudaraDvaDiska(obj)
            vreme = inf;
            
            [~, brojDiskova] = size(obj.diskovi);
            
            index1 = -1;
            index2 = -1;

            for i = 1 : brojDiskova - 1
                for j = i + 1 : brojDiskova
                    vremeDoSudara = obj.diskovi(i).vremeDoSudara(obj.diskovi(j));
                    
                    if ((vremeDoSudara ~= -1) && (vremeDoSudara < vreme))
                        vreme = vremeDoSudara;
                        
                        index1 = i;
                        index2 = j;
                    end
                end
            end
            
            if (vreme == inf)
                vreme = -1; 
            end
        end
        
        function impuls = impulsNaZid(obj, disk)
            diskDodiruje = obj.diskDodirujeZid(disk);
            impuls = 0;
            
            if (~diskDodiruje) 
%                 disp("Disk nije u kontaktu za zidom");
                return;
            end
            
            dodirujeGornji = ((disk.koordinate.y + disk.poluprecnik) >= obj.gornjiZid - obj.dozvoljenaGreska) && ...
                ((disk.koordinate.y + disk.poluprecnik) <= obj.gornjiZid);
            dodirujeDonji = ((disk.koordinate.y - disk.poluprecnik) <= obj.donjiZid + obj.dozvoljenaGreska) && ...
                ((disk.koordinate.y - disk.poluprecnik) >= obj.donjiZid);
            dodirujeDesni = ((disk.koordinate.x + disk.poluprecnik) >= obj.desniZid - obj.dozvoljenaGreska) && ...
                ((disk.koordinate.x + disk.poluprecnik) <= obj.desniZid);
            dodirujeLevi = ((disk.koordinate.x - disk.poluprecnik) <= obj.leviZid + obj.dozvoljenaGreska) && ...
                ((disk.koordinate.x - disk.poluprecnik) >= obj.leviZid);
            
            if (dodirujeGornji && disk.brzina.Vy > 0)
                impuls = impuls + abs(disk.brzina.Vy) * disk.masa;
            end
            if (dodirujeDonji && disk.brzina.Vy < 0)
                impuls = impuls + abs(disk.brzina.Vy) * disk.masa;
            end
            if (dodirujeDesni && disk.brzina.Vx > 0)
                impuls = impuls + abs(disk.brzina.Vx) * disk.masa;
            end
            if (dodirujeLevi && disk.brzina.Vx < 0)
                impuls = impuls + abs(disk.brzina.Vx) * disk.masa;
            end
        end
    end
end
