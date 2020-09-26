#### Zookeeper工作机制

#### Zookeeper特点

![](\img\image-20200809124957328.png)

- 一个领导者（Leader），多个跟随者（Follower）组成集群
- <font color="red">集群中只要有**半数以上**节点存活，Zookeeper集群就能正常服务</font>

- 全局数据一致：每个Server保存一份相同的数据副本，Client无论连接到哪个Server，数据都是一致的
- 更新请求顺序进行，来自同一个Client的更新请求按其发送顺序依次执行

- 数据更新原子性：一次数据更新要么成功，要么失败
- 数据是实现性，在一定时间范围内，Client能读到最新数据

#### 数据结构

Zookeeper的数据模型整体上可以看作一个<font color="red">树形结构</font>，每个节点称作一个ZNode。每个ZNode默认能够<font color="red">存储1MB</font>的数据，每个ZNode都可以通过其<font color="red">路径唯一标识</font>

![](img\image-20200809130019141.png)

#### 应用场景

- 统一命名服务

  在分布式环境下，经常要对服务/应用进行统一的命名，便于识别。

  例如IP地址不同意记住，而域名容易记住。

  <img src="img\image-20200809130748728.png" style="zoom:50%;" />

- 统一配置管理（配置中心）

  需求

  1. 一般要求一个集群中所有节点的配置信息是一致的
  2. 对配置文件修改后，希望能够快速同步到各个节点上

  解决

  1. 将配置信息写入到Zookeeper上的一个ZNode
  2. 各个客户端监听这个ZNode

  <img src="img\image-20200809131304309.png" style="zoom:50%;" />

- 统一集群管理

  需求

  1. 实时掌握每个节点的状态，根据节点状态做出一些调整

  解决

  1. 将节点信息写入到Zookeeper上的ZNode
  2. 监听这个ZNode可以获取他的实时状态变化

  ![](img\image-20200809131817497.png)

- 服务器节点动态上下线

  ![](img\image-20200809152240521.png)

- 软负载均衡

  在Zookeeper中记录每台服务器的访问数，让访问数最少的服务器去处理最新的客户端请求

  ![](img\image-20200809174522988.png)

#### Zookeeper 相关命令

- linux：

  - zkServer.sh  start开启zookeeper

  - zkServer.sh stop关闭zookeeper

  - zkServer.sh status 查看状态

  - zkClient.sh开启客户端，默认连接localhost：2181，使用-server ip:port  指定客户端连接的zookeeper地址，进入客户端后quit关闭客户端

#### Zookeeper选举机制



#### Zookeeper节点类型

- 持久（Persistent）：客户端和服务器断开连接之后，创建的节点不删除
  - 持久化目录节点：客户端与zk断开连接后，该节点依旧存在
  - 持久化顺序编号目录节点：客户端与zk断开连接后，该节点依旧存在，只是zk给该节点名称进行顺序标号

- 短暂（Ephemeral）：客户端和服务器断开连接后，创建的节点自动删除
  - 临时目录节点：客户端与zk断开连接后，该节点被删除
  - 临时顺序编号目录节点：客户端与zk断开连接后，该节点被删除，只是zk给该节点名称进行顺序标号

说明：创建znode时设置顺序标识，znode后会附加一个值，顺序号是一个单调递增的计数器，由父节点维护。<font color="red">在分布式系统中，顺序号可以为所有的事件进行全局排序，这样客户端可以通过顺序号推断事件的顺序。</font>



#### zk集群搭建

#### zk Shell命令

#### zk stat消息体

#### zk监听器原理

![](img\image-20200809223220138.png)

#### zk写数据流程

![](img\image-20200809223719633.png)

