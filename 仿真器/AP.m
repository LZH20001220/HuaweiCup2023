% 包含一个 AP 的属性和状态
classdef AP < handle
    
    % 1. 数据成员（原则上非友元类仅可访问, 不可随意修改）
    properties (SetAccess = public, GetAccess = public)
        last_t;         % 上一次事件的时间
        ords;           % 发送次数
        t_window;       % 当前窗口的剩余时间 (us)
        state;          % 状态, 取值在 ApState 枚举类型中
        
        simulator;      % 仿真器
        callback;       % 回调定时
        all_event;      % 全部事件追踪
        sta_event;      % 自己 STA 被干扰的事件
        effect_AP;      % 能听到自己发包的 AP
        effect_STA;     % 能被自己发包干扰的 STA
        
        mbps;           % 带宽 (Mbps)
        r;              % 最大重传次数
        dt;             % t_PHY + (B_MAC + B_Payload) * 8 / 带宽 (us)
        W_min;          % CW_min
        W_max;          % CW_max
        p_e;            % 信道质量导致的丢包率
        id;             % UID, 标识 AP 号
    end
    
    % 2. 类的通用属性
    properties (Constant)
        t_ACK         = 32;     % ACK (us)
        t_SIFS        = 16;     % SIFS (us)
        t_DIFS        = 43;     % DIFS (us)
        t_SLOT        = 9;      % SLOT (us)
        t_TO          = 65;     % ACK TimeOut (us)
        t_PHY         = 13.6;   % PHY 头时长 (us)
        L_MAC         = 30;     % MAC 头 (Byte)
        L_PLD         = 1500;   % Payload (Byte)
        default_W_min = 16;     % 默认的 CW_min
        default_W_max = 1024;   % 默认的 CW_max
    end
    
    % 3. 公有接口方法
    methods (Access = public)
        % 1. 构造函数, 接受必选参数 {mbps, simulator, r, p_e} 和可选参数 {W_min, W_max} 对 AP 进行配置
        function obj = AP(simu_conf)
            % simu_conf 为结构体, 包含配置参数, 将按照配置参数设置 AP 属性
            % 1. mbps
            if isfield(simu_conf, 'mbps')
                obj.mbps = simu_conf.mbps;
                obj.dt = obj.t_PHY + (obj.L_MAC + obj.L_PLD) * 8 / obj.mbps;
            else
                error('错误：mbps是AP的必选参数，但是传入的参数没有这一条！')
            end
            % 2. W_min
            if isfield(simu_conf, 'W_min')
                obj.W_min = simu_conf.W_min;
            else
                obj.W_min = obj.default_W_min;
            end
            % 3. W_max
            if isfield(simu_conf, 'W_max')
                obj.W_max = simu_conf.W_max;
            else
                obj.W_max = obj.default_W_max;
            end
            % 4. r
            if isfield(simu_conf, 'r')
                obj.r = simu_conf.r;
            else
                error('错误：r是AP的必选参数，但是传入的参数没有这一条！')
            end
            % 5. r
            if isfield(simu_conf, 'p_e')
                obj.p_e = simu_conf.p_e;
            else
                error('错误：p_e是AP的必选参数，但是传入的参数没有这一条！')
            end
            % 6. id 自动编号
            persistent id0;
            if isempty(id0)
                id0 = 1;
            end
            obj.id = id0;
            id0 = id0 + 1;
            % 7. simulator
            if isfield(simu_conf, 'simulator')
                obj.simulator = simu_conf.simulator;
            else
                error('错误：simulator是AP的必选参数，但是传入的参数没有这一条！')
            end
            % 8. 初始化滑动窗口与状态
            obj.last_t = 0;
            obj.ords = 0;
            obj.t_window = obj.GetWindowTime();
            obj.state = ApState.BACK_OFF;
            obj.callback = [];
        end
        
        % 2. 获取窗口等待时间
        function t = GetWindowTime(obj)
            if obj.W_min * 2^obj.ords > obj.W_max
                window = obj.W_max;
            else
                window = obj.W_min * 2^obj.ords;
            end
            t = randi([0, window - 1], 1, 1) * obj.t_SLOT;
        end
        
        % 3. 执行窗口倒计时
        function Run(obj)
            % 经过的时间差
            t = obj.simulator.t;
            delta_t = t - obj.last_t;
            obj.last_t = t;
            
            assert(obj.state == ApState.BACK_OFF);
            assert(isempty(obj.callback));
            % 如果当前有干扰, 说明应该执行 hold
            obj.callback = Callback(t + obj.t_window, ...
                                    @()obj.Send());
        end
        
        % 4. 尝试发送
        function Send(obj)
            % 经过的时间差
            t = obj.simulator.t;
            delta_t = t - obj.last_t;
            obj.last_t = t;
            
            assert(obj.state == ApState.BACK_OFF);
            
            % 1e-6 用于容许浮点数计算精度问题
            assert(delta_t <= obj.t_window + 1e-6);
            obj.t_window = max(0, obj.t_window - delta_t);
            
            % 如果应该发送
            assert(abs(obj.t_window) < 1e-6)
            obj.t_window = 0;
            obj.state = ApState.SEND;
            % 让互听的 AP 进行 hold;
            APs = obj.simulator.APs;
            for i = 1:length(obj.effect_AP)
                ap = APs{obj.effect_AP{i}};
                ap.Hold();
            end
            % 让干扰的 STA 设置干扰事件;
            for i = 1:length(obj.effect_STA)
                ap = APs{obj.effect_STA{i}};
                ap.sta_event{end + 1} = Events(t, t + obj.dt, EventState.SEND);
            end
            % 记录发送事件
            obj.all_event{end + 1} = Events(t, t + obj.dt, EventState.SEND);
            % 等到 ACK 时检查干扰
            obj.callback = Callback(t + obj.dt + obj.t_SIFS + obj.t_ACK, ...
                                    @()obj.CheckAck(t, t + obj.dt));
        end
        
        % 5. 被别的节点设置为 hold 状态
        function Hold(obj)
            % 经过的时间差
            t = obj.simulator.t;
            delta_t = t - obj.last_t;
            obj.last_t = t;
            
            % 1. Back off
            if obj.state == ApState.BACK_OFF
                % 1e-6 用于容许浮点数计算精度问题
                assert(delta_t <= obj.t_window + 1e-6);
                
                obj.t_window = max(0, obj.t_window - delta_t);
                if obj.t_window < obj.t_SLOT - 1e-6
                    % 如果在最后一个时隙内, 我们认为此时 CCA 无法这么快响应
                    % 那么该节点将拒绝 hold, 从而导致冲突发生
                else
                    % 先 hold 到 ACK, 期间删除 callback, 由别人重新建立
                    obj.state = ApState.HOLD;
                    obj.callback = [];
                end
            elseif obj.state == ApState.HOLD
                % hold 状态不用再 hold 
            elseif obj.state == ApState.SEND
                % 发送过程中不用退避
            else
                error('逻辑错误：不期望的状态 UNKNOWN？')
            end
        end
        
        % 6. 解除 hold 状态
        function Unhold(obj)
            % 经过的时间差
            t = obj.simulator.t;
            delta_t = t - obj.last_t;
            obj.last_t = t;
            
            if obj.state == ApState.BACK_OFF
                % 1e-6 用于容许浮点数计算精度问题
                assert(delta_t <= obj.t_window + 1e-6);
                
                obj.t_window = max(0, obj.t_window - delta_t);
            elseif obj.state == ApState.HOLD
                obj.state = ApState.BACK_OFF;
                obj.callback = Callback(t + obj.t_window, ...
                                        @()obj.Send());
            elseif obj.state == ApState.SEND
                % 发送过程中不用取消退避
            else
                error('逻辑错误：不期望的状态 UNKNOWN？')
            end
        end
        
        % 7. 检查 ACK
        function CheckAck(obj, t1, t2)
            % 经过的时间差
            t = obj.simulator.t;
            delta_t = t - obj.last_t;
            obj.last_t = t;
            
            assert(obj.state == ApState.SEND);
            % 清理事件以免膨胀
            clear_idx = [];
            if length(obj.sta_event) >= 32
                for i = 1:length(obj.sta_event)
                    if obj.sta_event{i}.t_end < t1
                        clear_idx(end + 1) = i;
                    end
                end
                obj.sta_event(clear_idx) = [];
            end
            
            % 检查是否存在重叠事件
            is_ACK = true;
            for i=1:length(obj.sta_event)
                if (t1 <= obj.sta_event{i}.t_start && obj.sta_event{i}.t_start <= t2) || (t1 <= obj.sta_event{i}.t_end && obj.sta_event{i}.t_end <= t2)
                    is_ACK = false;
                    break;
                end
            end
            % 即使收到 ACK, 由于信道质量, 也有 p_e 概率丢包
            rnd = rand(1, 1);
            if rnd < obj.p_e
                is_ACK = false;
            end
            if is_ACK
                % 记录收到 ACK
                obj.all_event{end + 1} = Events(t - obj.t_ACK, t, EventState.ACK);
                
                obj.callback = Callback(t + obj.t_DIFS, ...
                                        @()obj.NewData());
            else
                % 记录 TimeOut
                obj.all_event{end + 1} = Events(t - obj.t_ACK, t + (obj.t_TO - obj.t_ACK), EventState.TO);
                
                obj.callback = Callback(t + (obj.t_TO - obj.t_ACK - obj.t_SIFS) + obj.t_DIFS, ...
                                        @()obj.TimeOutData());
            end
        end
        
        % 8. 收到 ACK 事件彻底结束后
        function NewData(obj)
            % 经过的时间差
            t = obj.simulator.t;
            delta_t = t - obj.last_t;
            obj.last_t = t;
                
            % 让互听的 AP 进行 unhold;
            APs = obj.simulator.APs;
            for i = 1:length(obj.effect_AP)
                ap = APs{obj.effect_AP{i}};
                ap.Unhold();
            end
            
            assert(obj.state == ApState.SEND);
            obj.ords = 0;
            obj.t_window = obj.GetWindowTime();
            obj.state = ApState.BACK_OFF;
            obj.Run();
        end
        
        % 10. 超时重发 data 事件彻底结束后
        function TimeOutData(obj)
            % 经过的时间差
            t = obj.simulator.t;
            delta_t = t - obj.last_t;
            obj.last_t = t;
                
            % 让互听的 AP 进行 unhold;
            APs = obj.simulator.APs;
            for i = 1:length(obj.effect_AP)
                ap = APs{obj.effect_AP{i}};
                ap.Unhold();
            end
            
            assert(obj.state == ApState.SEND);
            obj.ords = obj.ords + 1;
            % 如果达到重传上限
            if obj.ords > obj.r
                obj.ords = 0;
                obj.t_window = obj.GetWindowTime();
                obj.state = ApState.BACK_OFF;
                obj.Run();
            else
                obj.t_window = obj.GetWindowTime();
                obj.state = ApState.BACK_OFF;
                obj.Run();
            end
        end
    end
end

