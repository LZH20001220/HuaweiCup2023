clear;
clc;
r = [6, 5, 32]; %最大重传次数
CW_min = [16, 32, 16];   %最小窗口
CW_max = [1024, 1024, 1024]; %最大窗口 
w0 = 16;    %初始窗口
n = 3;  %节点数量
T_ack = 32;     %ACK时间
T_sifs = 16;    %SIFS时间
T_difs = 43;    %DIFS时间
T_slot = 9;     %单个时隙时长
rate = [455.8, 286.8, 158.4];
T_TO = 65;     % ACK TimeOut (us)
T_PHY = 13.6;   % PHY 头时长 (us)
L_MAC = 30;     % MAC 头 (Byte)
L_PLD = 1500;   % Payload (Byte)
L_RTS = 20;     % RTS帧长
L_CTS = 14;     % CTS帧长

tau = zeros(length(rate), length(r));
Ptr = zeros(length(rate), length(r));
Ps = zeros(length(rate), length(r));
S1 = zeros(length(rate), length(r));
S2 = zeros(length(rate), length(r));
S3 = zeros(length(rate), length(r));
S = zeros(length(rate), length(r));
S1rts = zeros(length(rate), length(r));
S2rts = zeros(length(rate), length(r));
S3rts = zeros(length(rate), length(r));
Srts = zeros(length(rate), length(r));

Ts = zeros(length(rate));
Tcov = zeros(length(rate));
Thid = zeros(length(rate));
Tc = zeros(length(rate));
Tsrts = zeros(length(rate));
Tcrts = zeros(length(rate));
Psthe = zeros(length(rate));
b001 = zeros(length(rate));
b002 = zeros(length(rate));
b003 = zeros(length(rate));
tau1 = zeros(length(rate));
tau2 = zeros(length(rate));
tau3 = zeros(length(rate));
Ptr1 = zeros(length(rate));
Ptr2 = zeros(length(rate));
Ptr3 = zeros(length(rate));
Ps1 = zeros(length(rate));
Ps2 = zeros(length(rate));
Ps3 = zeros(length(rate));
p1 = [0.0891784, 0.0532169, 0.0891211];
p2 = [0.202092, 0.111311, 0.202105];
p3 = [0.0891784, 0.0532169, 0.0891211];
m = [6,5,6];
for i = 1:length(rate)
    Ts(i) = T_PHY + ((L_MAC + L_PLD) * 8)/rate(i) + T_sifs + T_ack + T_difs;
    Tc(i) = T_PHY + (L_MAC + L_PLD) * 8/rate(i) + T_TO + T_difs;
    Tsrts(i) = Ts(i) + 2 * T_sifs + ((L_RTS + L_CTS) * 8)/rate(i) + 2 * T_PHY;
    Tcrts(i) = L_RTS * 8 / rate(i) + T_TO + T_difs + T_PHY;
    Psthe(i) = (Tc(i) - Tcrts(i))/(Tsrts(i) - Ts(i) + Tc(i) - Tcrts(i));
    for j = 1:length(r)
        b001(j) = (2*(1-p1(j))*(1-2*p1(j)))/(CW_min(j)*(1-(2*p1(j))^(m(j)+1))*(1-p1(j)) + (1-2*p1(j))*(1-p1(j)^(r(j)+1)+CW_min(j)*2^m(j)*p1(j)^(m(j)+1)*(1-p1(j)^(r(j)-m(j))*(1-2*p1(j)))));
        b002(j) = (2*(1-p2(j))*(1-2*p2(j)))/(CW_min(j)*(1-(2*p2(j))^(m(j)+1))*(1-p2(j)) + (1-2*p2(j))*(1-p2(j)^(r(j)+1)+CW_min(j)*2^m(j)*p2(j)^(m(j)+1)*(1-p2(j)^(r(j)-m(j))*(1-2*p2(j)))));
        b003(j) = (2*(1-p3(j))*(1-2*p3(j)))/(CW_min(j)*(1-(2*p3(j))^(m(j)+1))*(1-p3(j)) + (1-2*p3(j))*(1-p3(j)^(r(j)+1)+CW_min(j)*2^m(j)*p3(j)^(m(j)+1)*(1-p3(j)^(r(j)-m(j))*(1-2*p3(j)))));
        
        tau1(j) = b001(j)*(1 - p1(j)^(r(j)+1)) / (1 - p1(j));
        tau2(j) = b002(j)*(1 - p2(j)^(r(j)+1)) / (1 - p2(j));
        tau3(j) = b003(j)*(1 - p3(j)^(r(j)+1)) / (1 - p3(j));
        
        Ptr1(j) = 1 - (1 - tau1(j))*(1 - tau2(j));
        Ptr2(j) = 1 - (1 - tau1(j))*(1 - tau2(j))*(1 - tau3(j));
        Ptr3(j) = 1 - (1 - tau3(j))*(1 - tau2(j));
        
        Ps1(j) = (tau1(j)*(1 - tau2(j)) + tau2(j)*(1 - tau1(j))*(1 - tau3(j))) / Ptr1(j);
        Ps2(j) = (tau2(j)*(1 - tau1(j)*(1 - tau3(j)) + tau1(j)*(1 - tau2(j)) + tau3(j)*(1 - tau2(j)))) / Ptr2(j);
        Ps3(j) = (tau3(j)*(1 - tau2(j)) + tau2(j)*(1 - tau1(j))*(1 - tau3(j))) / Ptr3(j);
        
        S1(i, j) = (tau1(j)*(1 - tau2(j))* L_PLD * 8)/(T_slot *(1 - Ptr1(j)) + Ptr1(j)*Ps1(j)*Ts(i) + Ptr1(j)*(1 - Ps1(j))*Tc(i));
        S2(i, j) = (tau2(j)*(1 - tau1(j))* (1 - tau3(j))* L_PLD * 8)/(T_slot *(1 - Ptr2(j)) + Ptr2(j)*Ps2(j)*Ts(i) + Ptr2(j)*(1 - Ps2(j))*Tc(i));
        S3(i, j) = (tau3(j)*(1 - tau2(j))* L_PLD * 8)/(T_slot *(1 - Ptr3(j)) + Ptr3(j)*Ps3(j)*Ts(i) + Ptr3(j)*(1 - Ps3(j))*Tc(i));
        S(i, j) = S1(i, j) + S1(i, j) + S3(i, j);
        
        S1rts(i, j) = (tau1(j)*(1 - tau2(j))* L_PLD * 8)/(T_slot *(1 - Ptr1(j)) + Ptr1(j)*Ps1(j)*Tsrts(i) + Ptr1(j)*(1 - Ps1(j))*Tcrts(i));
        S2rts(i, j) = (tau2(j)*(1 - tau1(j))* (1 - tau3(j))* L_PLD * 8)/(T_slot *(1 - Ptr2(j)) + Ptr2(j)*Ps2(j)*Tsrts(i) + Ptr2(j)*(1 - Ps2(j))*Tcrts(i));
        S3rts(i, j) = (tau3(j)*(1 - tau2(j))* L_PLD * 8)/(T_slot *(1 - Ptr3(j)) + Ptr3(j)*Ps3(j)*Tsrts(i) + Ptr3(j)*(1 - Ps3(j))*Tcrts(i));
        Srts(i, j) = S1rts(i, j) + S2rts(i, j) + S3rts(i, j);
    end
end
