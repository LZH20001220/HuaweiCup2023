classdef Simulator < handle
    properties
        t;
        max_time;   % 最大仿真时长 (us)
        APs;        % AP 组成的 cell
        topoAP2AP;  % topoAP2AP 代表每个 AP 会影响到的别的 AP 的 id 号
        topoAP2STA; % topoAP2STA 代表每个 AP 会影响到的别的 STA 的 id 号
    end
    
    methods
        % 1. 空构造
        function obj = Simulator(max_time)
            obj.max_time = max_time;
            % 请调用 init 实现初始化
        end
        
        % 2. 构造函数的实现, 以达成延迟构造
        function Init(obj, APs, topoAP2AP, topoAP2STA)
            obj.t = 0;
            obj.APs = APs;
            obj.topoAP2AP = topoAP2AP;
            obj.topoAP2STA = topoAP2STA;
            
            for i = 1:length(obj.APs)
                obj.APs{i}.effect_AP = topoAP2AP{i};
                obj.APs{i}.effect_STA = topoAP2STA{i};
                obj.APs{i}.Run();
            end
        end
        
        % 3. 主循环
        function RunAll(obj)
            while true
                obj.Run();
                if obj.t > obj.max_time
                    return;
                end
            end
        end
        
        % 4. 运行时间最早的回调函数
        function Run(obj)
            min_idx = 0;
            min_t = 1e18;
            for i = 1:length(obj.APs)
                ap = obj.APs{i};
                if ~isempty(ap.callback) ...
                    && (ap.callback.t < min_t ||  ...
                        (ap.callback.t == min_t && ap.callback.uid < obj.APs{min_idx}.callback.uid))
                    min_idx = i;
                    min_t = ap.callback.t;
                end
            end
            if min_t > 215563
                x = 1;
            end
            assert(min_idx ~= 0);
            obj.t = min_t;
            lambda = obj.APs{min_idx}.callback.lambda;
            obj.APs{min_idx}.callback = [];
            lambda();
        end
        
        % 5. 绘制事件曲线
        function PlotAllEvent(obj)
            figure('Name', '仿真事件曲线');
            cc = {'#DBB40C', '#048243','#FA4224','r'};
            for i = 1:length(obj.APs)
                events = obj.APs{i}.all_event;
                subplot(length(obj.APs), 1, i);
                for k = 1:3
                    x = (0);
                    y = (0);
                    for j = 1:length(events)
                        if(events{j}.state == k)
                            x(end + 1) = events{j}.t_start;
                            y(end + 1) = events{j}.state;
                            x(end + 1) = events{j}.t_end;
                            y(end + 1) = 0;
                        end
                    end
                    x(end + 1) = events{length(events)}.t_end + 1;
                    y(end + 1) = 0;
                    s = stairs(x, y, 'Color', cc{k}, 'LineWidth', 1);
                    hold on;
                end
                hold off;
                legend('发送','ACK','TimeOut');
                %修改x,y轴标签
                ylabel('\fontname{宋体}\fontsize{14}传输结果','FontWeight','bold');
                xlabel('\fontname{宋体}\fontsize{14}时间(us)','FontWeight','bold');
                axis([0, 10000, -0.2, 3.2])
                % axis([0, obj.t + 1, -0.2, 3.2])
            end
        end
        
        % 6. 绘制吞吐量曲线
        
        function [avg_throughput, p_c] = PlotThroughput(obj, gap)
            figure('Name', 'AP1吞吐量曲线');
            cc= {'#FA4224', '#048243','#DBB40C','r'};
            line = {'AP1吞吐量','AP2吞吐量','AP3吞吐量','系统总吞吐量'};
            count_ack_all = zeros(floor(obj.max_time / gap) + 1, 1);
            count_to_all = zeros(floor(obj.max_time / gap) + 1, 1);
            throughput_all = zeros(floor(obj.max_time / gap) + 1, 1);
            for i = 1:length(obj.APs)
                events = obj.APs{i}.all_event;
                count_ack = zeros(floor(obj.max_time / gap) + 1, 1);
                count_to = zeros(floor(obj.max_time / gap) + 1, 1);
                for j = 1:length(events)
                    now_t = events{j}.t_start;
                    idx = floor(now_t / gap) + 1;
                    if events{j}.state == EventState.ACK
                        count_ack(idx) = count_ack(idx) + 1;
                        count_ack_all(idx) = count_ack_all(idx) + 1;
                    elseif events{j}.state == EventState.TO
                        count_to(idx) = count_to(idx) + 1;
                        count_to_all(idx) = count_to_all(idx) + 1;
                    end
                end
                count_ack = count_ack(1:end-1);
                count_to = count_to(1:end-1);
                throughput = count_ack * 1500 * 8 / gap;
                x = (gap/2) : gap : (obj.max_time + gap/2);
                x = x(1:length(count_ack));
                plot(x, throughput, 'Color',cc{i},'LineWidth', 1);
                hold on;
                ax = gca;
                ax.YLim = [0, ceil(max(throughput) / 10) * 10];
                xlabel('\fontname{宋体}\fontsize{14}时间(us)','FontWeight','bold');
                ylabel('\fontname{宋体}\fontsize{14}吞吐(Mbps)','FontWeight','bold');
            end
            count_ack_all = count_ack_all(1:end-1);
            count_to_all = count_to_all(1:end-1);
            throughput_all = count_ack_all * 1500 * 8 / gap;
            plot(x,throughput_all,'Color',cc{4},'LineWidth', 1);
            hold off;
            legend(line);
            ax = gca;
            ax.YLim = [0, ceil(max(throughput_all) / 10) * 10];
            avg_throughput = mean(throughput_all);
            p_c = (sum(count_to_all)) / (sum(count_ack_all) + (sum(count_to_all)));
        end
    end
end

