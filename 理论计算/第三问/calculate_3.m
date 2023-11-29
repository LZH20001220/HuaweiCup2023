clear;
clc;
r = [6, 5, 32]; %最大重传次数
CW_min = 16;   %最小窗口
CW_max = 1024; %最大窗口 
m = log2(CW_max / CW_min);  %最多增长阶数
w0 = 16;    %初始窗口
n = 2;  %节点数量
nc = 1;     %暴露站数量
nh = 1;     %隐藏站数量
Pe = 0.1;   %丢包概率10%
T_ack = 32;     %ACK时间
T_sifs = 16;    %SIFS时间
T_difs = 43;    %DIFS时间
T_slot = 9;     %单个时隙时长
T_TO = 65;     % ACK TimeOut (us)
T_PHY = 13.6;   % PHY 头时长 (us)
L_MAC = 30;     % MAC 头 (Byte)
L_PLD = 1500;   % Payload (Byte)
L_RTS = 20;     % RTS帧长
L_CTS = 14;     % CTS帧长
rate = [455.8, 286.8, 158.4];
p = [0.357464497460350,0.279203999861742,0.356607602724564;0.388669282435096,0.311849748413784,0.387588098119039;0.431865379393535,0.363541794746749,0.430699088405013];
k = [0.286071663844833,0.199115555401936,0.285119558582849;0.320743647150107,0.235388609348649,0.319542331243377;0.368739310437262,0.292824216385277,0.367443431561125];
b00 = [0.0376129017307904,0.0277659979567545,0.0375409527973552;0.0317902827359910,0.0242900792548090,0.0317323324002892;0.0245630773407995,0.0191944229736563,0.0245348741171775];
tau = zeros(length(rate), length(r));
Ptr = zeros(length(rate), length(r));
Ps = zeros(length(rate), length(r));
S = zeros(length(rate), length(r));
Srts = zeros(length(rate), length(r));

Ts = zeros(length(rate));
Tcov = zeros(length(rate));
Thid = zeros(length(rate));
Tc = zeros(length(rate));
Tsrts = zeros(length(rate));
Tcrts = zeros(length(rate));
Psthe = zeros(length(rate));
for i = 1:length(rate)
    Ts(i) = T_PHY + ((L_MAC + L_PLD) * 8)/rate(i) + T_sifs + T_ack + T_difs;
    Thid(i) = 1.5 * (T_PHY + (L_MAC + L_PLD) * 8/rate(i)) + T_TO + T_difs;
    Tcov(i) = 0.5 * T_slot + (T_PHY + (L_MAC + L_PLD) * 8/rate(i)) + T_TO + T_difs;
    Tc(i) = nc / n * Tcov(i) + nh / n * Thid(i);
    Tsrts(i) = Ts(i) + 2 * T_sifs + ((L_RTS + L_CTS) * 8)/rate(i) + 2 * T_PHY;
    Tcrts(i) = L_RTS * 8 / rate(i) + T_TO + T_difs + T_PHY;
    Psthe(i) = (Tc(i) - Tcrts(i))/(Tsrts(i) - Ts(i) + Tc(i) - Tcrts(i));
    for j = 1:length(r)
        tau(i, j) = b00(i, j)*(1-p(i, j)^(r(j) + 1))/(1-p(i, j));
        Ptr(i, j) = 1 - (1 - tau(i, j))^nc;
        Ps(i, j) = nc * tau(i, j) * (1 - tau(i, j))^(nc -1) * (1 - k(i, j)^nh)*(1-Pe)/Ptr(i, j);
        S(i, j) = n * (Ps(i, j) * Ptr(i, j) * L_PLD * 8)/(T_slot *(1 - Ptr(i, j)) + Ptr(i, j)*Ps(i, j)*Ts(i) + (1-Ps(i, j))*Ptr(i, j)*Tc(i));
        Srts(i, j) = n * (Ps(i, j) * Ptr(i, j) * L_PLD * 8)/(T_slot *(1 - Ptr(i, j)) + Ptr(i, j)*Ptr(i, j)*Tsrts(i) + (1-Ps(i, j))*Ptr(i, j)*Tcrts(i));
    end
end