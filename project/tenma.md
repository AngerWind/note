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



