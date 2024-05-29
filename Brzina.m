classdef Brzina
    properties
        Vx (1, 1) double {mustBeNumeric} % x-komponenta brine
        Vy (1, 1) double {mustBeNumeric} % y-komponenta brine
    end
    
    methods
        % Konstruktor
        function obj = Brzina(Vx, Vy)
            obj.Vx = Vx;
            obj.Vy = Vy;
        end
        
        function obj = set.Vx(obj, Vx)
            obj.Vx = Vx;
        end
        
        function obj = set.Vy(obj, Vy)
            obj.Vy = Vy;
        end
        
        function intensity = getIntensity(obj)
            % Get the magnitude (intensity) of the velocity vector
            intensity = sqrt(obj.Vx^2 + obj.Vy^2);
        end
        
        function polarAngle = getPolarAngle(obj)
            % Get the polar angle of the velocity vector
            polarAngle = atan2(obj.Vy, obj.Vx); % Returns angle in radians
        end
    end
end