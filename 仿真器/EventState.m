classdef EventState < uint32
    enumeration
        SEND (1);   % 发送事件
        ACK  (2);   % 发送成功
        TO   (3);   % 发送失败
    end
end