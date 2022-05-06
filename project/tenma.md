### 调度方面

> 如果构建dag



> 如何确保dag没有成环



> 节点的暂停和kill

### 容错方面



### 分布式定时任务





### 资源方面

> 如何控制任务的优先级

扫描command的时候，command按照优先级排列

> 如何控制worker group

扫描command的时候， 机器只扫描属于当前worker group的命令，同事发送task到worker的时候也只往属于当前



> 如何控制任务多的时候不会将机器打爆





> 各版本Master和Worker通信原理





> 超时怎么解决



> kill, stop, pause， 



> worker容错是怎么样的



> master容错是怎么样的



> zookeeper目录

/scheduler/production/welab-skyscanner-tenma/

- dead-servers
  - worker_172.31.52.123:25551
- lock
  - masters
  - failover
    - masters
    - startup-masters
    - workers
- nodes
  - master
    - 10.240.42.161:25550（value=0.143,0.424,0.24,36.184,2.0,0.8,2022-04-24 17:56:14,2022-04-24 18:29:45,0,84,8,62.82）
  - worker
    - default_worker_group
      - 10.240.42.161:25551(value=0.138,0.424,1.33,36.179,2.0,0.8,2022-04-24 17:56:27,2022-04-24 18:32:46,0,84,8,62.82)
    - tiger





> 大版本改动

2021年之前， 



> 命令发送时， 怎么选择worker

启动时， ZookeeperNodeManager加载所有的Master, WorkerGroup和Worker节点， 并添加监听器监听这些路径的变化。保证节点信息是最新的。

在LowerWeightHostManager中，有一个定时任务每五秒钟从ZookeeperNodeManager获取WorkerGroup和Worker，然后去zk上获取他们的心跳信息。

同时，当ZookeeperNodeManager监听节点新增，删除时，除了同步自身保存的节点信息， 还要立即调用方法刷新LowerWeightHostManager中保存的Worker的信息。

当TaskPriorityQueueConsumer消费到需要发送的命令的时候， 挑选一个负载最低的host将命令发送过去。

负载的计算方法是， cpu使用率\*10+内存使用率\*20+平均负载\*70, 选择一个最小的发送



> Master的注册zk过程

在MasterRegistry中。先获取Master节点的根路径，然后在下面注册一个临时节点/scheduler/production/welab-skyscanner-tenma/nodes/master/172.31.28.20:25550， 其中节点名称是ip地址和master的通信端口。然后启动提交心跳任务到线程池中， 每60秒执行一次。心跳数据包含是`cpu使用率，内存使用率， 平均负载， 可用的物理内存(G)， 最大的cpu负载率， 最大内存使用率， 启动时间               心跳时间         节点状态(无用)   当前线程PID  cpu逻辑核心数   总的物理内存(G)`



> Worker的注册zk过程

在WorkerRegistry中。与Master相同，只是worker的心跳路径会有多个，因为worker可以属于多个worker group。

