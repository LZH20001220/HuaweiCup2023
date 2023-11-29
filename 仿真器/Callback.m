classdef Callback < handle
    properties
        t;          % 执行时间
        lambda;     % 执行函数
        uid;        % UID
    end
    
    methods
        function obj = Callback(t, lambda)
            obj.t = t;
            obj.lambda = lambda;
            persistent uid0;
            if isempty(uid0)
                uid0 = 1;
            end
            obj.uid = uid0;
            uid0 = uid0 + 1;
        end
    end
end

