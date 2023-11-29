clear;
clc;
r = 32; %最大重传次数
CW_min = 16;   %最小窗口
CW_max = 1024; %最大窗口 
m = log2(CW_max / CW_min);  %最多增长阶数
w0 = 16;    %初始窗口
n = 2;  %节点数量
nc = 1;     %暴露站数量
nh = 1;     %隐藏站数量
T_ack = 32;     %ACK时间
T_sifs = 16;    %SIFS时间
T_difs = 43;    %DIFS时间
T_slot = 9;     %单个时隙时长
rate = 275.3;   %物理层速率(Mbps)
T_TO = 65;     % ACK TimeOut (us)
T_PHY = 13.6;   % PHY 头时长 (us)
L_MAC = 30;     % MAC 头 (Byte)
L_PLD = 1500;   % Payload (Byte)
L_RTS = 20;     % RTS帧长
L_CTS = 14;     % CTS帧长

syms p
pp = 0;
b00 = (2*(1-pp)*(1-2*pp))/(w0*(1-(2*pp)^(m+1))*(1-pp) + (1-2*pp)*(1-pp^(r+1)+w0*2^m*pp^(m+1)*(1-pp^(r-m)*(1-2*pp))));
tau = b00;

Pidle = (1-tau)^2;
Ps = 1 - (1-tau)^2;
Ts = T_PHY + (L_MAC + L_PLD) * 8/rate + T_sifs + T_ack + T_difs;
Tc = T_PHY + (L_MAC + L_PLD) * 8/rate + T_TO + T_difs;
Tsrts = Ts + 2 * T_sifs + (L_RTS + L_CTS) * 8/rate + 2 * T_PHY;
Tcrts = L_RTS * 8 / rate + T_TO + T_difs + T_PHY;

%%% 第二问求解
S2 = (2*tau * (1-tau) * L_PLD * 8)/(T_slot * Pidle + Ps*Ts);
S2rts = (2*tau * (1-tau) * L_PLD * 8)/(T_slot * Pidle + Ps*Tsrts);
Psthe = (Tc - Tcrts)/(Tsrts - Ts + Tc - Tcrts);