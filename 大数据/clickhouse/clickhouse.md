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

   之后你也可以在`/etc/clickhouse-server/users.xml`修改这个`default`用户的密码

7. 安装完成后, ck相关命令在分别在`/usr/bin/`下

   ![image-20220817221617245](img/clickhouse/image-20220817221617245.png)

   创建过程中将会创建一个clickhouse用户和clickhouse组

   ![image-20220817221720683](img/clickhouse/image-20220817221720683.png)

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
    # --password 指定密码, 没有密码的话不用指定password
    # --user指定用户, 如果不指定的话默认使用default用户
    clickhouse-client -m -h localhost --port 9000 --password 111
    ~~~




## clickhouse的相关目录

1. 在你安装完clickhouse之后, 他会将所有的可执行命令放在`/usr/bin`目录下面, 这样你就可以直接在终端执行命令了

   ![image-20260113231601464](img/clickhouse/image-20260113231601464.png)

2. 所有的clickhouse-server的配置文件都保存在`/etc/clickhouse-server`下

   ![image-20220817222012393](img/clickhouse/image-20220817222012393.png)

3. 所有的clickhouse-client的配置文件都保存在`/etc/clickhouse-client`

   ![image-20220817222103877](img/clickhouse/image-20220817222103877.png)

4. 所有的clickhouse-server的数据文件都保存在`/var/lib/clickhouse`

   ![image-20260113232147355](img/clickhouse/image-20260113232147355.png)

   - metadata中保存的是数据库和表相关的DDL sql文件, 也是数据库和表的元信息
   - store中保存的是所有atomic表的数据
   - uuid中保存的是表名到uuid的映射
   - metadata_dropped中保存的是已经删除的表的相关sql文件
   - data用于保存老版本的ordinary数据库的表数据


# 数据库引擎

在clickhouse中, 创建数据库的时候可以指定多种数据库引擎, 每种数据库引擎都有不一样的功能, 你可以通过如下sql来查看数据库使用的引擎

~~~sql
SHOW CREATE DATABASE demo;
~~~

他会显示建表语句中的数据库引擎的类型



## Atomic

开源版本的clickhouse默认使用的数据库引擎, sql语句如下

~~~sql
CREATE DATABASE test 
[ENGINE = Atomic] 
[SETTINGS disk=...];
~~~



atomic就是原子的意思, 表示他可以原子性的修改表的元数据, 比如drop table, rename table, alter table等等, 而不会出现中间状态, 因为在atomic数据库中

- 所有的元数据和数据都是保存到本地的`/var/lib/clickhouse/metadata`和`/var/lib/clickhouse/metadata`中, **所以一般都是单机版本的clickhouse使用这种数据库类型**

- clickhouse会自动为每个表生成一个uuid, 当然你也可以自己指定, 但是不建议这么做

  ~~~shell
  CREATE TABLE name UUID '28f1c61c-2970-457a-bffe-454156ddcfef' (
  n UInt64
  ) ENGINE = ...;
  ~~~

- 表的数据会保持到`/var/lib/clickhouse/store/xxx/xxxyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy/`, 其中xxx是uuid的前缀, 你可以通过如下的sql语句来查询表的uuid

  ~~~sql
  SELECT
      database,
      name,
      uuid
  FROM system.tables
  WHERE database = 'demo_atomic'
    AND name = 'events';
    
     ┌─database────┬─name───┬─uuid─────────────────────────────────┐
  1. │ demo_atomic │ events │ ba8c8dff-31c0-4cb4-a408-f051a7b82a31 │
     └─────────────┴────────┴──────────────────────────────────────┘
  ~~~

- 对于drop table, 不会立刻删除数据, 只是将表的元数据移动到了``/var/lib/clickhouse/metadata_dropped`, 并将这个表标记为删除, 之后再对表数据进行删除

- 你可以直接在建表语句的settings字段中指定disk, 表示存储表元数据目录

  ~~~sql
  CREATE TABLE db (n UInt64) ENGINE = Atomic SETTINGS disk=disk(type='local', path='/var/lib/clickhouse-disks/db_disk');
  ~~~

  如果没有指定的话, 那么默认会使用`database_disk.disk`中指定的磁盘

  你可以通过如下的sql来查看一个atomic数据库的表在本地的存放位置

  ~~~sql
  SELECT
      database,
      name,
      uuid,
      data_paths
  FROM system.tables
  WHERE database = 'demo_atomic'
    AND name = 'events';
     ┌─database────┬─name───┬─uuid─────────────────────────────────┬─data_paths──────────────────────────────────────────────────────────────┐
  1. │ demo_atomic │ events │ ba8c8dff-31c0-4cb4-a408-f051a7b82a31 │ ['/var/lib/clickhouse/store/ba8/ba8c8dff-31c0-4cb4-a408-f051a7b82a31/'] │
     └─────────────┴────────┴──────────────────────────────────────┴─────────────────────────────────────────────────────────────────────────┘
  ~~~

  

## Shared

Shared和Atomic类似, 能够支持元数据的原子更新, 每个表都有uuid, 数据都保在在`/var/lib/clickhouse/store/xxx/xxxyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy/`中

但是不同的点在于Shared数据库的元数据都保存在keeper中, 而不会保存在本地的`/var/lib/metadata/`中, 所以这种数据库引擎一般都是在clickhouse集群中使用, 多个实例共享元数据, 但是需要注意的是, 数据还是保存在本地的

要想使用Shared数据库引擎, 你必须:

- 运行Clickhouse Keeper 或者zookeeper
- 在`/etc/clickhouse-server/config.xml`中配置了keeper的地址
- 所有clickhouse的实力连接的同一个keeper

之后你就可以使用如下的sql来建立一个Shared数据库

~~~sql
CREATE DATABASE demo_shared
ENGINE = Shared;

-- 验证数据库类型
SHOW CREATE DATABASE demo_shared;
~~~







## Lazy

这种数据库引擎很少用, 他的核心目标只有一个: 减少内存占用

当你第一次使用这个表的时候,  clickhouse会磁盘中加载表结构和表的数据, 所以在第一次访问的时候会特别的慢

如果你在指定的时间之后不再访问这个表, 那么他又会将内存中的元数据和表数据卸载掉, 下次使用的时候重新加载

同时Lazy数据库引擎也没有DDL的原子性, 并且他只能和*Log模型的表一起使用

你在绝大部分场景中都不应该使用这种数据库引擎, 而是应该使用Atomic数据库引擎, 他只适合那些好久才使用一次的表

~~~sql
CREATE DATABASE testlazy 
ENGINE = Lazy(expiration_time_in_seconds); -- 指定多久之后卸载表
~~~





## Replicated

// todo



## PostgreSQL

用于将一整个Postgres数据库映射到ck中。**支持在ck中对pg进行select, insert(不支持update, delete)**，以便在 ClickHouse 和 PostgreSQL 之间交换数据。



他的使用场景是:

1. 维度表
2. 配置表
3. Lookup
4. 查询范围小, 条件过滤强的sql

千万不要在ck中进行大数据量的查询pg



你可以通过如下的sql来创建一个PostgresSQL

~~~sql
CREATE DATABASE test_database
ENGINE = PostgreSQL(
    'host:port', 'database', 'user', 'password'[, `schema`, `use_table_cache`]);
~~~

- use_table_cache表示是否缓存pg的表结构到ck中, 默认值为0, 表示实时查询pg的表结构, 如果设置为1, 那么将会缓存pg的表结构, 在使用的时候不再实时查询

- 如果pg中的表结构变更了, 那么你也可以使用`detach`和`attach`查询进行更新

你可以通过 `SHOW TABLES` 和 `DESCRIBE TABLE` 实时访问远程 PostgreSQL 中的表列表和表结构。



使用这种数据库引擎的时候, 会将pg表中的字段类型映射为ck的字段类型

| PostgreSQL       | ClickHouse                                                   |
| ---------------- | ------------------------------------------------------------ |
| DATE             | [Date](https://clickhouse.com/docs/sql-reference/data-types/date) |
| TIMESTAMP        | [DateTime](https://clickhouse.com/docs/sql-reference/data-types/datetime) |
| REAL             | [Float32](https://clickhouse.com/docs/sql-reference/data-types/float) |
| DOUBLE           | [Float64](https://clickhouse.com/docs/sql-reference/data-types/float) |
| DECIMAL, NUMERIC | [Decimal](https://clickhouse.com/docs/sql-reference/data-types/decimal) |
| SMALLINT         | [Int16](https://clickhouse.com/docs/sql-reference/data-types/int-uint) |
| INTEGER          | [Int32](https://clickhouse.com/docs/sql-reference/data-types/int-uint) |
| BIGINT           | [Int64](https://clickhouse.com/docs/sql-reference/data-types/int-uint) |
| SERIAL           | [UInt32](https://clickhouse.com/docs/sql-reference/data-types/int-uint) |
| BIGSERIAL        | [UInt64](https://clickhouse.com/docs/sql-reference/data-types/int-uint) |
| TEXT, CHAR       | [String](https://clickhouse.com/docs/sql-reference/data-types/string) |
| INTEGER          | Nullable([Int32](https://clickhouse.com/docs/sql-reference/data-types/int-uint)) |
| ARRAY            | [Array](https://clickhouse.com/docs/sql-reference/data-types/array) |



### 使用案例

1. 在ck中映射pg数据库

   ~~~sql
   CREATE DATABASE test_database
   ENGINE = PostgreSQL('postgres1:5432', 'test_database', 'postgres', 'mysecretpassword', 'schema_name',1);
   
   SHOW DATABASES;
   ┌─name──────────┐
   │ default       │
   │ test_database │
   │ system        │
   └───────────────┘
   ~~~

2. 在ck中查询表结构和数据

   ~~~sql
   SHOW TABLES FROM test_database;
   ┌─name───────┐
   │ test_table │
   └────────────┘
   
   DESCRIBE TABLE test_database.test_table;
   ┌─name───┬─type──────────────┐
   │ id     │ Nullable(Integer) │
   │ value  │ Nullable(Integer) │
   └────────┴───────────────────┘
   
   SELECT * FROM test_database.test_table;
   ┌─id─┬─value─┐
   │  1 │     2 │
   └────┴───────┘
   ~~~

3. 通过ck插入数据到pg中

   ~~~sql
   INSERT INTO test_database.test_table VALUES (3,4);
   SELECT * FROM test_database.test_table;
   ┌─int_id─┬─value─┐
   │      1 │     2 │
   │      3 │     4 │
   └────────┴───────┘
   ~~~

4. 通过pg修改表结构, 因为`use_table_cache`设置为了1, 所以会缓存元数据, 如果元数据变更了, 需要手动同步

   ~~~sql
   -- 修改pg中的表结构
   postgre> ALTER TABLE test_table ADD COLUMN data Text
   
   -- ck中查看表结构, 未发生变化
   ┌─name───┬─type──────────────┐
   │ id     │ Nullable(Integer) │
   │ value  │ Nullable(Integer) │
   └────────┴───────────────────┘
   
   -- 手动同步表结构, 二选一即可
   DETACH TABLE test_database.test_table;
   ATTACH TABLE test_database.test_table;
   
   -- 重新查询
   DESCRIBE TABLE test_database.test_table;
   ┌─name───┬─type──────────────┐
   │ id     │ Nullable(Integer) │
   │ value  │ Nullable(Integer) │
   │ data   │ Nullable(String)  │
   └────────┴───────────────────┘
   ~~~



## MySQL

和Postgres数据库引擎一样, 用于将mysql中的整个数据库映射到ck中, **支持在ck中对mysql进行select, insert(不支持update, delete)**

~~~sql
CREATE DATABASE [IF NOT EXISTS] db_name [ON CLUSTER cluster]
ENGINE = MySQL('host:port', 'database' , 'user', 'password')
~~~







ck会将mysql中的数据类型转换为对应的ck数据类型, 如下是映射关系

| MySQL                            | ClickHouse                                                   |
| -------------------------------- | ------------------------------------------------------------ |
| UNSIGNED TINYINT                 | [UInt8](https://clickhouse.com/docs/sql-reference/data-types/int-uint) |
| TINYINT                          | [Int8](https://clickhouse.com/docs/sql-reference/data-types/int-uint) |
| UNSIGNED SMALLINT                | [UInt16](https://clickhouse.com/docs/sql-reference/data-types/int-uint) |
| SMALLINT                         | [Int16](https://clickhouse.com/docs/sql-reference/data-types/int-uint) |
| UNSIGNED INT, UNSIGNED MEDIUMINT | [UInt32](https://clickhouse.com/docs/sql-reference/data-types/int-uint) |
| INT, MEDIUMINT                   | [Int32](https://clickhouse.com/docs/sql-reference/data-types/int-uint) |
| UNSIGNED BIGINT                  | [UInt64](https://clickhouse.com/docs/sql-reference/data-types/int-uint) |
| BIGINT                           | [Int64](https://clickhouse.com/docs/sql-reference/data-types/int-uint) |
| FLOAT                            | [Float32](https://clickhouse.com/docs/sql-reference/data-types/float) |
| DOUBLE                           | [Float64](https://clickhouse.com/docs/sql-reference/data-types/float) |
| DATE                             | [Date](https://clickhouse.com/docs/sql-reference/data-types/date) |
| DATETIME, TIMESTAMP              | [DateTime](https://clickhouse.com/docs/sql-reference/data-types/datetime) |
| BINARY                           | [FixedString](https://clickhouse.com/docs/sql-reference/data-types/fixedstring) |

其他所有类型的字段, 都映射为ck中的String类型



### 使用案例

1. 在mysql中建表

   ~~~sql
   mysql> USE test;
   Database changed
   
   mysql> CREATE TABLE `mysql_table` (
       ->   `int_id` INT NOT NULL AUTO_INCREMENT,
       ->   `float` FLOAT NOT NULL,
       ->   PRIMARY KEY (`int_id`));
   Query OK, 0 rows affected (0,09 sec)
   
   mysql> insert into mysql_table (`int_id`, `float`) VALUES (1,2);
   Query OK, 1 row affected (0,00 sec)
   
   mysql> select * from mysql_table;
   +------+-----+
   | int_id | value |
   +------+-----+
   |      1 |     2 |
   +------+-----+
   1 row in set (0,00 sec)
   ~~~

2. 在ck中操作mysql

   ~~~sql
   CREATE DATABASE mysql_db ENGINE = MySQL('localhost:3306', 'test', 'my_user', 'user_password') SETTINGS read_write_timeout=10000, connect_timeout=100;
   
   SHOW DATABASES
   ┌─name─────┐
   │ default  │
   │ mysql_db │
   │ system   │
   └──────────┘
   
   SHOW TABLES FROM mysql_db
   ┌─name─────────┐
   │  mysql_table │
   └──────────────┘
   
   SELECT * FROM mysql_db.mysql_table
   ┌─int_id─┬─value─┐
   │      1 │     2 │
   └────────┴───────┘
   
   INSERT INTO mysql_db.mysql_table VALUES (3,4)
   SELECT * FROM mysql_db.mysql_table
   ┌─int_id─┬─value─┐
   │      1 │     2 │
   │      3 │     4 │
   └────────┴───────┘
   ~~~

   

## SQLite

和PostgreSQL一样, 用于将一整个sqlite数据库映射到ck中

~~~sql
    CREATE DATABASE sqlite_database
    ENGINE = SQLite('db_path') -- 指定sqlite的文件路径
~~~

ck会将sqlite中的数据类型映射为ck中的数据类型, 映射关系如下

| SQLite  | ClickHouse                                                   |
| ------- | ------------------------------------------------------------ |
| INTEGER | [Int32](https://clickhouse.com/docs/sql-reference/data-types/int-uint) |
| REAL    | [Float32](https://clickhouse.com/docs/sql-reference/data-types/float) |
| TEXT    | [String](https://clickhouse.com/docs/sql-reference/data-types/string) |
| BLOB    | [String](https://clickhouse.com/docs/sql-reference/data-types/string) |



### 使用案例

1. 在ck中创建sqlite的映射

   ~~~sql
   CREATE DATABASE sqlite_db ENGINE = SQLite('sqlite.db');
   ~~~

2. 查询数据

   ~~~sql
   SHOW TABLES FROM sqlite_db;
   ┌──name───┐
   │ table1  │
   │ table2  │
   └─────────┘
   
   SELECT * FROM sqlite_db.table1;
   ┌─col1──┬─col2─┐
   │ line1 │    1 │
   │ line2 │    2 │
   │ line3 │    3 │
   └───────┴──────┘
   ~~~

3. 将ck中的数据插入到sqlite中

   ~~~sql
   CREATE TABLE clickhouse_table(
       `col1` String,
       `col2` Int16
   ) ENGINE = MergeTree() ORDER BY col2;
   
   INSERT INTO clickhouse_table VALUES ('text',10);
   
   INSERT INTO sqlite_db.table1 SELECT * FROM clickhouse_table;
   
   SELECT * FROM sqlite_db.table1;
   ┌─col1──┬─col2─┐
   │ line1 │    1 │
   │ line2 │    2 │
   │ line3 │    3 │
   │ text  │   10 │
   └───────┴──────┘
   ~~~

   

## Backup

在ck中, 运行你通过backup和restore命令来备份恢复数据库和表, backup会为数据库创建一个备份

当然你可以将这个备份创建为一个数据库, 然后对这个数据库进行查询

想要具体了解可以查看

https://clickhouse.com/docs/engines/database-engines/backup

https://clickhouse.com/docs/operations/backup/disk





## MaterializedPostgreSQL

使用这种数据库引擎, 在创建数据库的时候必须指定要同步的pg的表, 之后ck会开始全量同步这些表中的数据到ck中, 之后从pg 的wal中拉取后续的更新到ck中, 进行增量同步



你可以通过如下的sql来创建数据库

~~~sql
CREATE DATABASE [IF NOT EXISTS] db_name [ON CLUSTER cluster]
ENGINE = MaterializedPostgreSQL(
    'host:port', 'database', 'user', 'password'
) 
[SETTINGS ...]
~~~

根据settings他有三种模式

1. 一个 `MaterializedPostgreSQL` 引擎数据库, 同步pg中的一整个schema中的所有的表

   ~~~sql
   CREATE DATABASE postgres_database
   ENGINE = MaterializedPostgreSQL(
       'postgres1:5432', 'postgres_database', 'postgres_user', 'postgres_password'
   )
   SETTINGS 
   -- 指定同步的schema, 会自动同步所有的表
   materialized_postgresql_schema = 'postgres_schema';
   
   SELECT * FROM postgres_database.table1;
   ~~~

   之后你可以使用pg中表名在ck中进行查询

   ~~~sql
   SELECT * FROM postgres_database.table1;
   ~~~

2. 一个 `MaterializedPostgreSQL` 引擎数据库, 同步多个schema下的多个表

   ~~~sql
   CREATE DATABASE database1
   ENGINE = MaterializedPostgreSQL(
       'postgres1:5432', 'postgres_database', 'postgres_user', 'postgres_password'
   )
   SETTINGS 
   -- 指定需要同步的表
   materialized_postgresql_tables_list = 'schema1.table1,schema2.table2,schema1.table3',
   materialized_postgresql_tables_list_with_schema = 1;
   ~~~

   之后你需要通过`schema_name.table_name`来访问表

   ~~~sql
   SELECT * FROM database1.`schema1.table1`;
   SELECT * FROM database1.`schema2.table2`;
   ~~~

3. 一个 `MaterializedPostgreSQL` 引擎数据库, 同步pg中的多个schema的所有的表

   ~~~sql
   CREATE DATABASE database1
   ENGINE = MaterializedPostgreSQL(
       'postgres1:5432', 'postgres_database', 'postgres_user', 'postgres_password'
   )
   SETTINGS 
   -- 指定要同步的schema
   materialized_postgresql_schema_list = 'schema1,schema2,schema3';
   ~~~

   之后你可以通过如下的sql来访问这些表

   ~~~sql
   SELECT * FROM database1.`schema1.table1`;
   SELECT * FROM database1.`schema1.table2`;
   SELECT * FROM database1.`schema2.table2`;
   ~~~



在同步的时候, 你也可以同步表中指定的列

~~~sql
REATE DATABASE database1
ENGINE = MaterializedPostgreSQL(
    'postgres1:5432', 'postgres_database', 'postgres_user', 'postgres_password'
)
SETTINGS 
materialized_postgresql_tables_list = 'schema1.table1(co1, col2),schema1.table2,schema1.table3(co3, col5, col7)
~~~





需要注意的是:

1. 这种数据库引擎是实验性质的, 要使用他需要再配置文件中将`allow_experimental_database_materialized_postgresql` 设置为 1，或使用 `SET` 命令：

   ~~~sql
   SET allow_experimental_database_materialized_postgresql=1
   ~~~

2. 如果pg中后续增加了新表, 那么不会自动同步, 需要你手动

   ~~~sql
   -- 手动指定需要同步的新表, 然后ck会开始同步数据到ck中
   ATTACH TABLE postgres_database.new_table;
   ~~~

3. PostgreSQL的复制协议不允许复制表结构的变更, 但是表结构的变更可以被检测到, 所以一到pg中的表结构发生了变更, 比如添加/删除了字段, 那么ck就会停止同步这个表, 你需要使用 `ATTACH` / `DETACH PERMANENTLY` 查询来完全重新加载表。如果 DDL 语句没有破坏复制（例如，重命名列），则表仍会接收更新（插入操作按位置执行）。



使用这种数据库对pg有如下的要求

1. 在 PostgreSQL 配置文件中， [wal_level](https://www.postgresql.org/docs/current/runtime-config-wal.html) 设置的值必须为 `logical` ， `max_replication_slots` 参数的值必须至少为 `2` 。

2. 每个复制的表都必须要下面二者之一

   - 主键

   - 唯一索引, 并且将唯一索引设置为replica Identity

     ~~~sql
     postgres# CREATE TABLE postgres_table (a Integer NOT NULL, b Integer, c Integer NOT NULL, d Integer, e Integer NOT NULL);
     postgres# CREATE unique INDEX postgres_table_index on postgres_table(a, c, e);
     postgres# ALTER TABLE postgres_table REPLICA IDENTITY USING INDEX postgres_table_index;
     ~~~



## DataLakeCatalog

`DataLakeCatalog` 数据库引擎使您能够将 ClickHouse 连接到外部的catalog，并进行数据查询，而无需重复数据。这使 ClickHouse 转变为一个强大的查询引擎，可与您现有的数据湖基础架构无缝协作。

`DataLakeCatalog` 引擎支持以下catalog：

- **AWS Glue Catalog** -  AWS 环境中的 Iceberg 表
- **Databricks Unity Catalog** - 适用于 Delta Lake 和 Iceberg 表
- **Hive Metastore** - 适用于hive的catalog
- **REST Catalogs** - 任何支持 Iceberg REST 规范的目录



更多细节和使用案例查看https://clickhouse.com/docs/engines/database-engines/datalakecatalog



# 数据类型

## 整型

有符号整型: Int8, Int16, Int32, Int64, Int128, Int256

无符号整型: UInt8, UInt16, UInt32, UInt64, UInt128, UInt256

他们是范围和Java中的范围类型



上述的类型也有他们的别名, 如下面的表格

| Type    | Alias                                                        |
| ------- | ------------------------------------------------------------ |
| `Int8`  | `TINYINT`, `INT1`, `BYTE`, `TINYINT SIGNED`, `INT1 SIGNED`   |
| `Int16` | `SMALLINT`, `SMALLINT SIGNED`                                |
| `Int32` | `INT`, `INTEGER`, `MEDIUMINT`, `MEDIUMINT SIGNED`, `INT SIGNED`, `INTEGER SIGNED` |
| `Int64` | `BIGINT`, `SIGNED`, `BIGINT SIGNED`, `TIME`                  |
| `UInt8`  | `TINYINT UNSIGNED`, `INT1 UNSIGNED`                      |
| `UInt16` | `SMALLINT UNSIGNED`                                      |
| `UInt32` | `MEDIUMINT UNSIGNED`, `INT UNSIGNED`, `INTEGER UNSIGNED` |
| `UInt64` | `UNSIGNED`, `BIGINT UNSIGNED`, `BIT`, `SET`              |

> 使用场景: 个数, 数量, id





## 浮点型

Float32, Float64, 需要注意浮点数在计算的时候有误差

他们的别名如下

| Type      | Alias                        |
| --------- | ---------------------------- |
| `Float32` | `FLOAT`, `REAL`, `SINGLE`    |
| `Float64` | `DOUBLE`, `DOUBLE PRECISION` |



> 使用场景: 一般数据值比较小, 不涉及大量的统计计算, 精度要求不高, 比如商品的重量



## 布尔类型

`bool` 类型在内部存储为 UInt8。可能的值为 `true`(内部存储1) ， `false` (内部存储0)

~~~sql
SELECT true AS col, toTypeName(col);
┌─col──┬─toTypeName(true)─┐
│ true │ Bool             │
└──────┴──────────────────┘

select true == 1 as col, toTypeName(col);
┌─col─┬─toTypeName(equals(true, 1))─┐
│   1 │ UInt8                       │
└─────┴─────────────────────────────┘

-- 在插入的时候, 你也可以直接通过1/0来表示true/false
CREATE TABLE test_bool( `A` Int64, `B` Bool )
ENGINE = Memory;

INSERT INTO test_bool VALUES (1, true),(2,0);
SELECT * FROM test_bool;
┌─A─┬─B─────┐
│ 1 │ true  │
│ 2 │ false │
└───┴───────┘
~~~





## Decimal

- Decimal32(S): 只能保存9位数字, S表示小数的位数

  **比如Decimal32(5)表示小数5位, 整数部分4位, 如果保存的小数位数超过了5位那么会直接截断**

  所以他的取值范围是[-9999.9999, 9999.9999]

- Decimal64(S): 只能保存18位数字, S表示小数位的位数

- Decimal128(S): 只能保存38位数字, S表示小数位的位数

- Decimal128(S): 只能保存76位数字, S表示小数的位数



当然如果你觉得上面的类型太麻烦了, 那么你也可以使用下面两种类型

- Decimal(P, S): 其中P表示能够保存的数字的长度, S表示小数部分的长度, P的取值为[1, 76], S的取值为[0, P]

  比如Decimal(32, 15)就表示保存的数字长度为32位, 小数部分15位, 超过直接截断

  - 如果P是1~9, 那么你实际上就是在使用Decimal32(S)
  - 如果P是10~18, 那么实际上就是使用的Decimal64(S)
  - 如果P是19~38, 那么你实际上就是在使用Decimal128(S)
  - 如果P是39~76, 那么实际上就是使用的Decimal256(S)

- Decimal(P): 等效于Decimal(P, 0), 即没有小数部分

- Decimal: 等效于Decimal(10, 0), 没有小数部分



比如Decimal(10, 4)表示保存10位数字, 其中小数位4位, 整数部分6位

~~~sql
create table decimal_test (
    x Decimal(10, 4)
) engine = TinyLog;

-- 数据被截断
insert into decimal_test values (123456.1234567);

select * from decimal_test;
   ┌───────────x─┐
1. │ 123456.1234 │
   └─────────────┘
~~~



> 使用场景是需要精确计算, 比如金额, 汇率



## 字符串

- String: 字符串可以任务长度, 他可以包含任意的字节集, 包括空字节

- FixedString(N)

  长度固定为N的字符串, N必须是正整数. 

  当插入的数据长度小于N的时候, 会在字符串末尾填充空字节. 

  当插入的数据的长度超过N的时候, 会报错

  > 和String相比, 极少使用FixedString, 即使是固定长度的字段, 比如性别, 名称等等, 考虑到变化性会带来一定的风险且收益不够明显, 所以使用有限



## 枚举类型

Enum8和Enum16

**实际上在Clickhouse中, Enum8和Enum16就是Int8和Int16, 包括数据存储也是使用的他们, Clickhouse会保存Enum到Int的转换, 然后在返回结果的时候进行转换**

~~~sql
create table test_enum (
    x Enum8 ('hello'=1, 'world'=2, 'nihao'=3)
)
engine = TinyLog;

-- 在插入的时候可以直接使用字符串, 或者数字
insert into test_enum values ('hello'), ('world'), (1);

-- 查询
select * from test_enum;
   ┌─x─────┐
1. │ hello │
2. │ world │
3. │ hello │
   └───────┘
   
-- 查询的时候也可以转换为对应的数字
select cast(x, 'Int8') from test_enum
   ┌─CAST(x, 'Int8')─┐
1. │               1 │
2. │               2 │
3. │               1 │
   └─────────────────┘

-- 插入不存在的枚举指会报错
insert into test_enum values ('haha');
Error on processing query: Code: 691. DB::Exception: Unknown element 'haha' for enum
~~~

Enum8和Enum18主要使用在一些状态的字段上面, 算是一种空间优化, 也算是一种数据约束

但是在实际使用过程中往往因为一些**数据内容的变化**而增加一定的维护成本, 所以谨慎使用



## 时间类型

目前Clickhouse中有三种时间类型

- Date: 类似'2019-12-16'
- Datetime: 类似'2019-12-16 20:50:10'
- Datetime64: 精确到毫秒, 类似'2019-12-16 20:50:10.66'



## 数组

Array(T): 由T类型元素构成的数组, T可以是任意类型, 包括数组

但是不推荐使用多维数组, 因为Clickhouse对多维数组的支持有限, 比如不能再MergeTree中存储多维数组



创建方式

1. 使用array函数

   ~~~sql
   -- array构造一个数组, toTypeName获取字段的类型
   select array(1, 2) as x, toTypeName(x) ;
      ┌─x─────┬─toTypeName(x)─┐
   1. │ [1,2] │ Array(UInt8)  │
      └───────┴───────────────┘
      
   -- array中的元素只能有一个类型, 否则会报错
   select array(1, 2, 'haha') as x, toTypeName(x) ;
   Code: 386. DB::Exception: Received from localhost:9000. DB::Exception: There is no supertype for types UInt8, UInt8, String because some of them are String/FixedString/Enum and some of them are not: In scope SELECT [1, 2, 'haha'] AS x, toTypeName(x). (NO_COMMON_TYPE)
   ~~~

2. 使用中括号创建数组

   ~~~sql
   select [1, 2] as x, toTypeName(x) ;
      ┌─x─────┬─toTypeName(x)─┐
   1. │ [1,2] │ Array(UInt8)  │
      └───────┴───────────────┘
   ~~~



## Nullable



# 表引擎

