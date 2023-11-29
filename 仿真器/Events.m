classdef Events < handle
    
    properties
        t_start;
        t_end;
        state;
    end
    
    methods
        function obj = Events(t_start, t_end, state)
            obj.t_start = t_start;
            obj.t_end = t_end;
            obj.state = state;
        end
    end
end

