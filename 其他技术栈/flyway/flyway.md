https://medium.com/@AlexanderObregon/using-spring-boot-with-flyway-to-manage-database-migrations-8180ce0c9230



### Flyway和SrpingBoot集成

管理数据库模式的长期变更，是后端系统开发中最棘手的部分之一。Flyway 通过 SQL 或基于 Java 的迁移脚本对模式变更进行版本控制，从而解决了这个问题。

Spring Boot 则让 Flyway 能够轻松地集成到应用程序生命周期中。今天，我们将深入探讨 Flyway 如何与 Spring Boot 协同工作，如何组织迁移脚本，如何安全地对变更进行版本控制，以及如何让所有操作在启动时自动执行。您还将了解 API 密钥认证和完整用户授权之间的区别，以及如何确保数据库迁移过程的安全。



#### Flyway如何在SpringBoot中自动运行Migrations

要想使用flyway和springboot集成, 只需要添加对应的flyway的依赖, springboot就会将其集成到启动流程中, 从而正常的执行你的migrations脚本

~~~xml
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>
~~~

flyway会集成到springboot初始化的早期阶段, 当程序启动并从spring上下文开始加载bean的时候, springboot会通过classpath中是否存在`flyway-core`这个依赖来检测flyway,  这会触发flyway的自动配置

Spring Boot 检测到 Flyway 后，会创建一个 `FlywayAutoConfiguration` bean, 并通过这个bean来实现自动配置. 迁移操作会在任何 `@PostConstruct` 方法、 `ApplicationRunner` 或 `CommandLineRunner` 代码执行之前运行。这种顺序是特意安排的，因为 Flyway 需要在任何程序尝试使用数据库之前更新数据库模式。

默认情况下，Flyway 会在以下位置查找迁移脚本：

~~~xml
src/main/resources/db/migration
~~~

您可以使用 `application.properties` 或 `application.yml` 文件中的以下属性来更改此位置：

~~~properties
spring.flyway.locations=classpath:/custom-folder
~~~

Flyway 的migrations脚本遵循以下的命名格式

~~~txt
V1__init_schema.sql
V2__add_index_to_table.sql
~~~

Flyway 会解析这些文件名以确定其顺序。前缀 `V` 是版本号的缩写，双下划线将版本号与易于理解的描述分隔开。`migration`文件夹中任何其他不符合此格式的文件都将被忽略。

> Flyway 并不要求版本号必须连续，所以跳过一个版本本身不会造成任何问题。但是，如果您之后添加的脚本版本低于最新应用的版本，则会被视为乱序，除非启用了 `outOfOrder` 设置，否则 Flyway 将停止运行。
>
> 更改已应用的脚本仍然会导致校验和不匹配，Flyway 会报错退出。





#### 事务

当数据库支持事务时，Flyway 会使用事务来运行迁移。在 PostgreSQL 等系统中，这意味着给定迁移的所有模式更改要么全部成功，要么全部失败。这提供了强大的安全保障，尤其是在升级期间。

对于不支持 DDL 事务的数据库（例如旧版本的 MySQL），Flyway 会回退到事务之外来执行这些命令，但仍会在元数据中跟踪这些命令。

以下是 Flyway 如何自动将迁移操作封装在事务块中的示例（这是概念上的，不是脚本中实际显示的内容，但我认为这是一个很好的可视化示例）：

~~~sql
BEGIN;
-- contents of V1__init_schema.sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
COMMIT;
~~~

如果创建表失败，则事务将被回滚，并且迁移将在 Flyway 的内部跟踪表中标记为失败。



#### 锁

为了防止竞态条件，Flyway 使用 `SELECT ... FOR UPDATE` （或数据库的等效语句）对 `flyway_schema_history` 表进行加锁。该锁仅在migration事务期间有效，不会写入额外的行或列来存储锁状态。

锁在migration开始前获取，并在所有migration完成后释放。如果应用程序的两个实例同时启动（例如在扩展容器环境中），则只有一个实例会获得锁。另一个实例会等待锁释放或抛出错误，具体取决于配置。

您可以通过此设置配置重试次数：

~~~txt
spring.flyway.lock-retry-count=10
~~~

这样可以让你调整 Flyway 在放弃之前重试获取锁的次数。这在处理集群部署或可能延迟其他节点启动的长时间迁移时非常有用。

如果最后无法获取锁，Flyway 会快速失败。这可以防止部分状态迁移或重叠迁移。如果部署后应用程序无法启动，您应该始终检查日志。Flyway 会打印详细日志，说明哪个迁移失败、哪个迁移正在运行以及导致问题的 SQL 语句。



#### flyway的默认行为

使用 Spring Boot 集成 Flyway 时，无需编写任何 Java 代码。只要添加依赖, 并编写对应的migrations脚本，Flyway 就会处理一切。

以下是仅包含依赖项和几个迁移文件的默认行为：

~~~xml
<!-- pom.xml -->
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>
~~~

将脚本放在 `src/main/resources/db/migration` 目录中，并按如下方式命名：

~~~xml
V1__create_users.sql
V2__add_email_index.sql
~~~

仅此而已。Spring Boot 会检测到 Flyway，在上下文加载期间初始化它，找到migration脚本，并按版本顺序应用它们。每个脚本只会应用一次。Flyway 会将应用程序及其校验和、时间戳和执行时间记录在 `flyway_schema_history` 表中。如果您之后更改了已运行文件的内容，Flyway 会检测到校验和不匹配，并在启动时抛出错误。

这是设计使然。更改已应用的migration文件被视为危险操作，未经人工干预是不允许的。

您可以通过直接查询元数据表来查看已应用的迁移：

~~~sql
SELECT version, description, installed_on, success
FROM flyway_schema_history;
~~~

这可以提供完整的迁移历史记录，包括已运行的迁移、应用时间和迁移是否成功。这有助于调试和审核生产环境中的模式变更。



您还可以使用以下方法在某些环境中禁用自动迁移：

~~~properties
spring.flyway.enabled=false
~~~

这在测试期间或迁移由外部处理时非常有用。如果您需要更多控制权，仍然可以手动触发迁移，方法是创建一个 `Flyway` bean 并调用 `migrate()` 方法。



Flyway 的默认行为开箱即用，并且能够直接融入 Spring Boot 的启动生命周期。这种设计经过精心考量，确保数据库更改始终在代码执行任何其他操作之前运行，从而降低应用程序所依赖的表或列缺失或配置错误的风险。

#### 编写和管理安全可靠的Migrations脚本

