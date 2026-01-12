# 单机安装

1. 关闭防火墙

2. centos取消打开文件限制数量

   - 在 `/etc/security/limits.conf `和`/etc/security/limits.d/20-nproc.conf` 文件的末尾加入以下内容

     ~~~shell
     * soft nofile 65536
     * hard nofile 65536
     * soft nproc 131072
     * hard nproc 131072
     ~~~

3. 安装依赖

   ~~~shell
   sudo yum install -y libtool
   ~~~

4. centos 关闭selinux

   - 临时关闭使用`setenforce 0`, 不用重启
   - 永久关闭, 修改`/etc/selinux/config` 中的 `SELINUX=disabled`  

5. 在https://repo.clickhouse.tech/rpm/stable/x86_64/下载rpm包

   ![image-20220817220600234](img/clickhouse/image-20220817220600234.png)

   或者直接使用如下的命令

   ~~~shell
   wget https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-dbg-25.9.7.56.x86_64.rpm
   wget https://packages.clickhouse.com/rpm/stable/clickhouse-client-25.9.7.56.x86_64.rpm
   wget https://packages.clickhouse.com/rpm/stable/clickhouse-server-25.9.7.56.x86_64.rpm
   wget https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-25.9.7.56.x86_64.rpm
   ~~~

   

6. 通过rmp安装ck

   ~~~shell
   sudo rpm -ivh *.rpm
   ~~~

   安装过程中会提示输入默认用户`default`的密码, 如果不需要密码可以直接回车

   ![image-20220817220711636](img/clickhouse/image-20220817220711636.png)

7. 安装完成后, ck相关命令在分别在`/usr/bin/`下

   ![image-20220817221617245](img/clickhouse/image-20220817221617245.png)

   创建过程中将会创建一个clickhouse用户和clickhouse组

   ![image-20220817221720683](img/clickhouse/image-20220817221720683.png)

   ck的server配置文件在`/etc/clickhouse-server`

   ![image-20220817222012393](img/clickhouse/image-20220817222012393.png)

   ck的client配置文件在`/etc/clickhouse-client`

   ![image-20220817222103877](img/clickhouse/image-20220817222103877.png)

   ck的其他文件如下

   ![image-20220817222245038](img/clickhouse/image-20220817222245038.png)

8. 修改配置文件, 使得其他机器可以访问ck

   ~~~shell
   sudo vim /etc/clickhouse-server/config.xml
   ~~~

   把 <listen_host>::</listen_host> 的注释打开

   ![image-20220817222501241](img/clickhouse/image-20220817222501241.png)

9. 在`/etc/clickhouse-server/config.xml`中修改ck的tcp端口, 默认为9000, 容易冲突

   ~~~xml
   <tcp_port>9000</tcp_port>
   ~~~

10. 在`/etc/clickhouse-server/config.xml`可以修改ck日志打印相关配置

    ![image-20220817222702665](img/clickhouse/image-20220817222702665.png)

11. 关闭ck的开机自启, 因为是测试使用

    ~~~shell
    sudo systemctl disable clickhouse-server
    sudo systemctl start clickhouse-server
    ~~~

12. ck server启停命令

    ~~~shell
    systemctl start clickhouse-server
    clickhouse start
    clickhouse restart
    
    systemctl stop clickhouse-server
    clickhouse stop
    
    systemctl status clickhouse-server
    clickhouse status
    ~~~

13. 启动ck client

    ~~~shell
    # -m 交互式终端使用分号表示sql语句的结尾, 而不是回车
    # --query 'sql' 跟hive -e一样, 直接执行后面的sql, 而不是开启交互式终端
    clickhouse-client -m -h hostname -p port 
    ~~~

    


# 数据库引擎

在clickhouse中, 创建数据库的时候可以指定多种数据库引擎, 每种数据库引擎都有不一样的功能



## Atomic

开源版本的clickhouse默认使用的数据库引擎, sql语句如下

~~~sql
CREATE DATABASE test [ENGINE = Atomic] [SETTINGS disk=...];
~~~



他可以原子性的修改表的元数据, 比如

- drop table
- rename table
- alter table

等等, 而不会出现中间状态, 因为在atomic数据库中

- clickhouse会自动为每个表生成一个uuid, 当然你也可以自己指定, 但是不建议这么做

  ~~~shell
  CREATE TABLE name UUID '28f1c61c-2970-457a-bffe-454156ddcfef' (n UInt64) ENGINE = ...;
  ~~~

- 表的数据会保持到`/clickhouse_path/store/xxx/${table_uuid}/`

- 你可以通过如下的sql语句来查询表的uuid

  ~~~sql
  
  ~~~

  











# 表引擎

# 数据类型

#### 整型

有符号整型: Int8, Int16, Int32, Int64,  范围是(-2^n-1  ~ -2^(n-1) - 1)

无符号整型: UInt8, UInt16, UInt32, UInt64, 范围是(0 ~ 2^n - 1)

> 使用场景: 个数, 数量, id

#### 浮点型

Float32, Float64, 需要注意浮点数在计算的时候有误差

> 使用场景: 一般数据值比较小, 不涉及大量的统计计算, 精度要求不高, 比如商品的重量



#### 布尔类型

clickhouse中没有单独的boolean类型, 可以使用UInt8来代替, 取值限制为0或者1



#### Decimal

- Decimal32(n): 只能保存9位数字, n表示小数的位数

  **比如Decimal32(5)表示小数5位, 整数部分4位, 如果保存的小数位数超过了5位那么会直接截断**

- Decimal64(n): 只能保存18位数字, n表示小数位的位数

- Decimal128(n): 只能保存38位数字, n表示小数位的位数

> 使用场景是需要精确计算, 比如金额, 汇率



#### 字符串

- String: 字符串可以任务长度, 他可以包含任意的字节集, 包括空字节

- FixedString(N)

  长度固定为N的字符串, N必须是正整数. 

  当插入的数据长度小于N的时候, 会在字符串末尾填充空字节. 

  当插入的数据的长度超过N的时候, 会报错

  > 和String相比, 极少使用FixedString, 即使是固定长度的字段, 比如性别, 名称等等, 考虑到变化性会带来一定的风险且收益不够明显, 所以使用有限



#### 枚举类型

Enum8和Enum16

**实际上在Clickhouse中, Enum8和Enum16就是Int8和Int16, 包括数据存储也是使用的他们, Clickhouse会保存Enum到Int的转换, 然后在返回结果的时候进行转换**

~~~shell

~~~


