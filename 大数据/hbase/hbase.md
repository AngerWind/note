### Hbase安装

1. 安装zk

2. 配置时间同步

3. 启动hdfs

4. 解压tar包到指定目录

5. 配置环境变量HBASE_HOME

6. 修改conf/hbase-env.sh

   ~~~shell
   # 指定使用外部的zk而不是自带的zk
   export HBASE_MANAGES_ZK=false 
   ~~~

7. 修改hbase-site.xml

   ~~~xml
   <configuration>
       <property>
           <!-- 指定hdfs地址 -->
           <name>hbase.rootdir</name>
           <value>hdfs://hadoop102:9000/HBase</value>
       </property>
       <!-- 指定hbase开启分布式 -->
       <property>
           <name>hbase.cluster.distributed</name>
           <value>true</value>
       </property>
       <!-- 配置hbase 端口 -->
       <property>
           <name>hbase.master.port</name>
           <value>16000</value>
       </property>
       <!-- 配置zk地址 -->
       <property>
           <name>hbase.zookeeper.quorum</name>
           <value>hadoop102,hadoop103,hadoop104</value>
       </property>
       <!-- 配置hbase在本机的数据目录, 默认${java.io.tmpdir}/hbase-${user.name} -->
       <property>
           <name>hbase.tmp.dir</name>
           <value>../tmp</value>
       </property>
   </configuration>
   ~~~

8. 修改regionservers

   ~~~shell
   hadoop102
   hadoop103
   hadoop104
   ~~~

9. 将hbase发送到其他机器上面

10. 集群停止和启动

    ~~~~shell
    start-hbase.sh # 在执行该命令的机器上面启动HMaster
    
    stop-hbase.sh
    ~~~~

11. 单节点启动和停止

    ~~~shell
    hbase-daemon.sh start master
    hbase-daemon.sh start regionserver
    
    hbase-daemon.sh stop master
    hbase-daemon.sh stop regionserver
    ~~~

12. 查看hbase页面

    http://hadoop102:16010  

13. shell客户端连接hbase

    ~~~~shell
    hbase shell
    
    hbase:004:0>help #查看所有命令
    hbase:004:0>help "list" #查看具体的命令帮助
    ~~~~



#### Hbase 命令

> 一般操作

~~~~shell
# 查看所有命令
hbase:018:0>help

# 查看具体命令用法
hbase:018:0>help "command"

# 查看系统状态
hbase:018:0> status
1 active master, 0 backup masters, 3 servers, 0 dead, 0.6667 average load

# 查看版本
hbase:019:0> version
2.4.11, r7e672a0da0586e6b7449310815182695bc6ae193, Tue Mar 15 10:31:00 PDT 2022
~~~~

> namespace

~~~shell
# 创建命名空间
hbase> create_namespace 'ns1'
hbase> create_namespace 'ns1', {'PROPERTY_NAME'=>'PROPERTY_VALUE'}

hbase> list_namespace # 查看所有命名空间
hbase> list_namespace 'abc.*' # 根据正则表达式查看命名空间

hbase> describe_namespace 'ns1' # 查看命名空间属性

hbase> drop_namespace 'ns1' # 删除命名空间
~~~

> ddl