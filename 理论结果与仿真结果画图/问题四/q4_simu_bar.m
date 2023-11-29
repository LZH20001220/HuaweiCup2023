clear;
clc;
figure('position',[150,100,900,550])%确定图片的位置和大小，[x y width height]
%准备数据
S = [102.708, 81.654, 103.086;93.918, 75.696, 94.398;81.984, 64.224, 84.744];
X=1:3;
 %画出3组柱状图，宽度1
s=bar(X,S,1);      
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
p = [0.1514, 0.1076, 0.148;0.1583, 0.1163, 0.152;0.1441, 0.1406, 0.1153];
%画出3组柱状图，宽度1
p=bar(X,p,1);      
%修改横坐标名称、字体
set(gca,'XTickLabel',{'455.8Mbps','286.8Mbps','158.4Mbps'},'FontSize',10,'FontName','Times New Roman');
% 设置柱子颜色
set(p(1),'FaceColor','#FA4224')     
set(p(2),'FaceColor','#048243')    
set(p(3),'FaceColor','#DBB40C')
ylim([0 0.18])
%修改x,y轴标签
ylabel('\fontname{宋体}\fontsize{14}碰撞概率');
xlabel('\fontname{宋体}\fontsize{14}不同物理层速率'); 
%修改图例
legend({'[W_{min}, W_{max}, r]=[16, 1024, 6]','[W_{min}, W_{max}, r]=[32, 1024, 5]','[W_{min}, W_{max}, r]=[16, 1024, 32]'})