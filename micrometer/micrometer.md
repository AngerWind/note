## Micrometer概述

Micromter是最流行的可观察系统的检测客户端, 他类似于SLF4J, 是具体监控系统无关的

他提供了一套数据指标的监控API, 然后各个监控系统去实现这些API, 并从中获取数据, 推送到自己的系统中, 

所以可以对接各种监控系统, 比如Prometheus





## 依赖

Micrometer提供了一个核心库, 这个库中包含了各种指标定义的接口, 以及**这些接口的内存实现**,  各种监控系统的厂家可以通过这个核心库的SPI机制, 实现自己系统的实现,  然后获取对应的指标, 推送到自己的系统中

gradle的依赖如下

~~~groovy
// bom文件, 用于依赖的版本控制
implementation platform('io.micrometer:micrometer-bom:1.15.5')

// micrometer的核心依赖库, 自带一个内存实现
implementation 'io.micrometer:micrometer-core'

// 添加Prometheus的micrometer的实现, 会自动依赖core模块
implementation 'io.micrometer:micrometer-registry-prometheus'
~~~



maven的依赖如下

~~~xml
<!-- bom文件, 用于版本控制 -->
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-bom</artifactId>
            <version>1.15.5</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>

<!-- 导入core模块, 他会自带一个内存实现 -->
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-core</artifactId>
</dependency>


<!-- 添加Prometheus的micrometer的实现, 会自动依赖core模块  -->
<dependency>
  <groupId>io.micrometer</groupId>
  <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
~~~



## 核心概念

在Micrometer中, 有7个核心的接口概念



### Meter

这个接口用来表示一种具体的指标, 他有如下的几个属性

| 属性                       | 作用                                                         | 举例                                         |
| -------------------------- | ------------------------------------------------------------ | -------------------------------------------- |
| **name（名称）**           | 指标的唯一标识，定义它“测量什么”<br>通过`.`进行层次性的命名  | `"http.server.requests"`                     |
| **tags（标签）**           | 给指标增加维度信息，用于区分这个指标的不同维度               | `status=200`, `method=GET`                   |
| **description（描述）**    | 对指标的文字说明，帮助理解                                   | `"Total HTTP requests received"`             |
| **baseUnit（基础单位）**   | 说明测量的物理单位（如秒、字节）                             | `"seconds"`, `"bytes"`                       |
| **measurements（测量值）** | 该指标采集的一组实际数值                                     | Counter 的 count、Timer 的 totalTime、max 等 |
| **type（类型）**           | Meter 的具体类型（如 Counter、Gauge、Timer 等）              | `Meter.Type.COUNTER`                         |
| **id（Meter.Id）**         | 上面信息的综合封装对象（name + tags + baseUnit + description） | 用于唯一标识该 Meter                         |

比如你有一个接口`/gender`, 他接受一个参数, 男/女, 你想要统计这个接口接受到的男和女参数的次数, 以及返回状态码为200和500的的请求次数, 那么你可以这样定义

- 定义一个name为`http.server.gender.request`, tag为`args=nan, status=200`的指标
- 定义一个name为`http.server.gender.request`, tag为`args=nv, status=200`的指标
- 定义一个name为`http.server.gender.request`, tag为`args=nan, status=500`的指标
- 定义一个name为`http.server.gender.request`, tag为`args=nv, status=500`的指标

上面我们对一个接口定义了4个指标, 如果来了一个请求, 那么就将对应的指标进行增加一次,  这些数据会保存在MeterRegisty中, 然后定期推送到具体的监控系统中, 比如Prometheus中, 然后在Prometheus中进行聚合



### MicroRegistry

度量注册中心，用来创建和管理注册各种 Meter；负责把指标导出到监控系统。

每一个系统都可以已实现自己的MicroRegistry, 用来将Meter数据推送到自己的系统

如下是一些常见的MeterRegistry

| 实现类                      | 说明                                                 |
| --------------------------- | ---------------------------------------------------- |
| **SimpleMeterRegistry**     | 简单实现，存内存，不导出；常用于测试。在core中自带的 |
| **PrometheusMeterRegistry** | 导出到 Prometheus（最常见）。                        |
| **GraphiteMeterRegistry**   | 导出到 Graphite。                                    |
| **DatadogMeterRegistry**    | 导出到 Datadog。                                     |
| **CompositeMeterRegistry**  | 组合多个 Registry，一次注册，多处导出。              |





### MeterFilter







## Meter的类型

在micrometer中, 定义了多种不同类型的meter

| 类型                | 说明                                       | 常见用途                      | 关键方法                                 |
| ------------------- | ------------------------------------------ | ----------------------------- | ---------------------------------------- |
| **Counter**         | 单调递增的计数器                           | 统计请求数、错误次数等        | `counter.increment()`                    |
| **Gauge**           | 采样当前值，可增可减                       | 内存使用量、队列长度、连接数  | `gauge.set(value)` 或通过函数绑定        |
| **Timer**           | 测量时间分布（次数 + 总时长）              | 接口响应时间、任务耗时        | `timer.record(Runnable/Callable)`        |
| **Summary**         | 统计一系列数值的分布（次数 + 总和 + 平均） | 数据包大小、请求体长度        | `summary.record(size)`                   |
| **LongTaskTimer**   | 记录执行时间较长的任务（可并行）           | 文件上传、批量任务等          | `sample = timer.start(); sample.stop();` |
| **FunctionCounter** | 从函数读取递增值（非直接计数）             | 统计某个对象的累积属性        | 定期从函数计算                           |
| **FunctionGauge**   | 从函数读取瞬时值（非直接设置）             | 比如缓存命中率、线程池大小    | `FunctionGauge.builder(...).register()`  |
| **TimeGauge**       | Gauge 的时间版本，值带时间单位             | 用于记录某个时间值（秒/毫秒） | `TimeGauge.builder(...).register()`      |

### Counter

- 永远递增，不可重置（除非重启或指标过期）
- 内部是累加器
- Prometheus 展示时是 `_total` 后缀
- **适合统计事件次数**

```java
Counter requests = Counter.builder("http.requests")
    .description("请求次数")
    .register(registry);

requests.increment();
```

### Gauge

- 表示一个**瞬时状态值**，可升可降
- 不保存历史趋势，只保存当前值
- 通常用来观测某个实时变量

```java
AtomicInteger queueSize = new AtomicInteger(0);
Gauge.builder("queue.size", queueSize, AtomicInteger::get)
    .description("当前队列长度")
    .register(registry);
```

### Timer

- 统计**事件持续时间**
- Micrometer 自动记录：
  - 总次数
  - 总时长
  - 平均值
  - 最大值（可配置）
- Prometheus 中会生成多个 `_count`、`_sum` 等指标

```java
Timer timer = Timer.builder("api.latency")
    .description("接口延迟")
    .register(registry);

timer.record(() -> {
    // 被监控的业务逻辑
    doSomething();
});
```



### DistributionSummary

- 类似 `Timer`，但不是时间，而是任意数值的分布
- 可用于统计文件大小、消息体长度等

~~~java
DistributionSummary summary = DistributionSummary.builder("payload.size")
    .description("消息体大小")
    .register(registry);

summary.record(512);
summary.record(2048);
~~~

### LongTaskTimer

- 适合持续时间较长、并发的任务
- 与普通 Timer 的区别是它**可同时跟踪多个正在执行的任务**

```java
LongTaskTimer longTaskTimer = LongTaskTimer.builder("job.duration")
    .register(registry);

LongTaskTimer.Sample sample = longTaskTimer.start();
try {
    // 长任务
    doHeavyJob();
} finally {
    sample.stop();
}
```

### FunctionCounter / FunctionGauge

- 不自己保存值，而是**从函数或对象中动态读取**
- 比如：读取缓存命中数、线程池队列长度

```java
FunctionCounter.builder("cache.hits", cache, Cache::getHitCount)
    .register(registry);

FunctionGauge.builder("threadpool.active", executor, ThreadPoolExecutor::getActiveCount)
    .register(registry);
```

### TimeGauge

- `Gauge` 的时间单位版
- 用于度量“持续时间”类指标，比如 JVM uptime

```java
TimeGauge.builder(
    "jvm.uptime", 
    managementBean, 
    TimeUnit.MILLISECONDS, 
    RuntimeMXBean::getUptime
).register(registry);
```





todo CompositeMeterRegistry, **Binder**, **Step / Histogram / SLA**, Exporter