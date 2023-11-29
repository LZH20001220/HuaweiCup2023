## 仿真器说明

#### 基本说明

本仿真程序是基于MATLAB R2021a 进行开发的，基于MATLAB 的面向对象编程工具，将每个AP 封装为了一个类，并采用元组传递拓扑关系。所有AP 通过一个Simulator类进行管理与交互，AP 将自己的行为抽象为事件，Simulator 将循环遍历所有AP 的事件，并按照时间顺序从前向后执行。

本程序只需改动main.m 文件的参数配置，即可对不同场景进行仿真。

#### 主脚本运行说明

主脚本为main.m 函数，问题一的运行示例如下代码所示。

每个AP 类通过结构体simu_conf 进行构造，其中mbps, simulator, r, p_e 是必选参数，W_min, W_max 是可选参数。

构造完AP 后，将它们组成一个元组，同时传入参数topoAP2AP，topoAP2STA，这两个参数定义了网络的拓扑关系，该代码对应了问题一的场景。

simulator.Init 初始化仿真，simulator.RunAll 执行仿真，simulator.PlotAllEvent 将绘制事件的时序图，simulator.PlotThroughput 将统计每个AP 的吞吐量、碰撞概率。

#### ApState.m

用于定义AP的状态，包括退避状态，其他人发包时HOLD等待状态，SEND发送状态。

#### Callback.m

代表事件对应的回调函数，包含触发时间，执行内容。

#### EventState.m

用于记录事件的状态，用于仿真输出。

#### Events.m

事件的状态，用三元组 `(起始时间, 终止时间, 状态)` 来定义一个事件。

#### Simulator.m

用于与各AP的事件与状态交互，实现整个仿真程序的运行。

#### AP.m

用于定义每个AP的行为逻辑和状态，与仿真器实现交互。

