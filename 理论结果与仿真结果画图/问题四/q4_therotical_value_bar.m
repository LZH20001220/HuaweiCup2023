clear;
clc;
figure('position',[150,100,900,550])%确定图片的位置和大小，[x y width height]
%准备数据
m1=load('matlab4_4.mat');
X=1:3;
 %画出3组柱状图，宽度1
s=bar(X,m1.S,1);      
 %修改横坐标名称、字体
set(gca,'XTickLabel',{'455.8Mbps','286.8Mbps','158.4Mbps'},'FontSize',10,'FontName','Times New Roman');
% 设置柱子颜色
set(s(1),'FaceColor','#FA4224')  
set(s(2),'FaceColor','#048243')    
set(s(3),'FaceColor','#DBB40C')    
%修改x,y轴标签
ylabel('\fontname{宋体}\fontsize{14}吞吐量(Mbps)');
xlabel('\fontname{宋体}\fontsize{14}不同物理层速率'); 
legend({'[W_{min}, W_{max}, r]=[16, 1024, 6]','[W_{min}, W_{max}, r]=[32, 1024, 5]','[W_{min}, W_{max}, r]=[16, 1024, 32]'})
figure('position',[150,100,900,550])%确定图片的位置和大小，[x y width height]
%画出3组柱状图，宽度1
srts=bar(X,m1.Srts,1);      
%修改横坐标名称、字体
set(gca,'XTickLabel',{'455.8Mbps','286.8Mbps','158.4Mbps'},'FontSize',10,'FontName','Times New Roman');
% 设置柱子颜色
set(srts(1),'FaceColor','#FA4224')     
set(srts(2),'FaceColor','#048243')    
set(srts(3),'FaceColor','#DBB40C')  
%修改x,y轴标签
ylabel('\fontname{宋体}\fontsize{14}RTS机制吞吐量(Mbps)');
xlabel('\fontname{宋体}\fontsize{14}不同物理层速率'); 
legend({'[W_{min}, W_{max}, r]=[16, 1024, 6]','[W_{min}, W_{max}, r]=[32, 1024, 5]','[W_{min}, W_{max}, r]=[16, 1024, 32]'})
figure('position',[150,100,900,550])%确定图片的位置和大小，[x y width height]
%画出3组柱状图，宽度1
pp = [0.0891784	0.0532169	0.0891211;0.202092	0.111311	0.202105;0.0891784	0.0532169	0.0891211];
p=bar(X,pp,1);      
%修改横坐标名称、字体
set(gca,'XTickLabel',{'455.8Mbps','286.8Mbps','158.4Mbps'},'FontSize',10,'FontName','Times New Roman');
% 设置柱子颜色
set(p(1),'FaceColor','#FA4224')     
set(p(2),'FaceColor','#048243')    
set(p(3),'FaceColor','#DBB40C')
%设置上边界确保不遮挡
ylim([0 0.3])
%修改x,y轴标签
ylabel('\fontname{宋体}\fontsize{14}碰撞概率');
xlabel('\fontname{宋体}\fontsize{14}不同物理层速率'); 
%修改图例
legend({'[W_{min}, W_{max}, r]=[16, 1024, 6]','[W_{min}, W_{max}, r]=[32, 1024, 5]','[W_{min}, W_{max}, r]=[16, 1024, 32]'})