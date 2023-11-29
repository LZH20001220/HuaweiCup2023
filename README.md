## 比赛说明

##### 比赛链接：[“华为杯”第二十届中国研究生数学建模竞赛](https://cpipc.acge.org.cn/cw/hp/4)

##### 比赛选题：WLAN 网络信道接入机制建模(A题)



## 代码说明

### 0. 总体流程图

![image-20231129204616778](https://github.com/LZH20001220/HuaweiCup2023/assets/65153649/645d5765-a709-4420-9e1f-407a35117bef){ width=50% height=auto }



### 1. 仿真器

#### 1.1 仿真器说明

本仿真程序是基于MATLAB R2021a 进行开发的，基于MATLAB 的面向对象编程工具，将每个AP 封装为了一个类，并采用元组传递拓扑关系。所有AP 通过一个Simulator类进行管理与交互，AP 将自己的行为抽象为事件，Simulator 将循环遍历所有AP 的事件，并按照时间顺序从前向后执行。

本程序只需改动main.m 文件的参数配置，即可对不同场景进行仿真。

#### 1.2 主脚本运行说明

主脚本为main.m 函数，问题一的运行示例如下代码所示。

每个AP 类通过结构体simu_conf 进行构造，其中mbps, simulator, r, p_e 是必选参数，W_min, W_max 是可选参数。

构造完AP 后，将它们组成一个元组，同时传入参数topoAP2AP，topoAP2STA，这两个参数定义了网络的拓扑关系，该代码对应了问题一的场景。

simulator.Init 初始化仿真，simulator.RunAll 执行仿真，simulator.PlotAllEvent 将绘制事件的时序图，simulator.PlotThroughput 将统计每个AP 的吞吐量、碰撞概率。

#### 1.3 核心功能模块说明

- **ApState.m**:用于定义AP的状态，包括退避状态，其他人发包时HOLD等待状态，SEND发送状态。
- **Callback.m**:代表事件对应的回调函数，包含触发时间，执行内容。
- **EventState.m**:用于记录事件的状态，用于仿真输出。
- **Events.m**:事件的状态，用三元组 `(起始时间, 终止时间, 状态)` 来定义一个事件。
- **Simulator.m**:用于与各AP的事件与状态交互，实现整个仿真程序的运行。
- **AP.m**:用于定义每个AP的行为逻辑和状态，与仿真器实现交互。

### 2. 理论计算：

#### 2.1 代码说明：

- **calculate_1.m**:计算第一问的冲突概率和系统吞吐
- **calculate_2.m**:计算第二问的冲突概率和系统吞吐
- **calculate_3.m**:计算第三问的冲突概率和系统吞吐
- **calculate_4_1.m**:计算第四问情况一的冲突概率和系统吞吐
- **calculate_4_2_3.m**:计算第四问情况二和情况三的冲突概率和系统吞吐
- **calculate_4_4.m**:计算第四问情况四的冲突概率和系统吞吐

#### 2.2 结果文件：

- **result_1.mat**:第一问的计算结果
- **result_2.mat**:第二问的的计算结果
- **result_3.mat**:第三问的的计算结果
- **result_4_1.mat**:第四问情况一的计算结果
- **result_4_2_3.mat**:第四问情况二和情况三的计算结果
- **result_4_4.mat**:第四问情况四的计算结果

#### 2.3 冲突概率计算：

通过Mathematica用于求解多元方程计算第四问四种情况下的冲突概率。



### 3. 画图 ###

#### 3.1 仿真器 ####

simulator.m是画每一章的仿真事件图与吞吐量曲线图，对应代码内的第五部分第六部分，执行main.m文件并修改每问相应的参数即可绘制。
为确保main.m文件中最大仿真时间固定在2e6，不必为每次画两张图修改参数，这里将simulator.m中92行x轴范围限定在10000。如有修改可写回原形。

#### 3.2 理论数据画图 ####

q3_therotical_value_bar.m与q4_therotical_value_bar.m分别导入result_3，result_4_1，result_4_2_3，result_4_4数据，其分别为第三题，第四题第一种情况，二三种情况和第四种情况中理论值的解。绘制柱状图。

#### 3.3 仿真数据画图 ####

q3_simu_bar.m、q4_simu_bar.m是在运行完simulator.m的基础上记录每组数据，将其写入3×3的数组中绘制柱状图代码。



## 比赛结果

一等奖(华为专项二等奖)              [成绩公示网址](https://cpipc.acge.org.cn//cw/detail/4/2c9080158aee323f018c0b4b1fdf71ff)
