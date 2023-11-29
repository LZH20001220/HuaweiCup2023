%%
clear;
clc;
r = 32; %����ش�����
CW_min = 16;   %��С����
CW_max = 1024; %��󴰿� 
m = log2(CW_max / CW_min);  %�����������
w0 = 16;    %��ʼ����
n = 2;  %�ڵ�����
nc = 1;     %��¶վ����
nh = 1;     %����վ����
T_ack = 32;     %ACKʱ��
T_sifs = 16;    %SIFSʱ��
T_difs = 43;    %DIFSʱ��
T_slot = 9;     %����ʱ϶ʱ��
rate = 455.8;   %���������(Mbps)
T_TO = 65;     % ACK TimeOut (us)
T_PHY = 13.6;   % PHY ͷʱ�� (us)
L_MAC = 30;     % MAC ͷ (Byte)
L_PLD = 1500;   % Payload (Byte)
L_RTS = 20;     % RTS֡��
L_CTS = 14;     % CTS֡��
%%
syms p
b00 = (2*(1-p)*(1-2*p))/(w0*(1-(2*p)^(m+1))*(1-p) + (1-2*p)*(1-p^(r+1)+w0*2^m*p^(m+1)*(1-p^(r-m)*(1-2*p))));
tau = b00*(1-p^(r+1))/(1-p);
equation = p == 1 - (1 - tau)^(n - 1);
p_solution = vpasolve(equation, p);
for i = 1 : length(p_solution)
    if(isreal(p_solution(i)))
        pp = double(p_solution(i));
    end
end
b00 = (2*(1-pp)*(1-2*pp))/(w0*(1-(2*pp)^(m+1))*(1-pp) + (1-2*pp)*(1-pp^(r+1)+w0*2^m*pp^(m+1)*(1-pp^(r-m)*(1-2*pp))));
tau = b00*(1-pp^(r+1))/(1-pp);
%%
Ptr = 1-(1-tau)^n;
Es = 1/Ptr - 1;
Ps = (n*tau*(1-tau)^(n-1))/Ptr;
Pc = 1 - Ps;
Ts = T_PHY + (L_MAC + L_PLD) * 8/rate + T_sifs + T_ack + T_difs;
Tc = T_PHY + (L_MAC + L_PLD) * 8/rate + T_TO + T_difs;
Tsrts = Ts + 2 * T_sifs + (L_RTS + L_CTS) * 8/rate + 2 * T_PHY;
Tcrts = L_RTS * 8 / rate + T_TO + T_difs + T_PHY;
%%% ��һ�����
S = (Ps * Ptr * L_PLD * 8)/(T_slot *(1 - Ptr) + Ps*Ptr*Ts + (1-Ps)*Ptr*Tc);
S_trs = (Ps * Ptr * L_PLD * 8)/(T_slot *(1 - Ptr) + Ps*Ptr*Tsrts + (1-Ps)*Ptr*Tcrts);
Psthe = (Tc - Tcrts)/(Tsrts - Ts + Tc - Tcrts);