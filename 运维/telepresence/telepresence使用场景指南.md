# Telepresence 使用场景指南

- 官方参考：
  - [Code and debug an application locally](https://telepresence.io/docs/howtos/engage)
  - [Intercepts](https://telepresence.io/docs/concepts/intercepts)
  - [Using Telepresence with Docker](https://telepresence.io/docs/howtos/docker)
- 适用版本：Telepresence 2.28 文档语义
- 目标：帮助判断在不同开发、调试、联调场景下应该如何使用 Telepresence

## 1. Telepresence 解决什么问题

在 Kubernetes 微服务环境里，本地开发经常遇到这些问题：

- 本地服务依赖集群里的 Kafka、Redis、MySQL、其他微服务、内部 DNS。
- 每次改代码都要 build 镜像、push、部署，反馈链路太长。
- 服务只在集群网络里能访问，本机直接访问不到。
- 想用本地 IDE 断点调试，但真实请求和依赖都在集群里。
- 不想复制一整套复杂的本地环境。

Telepresence 的核心价值是：让本地进程进入集群网络，并在需要时让集群流量进入本地进程。

你可以把它理解成两层能力：

1. `telepresence connect`：让你的本机能访问集群内服务。
2. `replace` / `intercept` / `wiretap` / `ingest`：让你的本地进程和某个 Kubernetes workload 产生更深的关系。

## 2. 快速决策表

| 你的目标 | 推荐方式 | 原因 |
|---|---|---|
| 只是想本地访问集群内服务 | `telepresence connect` | 不改动 workload，最轻量 |
| 本地服务需要远端容器的环境变量、挂载卷，但不接收集群流量 | `ingest` | 拿环境，不碰流量 |
| 调试 HTTP API，只让自己的请求进本地 | `intercept` + header/path 过滤 | 远端服务继续运行，影响可控 |
| 想完整接管某个远端容器 | `replace` | 远端容器被本地进程替代 |
| 调试 Kafka/RabbitMQ consumer，必须停掉远端实例 | `replace` | 避免本地和远端同时消费消息 |
| 想观察真实流量，但不影响真实请求 | `wiretap` | 流量复制到本地，远端照常处理 |
| 多个开发者同时调同一个服务 | `intercept` 带个人 header，或 `wiretap` | 避免互相抢流量 |
| 本地应用必须跑在 Docker 容器里 | `connect --docker` 或 `--docker-run` | 把 Telepresence 网络也放进容器环境 |

## 3. 最基础场景：本机访问集群内部服务

### 场景

你本地运行一个服务，但它需要访问集群里的依赖，例如：

- `kafka.default.svc.cluster.local`
- `redis.cache.svc.cluster.local`
- `mysql.database.svc.cluster.local`
- 只暴露在 ClusterIP 内部的 HTTP 服务

你不需要让集群流量打到本地，只需要本地能访问集群。

### 推荐命令

```bash
telepresence connect
```

连接后可以验证：

```bash
curl -ik https://kubernetes.default
```

如果返回 `401` 或 `403`，通常说明 Kubernetes API server 已经可以从本机网络访问，连接是通的。

### 本地应用如何使用

本地应用可以直接使用集群里的服务名或内部域名。例如：

```properties
KAFKA_BOOTSTRAP_SERVERS=kafka.default.svc.cluster.local:9092
REDIS_HOST=redis.cache.svc.cluster.local
```

### 适合

- 本地启动 Spring Boot / Go / Node.js 服务，依赖仍然在 K8s 集群里。
- 本地跑脚本访问集群内数据库或内部 API。
- 不想部署本地依赖，也不想改集群 workload。

### 不适合

- 你需要让 Kubernetes Service 的请求转到本地。
- 你需要拿远端容器里的环境变量和挂载卷。

## 4. Ingest：只拿远端环境，不接管流量

### 场景

你的本地应用需要像远端容器一样运行，但你不希望影响远端服务。

例如：

- 想拿远端容器的环境变量。
- 想读取远端容器挂载的配置或证书。
- 想访问集群内部服务。
- 不需要任何请求从集群转发到本地。

### 推荐命令

```bash
telepresence connect

telepresence ingest example-app \
  --container echo-server \
  --env-file /tmp/example-app.env \
  --mount /tmp/example-app-mounts
```

然后本地启动应用时加载环境变量：

```bash
source /tmp/example-app.env
./start-local-app
```

如果是 Java 应用，也可以把 env 文件转换后交给启动脚本或 IDE 使用。

### 流量行为

- 不会拦截 Service 流量。
- 不会替换远端容器。
- 远端 Pod 和容器继续正常运行。
- 本地只是获得远端容器的环境上下文和集群网络能力。

### 适合

- 想最小化对集群的影响。
- 本地服务只是主动访问集群依赖。
- 调试不依赖外部请求入口的逻辑。
- 本地跑一次性任务或脚本，需要远端环境变量。

### 不适合

- 想调试真实进入 Service 的请求。
- 想让本地代码替代远端容器。
- 想停掉远端消费者避免重复消费。

## 5. Intercept：把命中的请求交给本地处理

### 场景

你正在调试一个 HTTP API，希望真实请求进入本地服务，但又不想影响所有请求。

例如：

- 前端或测试工具请求带上 `x-user=alice`，只有 Alice 的请求进本地。
- 只拦截 `/api/order` 这类路径，其他 API 继续走远端。
- 远端服务还要继续处理其他用户请求或后台任务。

### 推荐命令

```bash
telepresence connect

telepresence intercept example-app \
  --http-header 'x-user=alice' \
  --http-path-prefix '/api' \
  --port 8080:http \
  --env-file /tmp/example-app.env \
  --mount /tmp/example-app-mounts
```

本地服务监听：

```bash
localhost:8080
```

### 参数理解

- `example-app`：要拦截的 workload 或服务名称。
- `--port 8080:http`：本地 `8080` 接收远端名为 `http` 的服务端口流量。
- `--http-header 'x-user=alice'`：只拦截带指定 Header 的请求。
- `--http-path-prefix '/api'`：只拦截指定路径前缀。
- `--env-file`：把目标容器环境变量写到本地文件。
- `--mount`：把目标容器的挂载卷暴露到本地路径。

### 流量行为

命中条件的请求：

```text
调用方 -> Kubernetes Service -> Telepresence Traffic Agent -> 本地 localhost:8080
```

未命中条件的请求：

```text
调用方 -> Kubernetes Service -> 原远端容器
```

注意：被 `intercept` 命中的请求不会再进入远端容器，而是由本地服务处理。本地服务的响应会返回给调用方。

### 适合

- HTTP API 调试。
- 多人共享测试环境，但每个人通过不同 Header 拦截自己的请求。
- 本地断点调试某个请求链路。
- 想让远端服务继续处理未命中的流量。

### 不适合

- Kafka/RabbitMQ consumer 这类没有 HTTP 请求入口的后台消费者。
- 你不希望本地响应影响真实调用方。
- 本地服务不稳定，但流量又会命中拦截规则。

### 多人协作建议

建议每个开发者使用自己的 Header：

```bash
telepresence intercept order-service \
  --http-header 'x-dev-user=zhangsan' \
  --port 8080:http
```

测试请求时带上：

```bash
curl -H 'x-dev-user: zhangsan' http://order.example.com/api/orders
```

这样可以避免多个开发者互相抢流量。

## 6. Replace：本地完整替代远端容器

### 场景

你希望某个远端容器停止运行，由本地服务接管它的职责。

最典型的是消息队列消费者：

- Kafka consumer
- RabbitMQ consumer
- RocketMQ consumer
- 定时任务 worker
- 后台 job processor

这类服务如果远端和本地同时运行，可能会造成：

- 本地和远端同时消费消息。
- 调试时消息被远端抢走。
- 同一任务被重复处理。
- 数据写入结果不可控。

这时应该使用 `replace`，让远端业务容器被 Traffic Agent 替代，流量或运行职责转到本地。

### 推荐命令

```bash
telepresence connect

telepresence replace example-app \
  --container echo-server \
  --env-file /tmp/example-app.env \
  --mount /tmp/example-app-mounts
```

如果远端容器声明了端口，Telepresence 默认会把远端容器端口映射到本地相同端口。

也可以显式指定：

```bash
telepresence replace example-app \
  --container echo-server \
  --port 1080:8080 \
  --env-file /tmp/example-app.env \
  --mount /tmp/example-app-mounts
```

含义是：远端容器的 `8080` 端口由本地 `1080` 接收。

### 流量行为

```text
原远端容器被移除
Traffic Agent 进入 Pod
原本发往远端容器的流量 -> 本地服务
```

### 适合

- 消息队列消费者调试。
- 定时任务或后台任务调试。
- 必须停止远端容器，避免它继续处理任务。
- 需要本地服务完整接管某个容器。
- 远端容器没有标准入站流量，不适合 `intercept`。

### 不适合

- 共享环境里有其他人依赖该容器稳定运行。
- 你只想拦截一部分 HTTP 请求。
- 你只是想读取远端环境变量。

### 退出 replace

```bash
telepresence leave example-app --container echo-server
```

退出后，被替换的容器会恢复。

## 7. Wiretap：复制请求到本地，不影响真实流量

### 场景

你想让本地服务收到真实请求，但不希望本地服务影响真实请求结果。

例如：

- 想观察线上/测试环境真实请求内容。
- 想让本地新逻辑“旁路跑一遍”，但不参与响应。
- 想打断点，但不希望调用方等待本地断点。
- 多个开发者想同时观察同一个服务的流量。

### 推荐命令

```bash
telepresence connect

telepresence wiretap example-app \
  --port 8080:http \
  --env-file /tmp/example-app.env \
  --mount /tmp/example-app-mounts
```

### 流量行为

真实请求仍然到远端服务：

```text
调用方 -> Kubernetes Service -> 原远端容器 -> 调用方收到远端响应
```

同时 Telepresence 把请求送一份到本地：

```text
Traffic Agent -> 本地 localhost:8080
```

本地服务的响应不会影响调用方。

### 适合

- 只读观察真实流量。
- 验证新逻辑是否能处理真实请求。
- 不希望本地断点影响远端服务。
- 希望对集群影响尽可能小。

### 不适合

- 你需要让调用方收到本地服务的响应。
- 你需要阻止远端服务处理请求。
- 你要调试消息队列消费逻辑。

## 8. Docker 场景：本地应用跑在容器里

### 场景

你的本地服务不是直接跑在宿主机，而是跑在 Docker 容器中。

例如：

- 本地开发环境通过 Dockerfile 固化。
- 依赖 Linux 容器环境。
- IDE 使用 Remote Debug 连接容器。
- 不想让 Telepresence 修改宿主机网络。

### 方式一：Telepresence daemon 跑在 Docker 中

```bash
telepresence connect --docker
```

这会让 Telepresence 的网络能力限制在容器环境中。

访问集群服务时使用：

```bash
telepresence curl -ik https://kubernetes.default
```

### 方式二：engage 时直接运行本地容器

例如使用 `replace`：

```bash
telepresence replace example-app \
  --container echo-server \
  --docker-run -- <your-local-container-image>
```

也可以根据场景配合 `intercept` 或 `wiretap` 使用 `--docker-run`。

### 适合

- 本地服务必须在容器中运行。
- 希望容器内路径和远端挂载路径更一致。
- 不方便在宿主机安装完整运行时。

### 注意

- Docker 方式对 IDE、断点、文件热更新可能更复杂。
- 如果代码修改后容器需要重新构建，反馈速度会变慢。
- 网络排查时要区分宿主机网络和 Telepresence 容器网络。

## 9. Kafka / 消息队列消费者应该怎么用

### 推荐：优先使用 replace

消息队列消费者和 HTTP 服务不一样。HTTP 请求通常可以按 Header 或 Path 拦截，但 Kafka/RabbitMQ 消费是服务主动从 broker 拉取或订阅消息。

如果远端 consumer 继续运行，本地 consumer 很可能拿不到你想调试的消息。

所以这类场景建议：

```bash
telepresence connect

telepresence replace kafka-consumer \
  --container app \
  --env-file /tmp/kafka-consumer.env \
  --mount /tmp/kafka-consumer-mounts
```

然后本地启动 consumer：

```bash
source /tmp/kafka-consumer.env
./start-consumer
```

### 注意

- 确认本地 consumer 使用的 group id 是否符合预期。
- 如果只是测试，不要误消费共享环境的重要消息。
- 如有必要，使用专门的 topic、group 或 namespace。
- 调试完成后及时执行 `telepresence leave`。

## 10. HTTP API 联调应该怎么用

### 推荐：intercept + Header 过滤

共享测试环境里，最稳的方式是要求调用方带一个专属 Header。

```bash
telepresence intercept order-service \
  --http-header 'x-dev-user=alice' \
  --port 8080:http \
  --env-file /tmp/order-service.env \
  --mount /tmp/order-service-mounts
```

调用方请求：

```bash
curl -H 'x-dev-user: alice' http://order.example.com/api/orders
```

### 为什么不直接拦截全部流量

直接拦截全部流量会导致所有访问该服务的请求都进入你的本地服务。只要你本地服务打断点、重启或异常，其他人的请求也会受影响。

### 推荐实践

- 每个开发者使用唯一 Header。
- 调试路径尽量加 `--http-path-prefix` 缩小范围。
- 本地服务启动成功后再创建 intercept。
- 调试完成后执行 `telepresence leave`。

## 11. 只观察真实流量应该怎么用

### 推荐：wiretap

如果你只是想看真实请求长什么样，或者让本地新版本旁路跑一遍，不要用 `intercept`，优先用 `wiretap`。

```bash
telepresence wiretap payment-service \
  --port 8080:http \
  --env-file /tmp/payment-service.env
```

### 适合验证

- 请求体结构是否符合预期。
- Header、Cookie、Trace ID 是否完整。
- 本地新逻辑是否能处理真实流量。
- 新版本是否会报错，但不影响远端真实响应。

### 注意

- 本地服务的响应不会返回给调用方。
- 如果你要验证“调用方实际收到什么”，应该用 `intercept`。

## 12. 常用操作流程模板

### 通用前置检查

```bash
kubectl config current-context
kubectl get ns
telepresence connect
telepresence list
```

确认目标 workload 是否可 engage：

```bash
telepresence list
```

查看容器名：

```bash
kubectl describe deploy example-app
```

### 本地启动应用

如果用了 `--env-file`：

```bash
source /tmp/example-app.env
```

然后启动你的应用：

```bash
./start-local-app
```

### 查看状态

```bash
telepresence status
telepresence list
```

### 退出

```bash
telepresence leave example-app
```

如果指定了容器：

```bash
telepresence leave example-app --container echo-server
```

完全退出 Telepresence：

```bash
telepresence quit
```

## 13. 选择建议总结

从低影响到高影响，大致顺序是：

```text
connect < ingest < wiretap < intercept < replace
```

建议优先选择影响更小的方式：

- 能用 `connect` 解决，就不要 engage workload。
- 只需要环境变量和集群网络，用 `ingest`。
- 只观察流量，用 `wiretap`。
- 需要本地处理请求，用 `intercept`。
- 必须停掉远端容器或完整接管，用 `replace`。

## 14. 风险和注意事项

### 不要在不确定的共享环境里直接 replace

`replace` 会让目标容器被 Traffic Agent 替代。别人依赖这个服务时，可能会受到影响。

### intercept 尽量加过滤条件

推荐使用：

```bash
--http-header 'x-dev-user=your-name'
--http-path-prefix '/your-api'
```

不要轻易拦截整个服务的全部流量。

### 调试完成后及时清理

```bash
telepresence leave <name>
telepresence quit
```

### 注意本地端口冲突

如果远端端口是 `8080`，但本地 `8080` 已被占用，可以使用：

```bash
--port 18080:8080
```

### 注意 namespace

如果目标服务不在当前 namespace，使用：

```bash
telepresence intercept example-app \
  --namespace test \
  --port 8080:http
```

或者先切换 kubectl context / namespace。

## 15. 我的推荐用法

日常开发里可以按下面顺序思考：

1. 我只是要访问集群依赖吗？
   - 是：用 `telepresence connect`。

2. 我需要远端容器的环境变量和挂载卷吗？
   - 是，但不需要流量：用 `ingest`。

3. 我要调试 HTTP 请求吗？
   - 是，并且要让调用方收到本地响应：用 `intercept`。
   - 是，但只想旁路观察：用 `wiretap`。

4. 我要调试 consumer、worker、定时任务吗？
   - 是：优先用 `replace`，避免远端继续处理任务。

5. 我在共享环境里操作吗？
   - 是：优先 `wiretap` 或带 Header 的 `intercept`，慎用 `replace`。

简化记忆：

```text
connect   = 本机进集群网络
ingest    = 本机拿远端环境，不接流量
wiretap   = 复制流量到本地，不影响远端
intercept = 命中流量交给本地处理
replace   = 本地替代远端容器
```
