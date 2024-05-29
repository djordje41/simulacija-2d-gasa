classdef Koordinate
    properties
        x (1, 1) double {mustBeNumeric} % x koordinata u metrima [m]
        y (1, 1) double {mustBeNumeric} % y koordinata u metrima [m]
    end
    
    methods
        % Constructor
        function obj = Koordinate(x, y)
            obj.x = x;
            obj.y = y;
        end
        
        function obj = set.x(obj, x)
            obj.x = x;
        end
        
        function obj = set.y(obj, y)
            obj.y = y;
        end
        
        % Vraca rastojanje izmedju ove koordinate i zadate koordinate
        function rastojanje = rastojanje(obj, koordinata)
            if ~isa(koordinata, 'Koordinate')
                error('Input must be a Koordinate object.');
            end
            
            dx = obj.x - koordinata.x;
            dy = obj.y - koordinata.y;
            rastojanje = sqrt(dx^2 + dy^2);
        end
    end
end
