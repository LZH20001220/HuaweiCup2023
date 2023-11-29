classdef ApState < uint32
    enumeration
        BACK_OFF (1);   % 正在 backoff
        HOLD     (2);   % 正在 hold
        SEND     (3);   % 正在发送 (t_DATA + t_SIFS + t_ACK)
                        % 等待 TimeOut ((t_TO - t_ACK - ap.t_SIFS) + t_DIFS)
                        % 等待 DIFS (t_DIFS)
    end
end

