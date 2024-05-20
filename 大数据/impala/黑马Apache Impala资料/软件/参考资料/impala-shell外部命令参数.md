### impala-shell外部命令参数

| **选项**                                                   | **描述**                                                     |
| ---------------------------------------------------------- | ------------------------------------------------------------ |
| -B   or --delimited                                        | 导致使用分隔符分割的普通文本格式打印查询结果。当为其他 Hadoop 组件生成数据时有用。对于避免整齐打印所有输出的性能开销有用，特别是使用查询返回大量的结果集进行基准测试的时候。使用 --output_delimiter 选项指定分隔符。使用 -B 选项常用于保存所有查询结果到文件里而不是打印到屏幕上。在 Impala   1.0.1 中添加 |
| --print_header                                             | 是否打印列名。整齐打印时是默认启用。同时使用 -B 选项时，在首行打印列名 |
| -o filename or   --output_file filename                    | 保存所有查询结果到指定的文件。通常用于保存在命令行使用 -q 选项执行单个查询时的查询结果。对交互式会话同样生效；此时你只会看到获取了多少行数据，但看不到实际的数据集。当结合使用   -q 和 -o 选项时，会自动将错误信息输出到 /dev/null(To suppress these incidental messages when   combining the -q and -o options,   redirect stderr to /dev/null)。在   Impala 1.0.1 中添加 |
| --output_delimiter=character                               | 当使用   -B 选项以普通文件格式打印查询结果时，用于指定字段之间的分隔符(Specifies   the character to use as a delimiter between fields when query results are   printed in plain format by the -B option)。默认是制表符 tab ('\t')。假如输出结果中包含了分隔符，该列会被引起且/或转义( If an output value contains the delimiter character,   that field is quoted and/or escaped)。在 Impala 1.0.1 中添加 |
| -p   or --show_profiles                                    | 对   shell 中执行的每一个查询，显示其查询执行计划 (与 EXPLAIN 语句输出相同) 和发生低级故障(low-level breakdown)的执行步骤的更详细的信息 |
| -h   or --help                                             | 显示帮助信息                                                 |
| -i hostname or   --impalad=hostname                        | 指定连接运行 impalad 守护进程的主机。默认端口是 21000。你可以连接到集群中运行 impalad 的任意主机。假如你连接到 impalad 实例通过 --fe_port 标志使用了其他端口，则应当同时提供端口号，格式为 hostname:port |
| -q query or   --query=query                                | 从命令行中传递一个查询或其他 shell 命令。执行完这一语句后 shell 会立即退出。限制为单条语句，可以是 SELECT, CREATE TABLE, SHOW TABLES, 或其他 impala-shell 认可的语句。因为无法传递 USE 语句再加上其他查询，对于 default 数据库之外的表，应在表名前加上数据库标识符(或者使用 -f 选项传递一个包含 USE 语句和其他查询的文件) |
| -f query_file or   --query_file=query_file                 | 传递一个文件中的 SQL 查询。文件内容必须以分号分隔            |
| -k   or --kerberos                                         | 当连接到   impalad 时使用 Kerberos 认证。如果要连接的 impalad 实例不支持 Kerberos，将显示一个错误 |
| -s kerberos_service_name or   --kerberos_service_name=name | Instructs impala-shell to   authenticate to a particular impalad service principal. 如何没有设置 kerberos_service_name ，默认使用   impala。如何启用了本选项，而试图建立不支持 Kerberos 的连接时，返回一个错误(If   this option is used in conjunction with a connection in which Kerberos is not   supported, errors are returned) |
| -V   or --verbose                                          | 启用详细输出                                                 |
| --quiet                                                    | 关闭详细输出                                                 |
| -v   or --version                                          | 显示版本信息                                                 |
| -c                                                         | 查询执行失败时继续执行                                       |
| -r   or --refresh_after_connect                            | 建立连接后刷新 Impala 元数据，与建立连接后执行 [REFRESH](http://www.cloudera.com/content/cloudera-content/cloudera-docs/Impala/latest/Installing-and-Using-Impala/ciiu_langref_sql.html#refresh_unique_1) 语句效果相同 |
| -d default_db or   --database=default_db                   | 指定启动后使用的数据库，与建立连接后使用 [USE](http://www.cloudera.com/content/cloudera-content/cloudera-docs/Impala/latest/Installing-and-Using-Impala/ciiu_langref_sql.html#use_unique_1) 语句选择数据库作用相同，如果没有指定，那么使用 default 数据库 |
| -l                                                         | 启用 LDAP 认证                                               |
| -u                                                         | 当使用 -l 选项启用 LDAP 认证时，提供用户名(使用短用户名，而不是完整的 LDAP 专有名称(distinguished name)) ，shell 会提示输入密码 |