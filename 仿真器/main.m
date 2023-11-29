clear AP;
clear Callback;
close all;clear;clc;

tic;
rng(0);                     % 固定随机数种子, 便于复现

% 1. 参数配置
simu_conf = struct();
max_time = 1e6;             % 最大仿真时间 (us)
simulator = Simulator(max_time);
simu_conf.mbps = 455.8;     % 物理层速率
% simu_conf.mbps = 275.3;     % 物理层速率
simu_conf.simulator = simulator;
simu_conf.r = 32;           % 最大重传次数
simu_conf.p_e = 0.1;          % 信道质量导致的丢包率

% 2. 创建 AP
APs = cell(2, 1);
APs{1} = AP(simu_conf);     % AP1
APs{2} = AP(simu_conf);     % AP2

% 3. 创建拓扑
% topoAP2AP 代表每个 AP 会影响到的别的 AP 的 id 号
% topoAP2AP = {{2}, {1}};
topoAP2AP = {{}, {}};
% topoAP2STA 代表每个 AP 会影响到的别的 STA 的 id 号
topoAP2STA = {{2}, {1}};
% topoAP2STA = {{}, {}};

% 4. 启动仿真
simulator.Init(APs, topoAP2AP, topoAP2STA);
simulator.RunAll();

% 5. 绘制仿真输出
simulator.PlotAllEvent();

% 6.绘制吞吐曲线
% avg_throughput 是平均吞吐量, p 是碰撞概率
[avg_throughput, p] = simulator.PlotThroughput(5e5);

toc
