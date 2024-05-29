classdef Disk
    properties
        % poluprecnik diska u metrima [m]
        poluprecnik (1, 1) double {mustBeNumeric, mustBeNonnegative}
        % masa diska u gramima [g]
        masa (1, 1) double {mustBeNumeric, mustBeNonnegative}
        % brzina diska u metrima po sekundi [m/s]
        brzina
        % koordinate centra diska u metrima [x, y]
        koordinate
    end
    
    methods
        % Konstruktor
        function obj = Disk(poluprecnik, masa, brzina, koordinate)
            % Validacija podataka
            if ~isa(brzina, 'Brzina')
                error('brzina must be type of Brzina');
            end
            if ~isa(koordinate, 'Koordinate')
                error('koordinate must be type of Koordinate');
            end
            
            % Popunjavanje objekta
            obj.poluprecnik = poluprecnik;
            obj.masa = masa;
            obj.brzina = brzina;
            obj.koordinate = koordinate;
        end
        
        % Vrace true ako se dva diska seku, u suprotnom vraca false
        function sece = sece(obj, disk)
            sece = false;
            rastojanjeIzmedjuCentara = disk.koordinate.rastojanje(obj.koordinate);
            
            if (rastojanjeIzmedjuCentara < (obj.poluprecnik + disk.poluprecnik))
                sece = true;
            end
        end
        
        % Vrace true ako se dva diska dodiruju, u suprotnom vraca false.
        % Dozvoljada da se rastojanje centara diskova nadje u opsegu zbira
        % poluprecnika i zbira poluprecnika i dozvoljene greske (ustupak se
        % uvodi jer matlab gresi posle 15. decimale).
        function dodiruje = dodiruje(obj, disk)
            dozvoljenaGreska = 1e-12;
            
            dodiruje = false;
            
            % Rastojanje izmedju koordinata cemtara dva diska
            d = disk.koordinate.rastojanje(obj.koordinate);
            
            if (d >= (obj.poluprecnik + disk.poluprecnik) && ...
                d <= (obj.poluprecnik + disk.poluprecnik + dozvoljenaGreska))
                dodiruje = true;
            end
        end
        
        % Podesava koordinate centra diska na vrednosti na kojima ce se
        % njegov centar naci za zadato vreme
        function obj = transliraj(obj, vreme)
            obj.koordinate.x = obj.koordinate.x + obj.brzina.Vx * vreme;
            obj.koordinate.y = obj.koordinate.y + obj.brzina.Vy * vreme;
        end
        
        % Vraca vreme do sudara ovog diska sa zadatim u sekundama.
        % U slucaju da se sudar nece desiti, vraca -1;
        function vreme = vremeDoSudara(obj, disk)
            if (obj.sece(disk))
                disp(obj.koordinate)
                disp(disk.koordinate)
                error('Diskovi se seku!'); 
            end
            
            deltaX = obj.koordinate.x - disk.koordinate.x;
            deltaY = obj.koordinate.y - disk.koordinate.y;
            
            deltaVx = obj.brzina.Vx - disk.brzina.Vx;
            deltaVy = obj.brzina.Vy - disk.brzina.Vy;
            
            parametri = [ ...
                deltaVx^2 + deltaVy^2, ...
                2 * (deltaX * deltaVx + deltaY * deltaVy), ...
                deltaX^2 + deltaY^2 - (obj.poluprecnik + disk.poluprecnik)^2 ...
            ];
            
            t = roots(parametri);
            
            vreme = Disk.prilagodiVremeSudara(t);
            
            if (vreme < 0 && vreme ~= -1)
                vreme = 0;
%                 disp(obj.sece(disk));
%                 disp(obj.dodiruje(disk));
%                 error('Im outt');
            end
        end
        
        % Izvrsava sudar dva diska, menja njihovu brzinu uzimajuci u obzir
        % zakon odrzanja impulsa i pod pretpostavkom da je sudar elastican
        % https://williamecraver.wixsite.com/elastic-equations
        % DEPRICATED
        function [obj, disk] = izvrsiSudar(obj, disk)
            pragTolerancije = 1e-10;

            if (abs((obj.poluprecnik + disk.poluprecnik) - ...
                    obj.koordinate.rastojanje(disk.koordinate)) > pragTolerancije) 
                disp("Diskovi se ne dodiruju");
                return;
            end
            
            m1 = obj.masa; m2 = disk.masa;
            
            V1u = obj.brzina.getIntensity();
            V2u = disk.brzina.getIntensity();
            
            V1ux = obj.brzina.Vx;
            V1uy = obj.brzina.Vy;
            
            V2ux = disk.brzina.Vx;
            V2uy = disk.brzina.Vy;
            
            theta1 = atan(V1uy / V1ux);
            theta2 = atan(V2uy / V2ux);
            
            phi = atan((obj.koordinate.y - disk.koordinate.y) / ...
                (obj.koordinate.x - disk.koordinate.x));

%             V1ix = (cos(phi) / (m1 + m2)) * (V1u * cos(theta1 - phi) * (m1 - m2) + 2 * m2 * V2u * cos(theta2 - phi)) + ...
%                 V1u * sin(theta1 - phi) * cos(phi + pi/2);
%             
%             V1iy = (sin(phi) / (m1 + m2)) * (V1u * cos(theta1 - phi) * (m1 - m2) + 2 * m2 * V2u * cos(theta2 - phi)) + ...
%                 V1u * sin(theta1 - phi) * sin(phi + pi/2);
%             
%             V2ix = (cos(phi) / (m1 + m2)) * (V2u * cos(theta2 - phi) * (m2 - m1) + 2 * m1 * V1u * cos(theta1 - phi)) + ...
%                 V2u * sin(theta2 - phi) * cos(phi + pi/2);
%             
%             V2iy = (sin(phi) / (m1 + m2)) * (V2u * cos(theta2 - phi) * (m2 - m1) + 2 * m1 * V1u * cos(theta1 - phi)) + ...
%                 V2u * sin(theta2 - phi) * sin(phi + pi/2);
            
            V1ix = (cos(phi) / (m1 + m2)) * (V1u * cos(theta1 + phi) * (m1 - m2) + 2 * m2 * V2u * cos(theta2 + phi)) + ...
                V1u * sin(theta1 + phi) * cos(phi + pi/2);
            
            V1iy = (sin(phi) / (m1 + m2)) * (V1u * cos(theta1 + phi) * (m1 - m2) + 2 * m2 * V2u * cos(theta2 + phi)) + ...
                V1u * sin(theta1 + phi) * sin(phi + pi/2);
            
            V2ix = (cos(phi) / (m1 + m2)) * (V2u * cos(theta2 + phi) * (m2 - m1) + 2 * m1 * V1u * cos(theta1 + phi)) + ...
                V2u * sin(theta2 + phi) * cos(phi + pi/2);
            
            V2iy = (sin(phi) / (m1 + m2)) * (V2u * cos(theta2 + phi) * (m2 - m1) + 2 * m1 * V1u * cos(theta1 + phi)) + ...
                V2u * sin(theta2 + phi) * sin(phi + pi/2);
            
            % Ova korekcija se mora izvrsiti, verovatno zbog racunanja
            % uglova ranije
            if (V1ux > 0)
                V1ix = -V1ix;
                V1iy = -V1iy;
            else
                V2ix = -V2ix;
                V2iy = -V2iy;
            end
            
            obj.brzina.Vx = V1ix;
            obj.brzina.Vy = V1iy;
            
            disk.brzina.Vx = V2ix;
            disk.brzina.Vy = V2iy;
        end
        
        % Pokusaj 2
        % DEPRICATED
        function [obj, disk] = izvrsiSudar2(obj, disk)
            pragTolerancije = 1e-10;

            if (abs((obj.poluprecnik + disk.poluprecnik) - ...
                    obj.koordinate.rastojanje(disk.koordinate)) > pragTolerancije) 
                disp("Diskovi se ne dodiruju");
                return;
            end
            
            m1 = obj.masa; m2 = disk.masa;
            
            V1ux = obj.brzina.Vx;
            V1uy = obj.brzina.Vy;
            
            V2ux = disk.brzina.Vx;
            V2uy = disk.brzina.Vy;
            
            theta = acos( ( (V2ux - V1ux) * (disk.koordinate.x - obj.koordinate.x) + ...
                (V2uy - V1uy) * (disk.koordinate.y - obj.koordinate.y) ) / ...
                ( sqrt( (V2ux - V1ux)^2 + (V2uy - V1uy)^2 ) * ...
                sqrt( (disk.koordinate.x - obj.koordinate.x)^2 + (disk.koordinate.y - obj.koordinate.y)^2 ) ) );

            k1 = (m1 - m2) / (m1 + m2);
            k2 = (2 * m2) / (m1 + m2);
            k3 = (m2 - m1) / (m1 + m2);
            k4 = (2 * m1) / (m1 + m2);
            
            V1ix = (k1 * (V1ux * cos(theta) + V1uy * sin(theta)) + k2 * (V2ux * cos(theta) + V2uy * sin(theta))) * cos(theta) - ...
                (-V1ux * sin(theta) + V1uy * cos(theta)) * sin(theta);
            
            V1iy = (k1 * (V1ux * cos(theta) + V1uy * sin(theta)) + k2 * (V2ux * cos(theta) + V2uy * sin(theta))) * sin(theta) - ...
                (-V1ux * sin(theta) + V1uy * cos(theta)) * cos(theta);
            
            V2ix = (k4 * (V1ux * cos(theta) + V1uy * sin(theta)) + k3 * (V2ux * cos(theta) + V2uy * sin(theta))) * cos(theta) - ...
                (-V2ux * sin(theta) + V2uy * cos(theta)) * sin(theta);
            
            V2iy = (k4 * (V1ux * cos(theta) + V1uy * sin(theta)) + k3 * (V2ux * cos(theta) + V2uy * sin(theta))) * sin(theta) - ...
                (-V2ux * sin(theta) + V2uy * cos(theta)) * cos(theta);
            
            obj.brzina.Vx = V1ix;
            obj.brzina.Vy = V1iy;
            
            disk.brzina.Vx = V2ix;
            disk.brzina.Vy = V2iy;
        end
        
        % Najpre proverada da li se diskovi dodiruju. Ako se diskovi seku
        % vraca gresku. Ako se diskovi ne seku, proverava da li se
        % dodiruju. Ostavlja mali prostor za gresku zbog greske koju pravi 
        % matlab posle 15. decimale. Na osnovu masa, poluprecnika,
        % pozicije i brzina dva diska, racuna izlaznu brzinu.
        function [obj, disk] = izvrsiSudar3(obj, disk)
            if (~obj.dodiruje(disk)) 
                disp("Diskovi se ne dodiruju");
                return;
            end
            
            m1 = obj.masa;
            m2 = disk.masa;
            
            V1ux = obj.brzina.Vx;
            V1uy = obj.brzina.Vy;
            
            V1 = obj.brzina.getIntensity();
            
            V2ux = disk.brzina.Vx;
            V2uy = disk.brzina.Vy;
            
            V2 = disk.brzina.getIntensity();
            
            x1 = obj.koordinate.x;
            y1 = obj.koordinate.y;
            x2 = disk.koordinate.x;
            y2 = disk.koordinate.y;
            
            phi = arctg((x2 - x1), (y2 - y1));
            
            theta1 = arctg(V1ux, V1uy) - phi;
            theta2 = arctg(V2ux, V2uy) - phi;
            
            k1 = (m1 - m2) / (m1 + m2);
            k2 = (2 * m2) / (m1 + m2);
            k3 = (m2 - m1) / (m1 + m2);
            k4 = (2 * m1) / (m1 + m2);
            
            V1n = V1 * cos(theta1);
            V1t = V1 * sin(theta1);
            
            V2n = V2 * cos(theta2);
            V2t = V2 * sin(theta2);
            
            V1it = V1t;
            V2it = V2t;
            
            V1in = k1 * V1n + k2 * V2n;
            V2in = k4 * V1n + k3 * V2n;
            
            V1ix = V1in * cos(phi) - V1it * sin(phi);
            V1iy = V1in * sin(phi) + V1it * cos(phi);
            
            V2ix = V2in * cos(phi) - V2it * sin(phi);
            V2iy = V2in * sin(phi) + V2it * cos(phi);
            
            obj.brzina.Vx = V1ix;
            obj.brzina.Vy = V1iy;
            
            disk.brzina.Vx = V2ix;
            disk.brzina.Vy = V2iy;
        end
    end
    
    methods(Static)
        % Proverava da li u nizu diskova postoje barem dva koja se seku
        function [seceSe, index1, index2] = seceSeBaremJedan(nizDiskova)
            seceSe = false;
            index1 = -1;
            index2 = -1;
            
            brojDiskova = numel(nizDiskova);
            for i = 1:brojDiskova - 1
                for j = i+1:brojDiskova
                    if nizDiskova(i).sece(nizDiskova(j))
                        % Pronađeni su diskovi koji se seku, nema potrebe 
                        % za daljom proverom. Dodeljujemo vrednosti koje
                        % vracamo i izlazimo iz funkcije.
                        seceSe = true;
                        index1 = i; 
                        index2 = j;
                        return;
                    end
                end
            end
        end
        
        % Vraca sve parove diskova koji se seku
        function diskovi = diskoviKojiSeSeku(nizDiskova)
            brojDiskova = numel(nizDiskova);
            index = 1;
            
            for i = 1:brojDiskova - 1
                for j = i+1:brojDiskova
                    if nizDiskova(i).sece(nizDiskova(j))
                        diskovi(:, index) = [nizDiskova(i) nizDiskova(j)];
                        index = index + 1;
                    end
                end
            end
            
            if (index == 1)
                diskovi = [];
            end
        end
        
        % Ova funkcija se koristi kako bi uniformisala vrednost koju nam
        % vrati funkcija roots, koja moze biti prazan niz, niz sa
        % kompleksnim elementima ili niz sa realnim elementima. Vraca
        % najmanju realnu vrednost ili -1 u slucaju da ne postoji validno
        % realno resenje. Roots vraca dva resenja, jedno je u slucaju kada
        % se sudare diskovi, a drugo je u hipotetickom slucaju da diskovi
        % prolaze jedan kroz drugi, trenutak kada se dodiruju nakon izlaska
        % jednog iz drugog.
        function vreme = prilagodiVremeSudara(t)
            if isempty(t)
                vreme = -1;
                return;
            end
            
            if ~isreal(t(1))
                vreme = -1;
                return;
            end
            
            t(t >= 1e-13 & t < 0) = 0;

            % Sledeca linija otklanja vrednosti manje od 0
            % Ove vrednosti se dobijaju u slucaju da se dva diska na
            % pocetku preklapaju. Ovo ne bi trebalo da se desi.
            t = t(t >= 0);
            
            if (length(t) == 2)
                % Ovo znaci da postoje dva resenja koja su veca od 0 sto znaci
                % da diskovi nailaze jedan na drugi.
                vreme = min(t);
            else
                % Ovo znaci da postoji jedno (ili nijedno) resenje koje je 
                % vece od 0 sto znaci da diskovi odlaze jedan od drugog.
                vreme = -1;
            end
        end
    end
end