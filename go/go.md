#### go依赖管理

1. 在go中, 如果a依赖b, 并且ab都依赖了c, 那么会选择c的高版本, 而不是maven中的路径优先规则
2. 如果想要排除a的1.1版本, 可以在go.mod中使用exclude标签, 哪怕当前还没有使用到a这个依赖(类似在maven的DependenciesManager添加exclude). 排除掉a的1.1版本之后将会go将会选择a的一个更高的版本, 如果没有更高版本将会报错



#### go.mod replace

1. 如果左边有版本号, 则只有指定的版本号会被替换, 其他版本正常解析. 如果左边没有版本号, 则所有的版本都被替换
2. 如果右边的是绝对路径或者相对路径(以./或者../开始), 那么认为是本地路径, 并且右边不能添加版本号
3. 如果右边是网络路径, 那么必须要有版本号

~~~~go.mod
replace (
    golang.org/x/net v1.2.3 => example.com/fork/net v1.4.5
    golang.org/x/net => example.com/fork/net v1.4.5
    golang.org/x/net v1.2.3 => ./fork/net
    golang.org/x/net => ./fork/net
)
~~~~







#### 为什么go.mod中有indirect

indirect表示的是go无法确定某个module的版本, 所以在生成go.mod的时候会在无法确定的module后面添加一个indirect, 有两种情况会导致这样

1. 依赖的module还没有启动go.mod

   如下图所示，Module A 依赖 B，但是 B 还未切换成 Module，也即没有`go.mod`文件，此时，当使用`go mod tidy`命令更新A的`go.mod`文件时，B的两个依赖B1和B2将会被添加到A的`go.mod`文件中（前提是A之前没有依赖B1和B2），并且B1 和B2还会被添加`// indirect`的注释。

   ![img](img/go/aHR0cHM6Ly9vc2NpbWcub3NjaGluYS5uZXQvb3NjbmV0L3VwLTExZTdhMTE4ZTA0YzNlZTRmZmNiMjU4YmQ3NDRhYjFhYjEzLnBuZw)

   此时Module A的`go.mod`文件中require部分将会变成：

   ```go
   require (
   	B vx.x.x
   	B1 vx.x.x // indirect
   	B2 vx.x.x // indirect
   )
   ```

2. 依赖的module的go.mod不完整

   即便B拥有`go.mod`，如果`go.mod`文件不完整的话，Module A依然会记录部分B的依赖到`go.mod`文件中。

   如下图所示，Module B虽然提供了`go.mod`文件中，但`go.mod`文件中只添加了依赖B1，那么此时A在引用B时，则会在A的`go.mod`文件中添加B2作为间接依赖，B1则不会出现在A的`go.mod`文件中。

   ![img](img/go/aHR0cHM6Ly9vc2NpbWcub3NjaGluYS5uZXQvb3NjbmV0L3VwLWYxODVlNGEwMWM2M2ZmY2U3MDc2N2VjZGYwNjU4MTkxMDBjLnBuZw)

   此时Module A的`go.mod`文件中require部分将会变成：

   ```go
   require (
   	B vx.x.x
   	B2 vx.x.x // indirect
   )
   ```

   由于B1已经包含进B的`go.mod`文件中，A的`go.mod`文件则不必再记录，只会记录缺失的B2。

可以用`go mod why github.com/xxx/yyy`来分析当前的依赖为何会被引入进来

#### 为什么go.mod有incompatible

incompatible表示不兼容的意思.

在go中, 一个 Module 的版本号需要遵循 `v<major>.<minor>.<patch>` 的格式，此外，如果 `major` 版本号大于 1 时，其版本号还需要体现在 Module 名字中。

比如 Module `github.com/RainbowMango/m`，如果git中的版本小于2.x.x, 其module名字应该表示为`github.com/RainbowMango/m`, 如果其版本号增长到 2.x.x 时，其 Module 名字也需要相应的改变为： `github.com/RainbowMango/m/v2`。即，如果 `major` 版本号大于 1 时，需要在 Module 名字中体现版本。

但是如果版本号增长到2.x.x时, 其module名字上没有添加版本信息, 即还是使用的`github.com/RainbowMango/m`, 那么在使用命令 `go mod tidy`，go 命令会自动查找 Module m 的最新版本，即 `v2.x.x`。 由于 Module 为不规范的 Module，为了加以区分，go 命令会在 `go.mod` 中增加 `+incompatible` 标识。

```
require (
	github.com/RainbowMango/m v3.6.0+incompatible
)
```

除了增加 `+incompatible`（不兼容）标识外，在其使用上没有区别。





#### go GOPROXY环境变量



#### go GOPRIVATE环境变量



#### go值类型与引用类型, 零值

值类型: 数字, string, bool, array, struct   

引用类型: 指针, slice, map, interface, func, chan   零值为nil







#### 什么时候可以进行==比较

#### 

#### 命名类型和未命名类型

日志框架 orm框架 json框架 分页





#### go中的error, panic与java中的运行时异常和非运行时异常比较

> java中的错误机制

在java中, RuntimeException是不必进行catch的, 造成这些错误一般都是程序的逻辑出现了问题而导致的, 那么对于这一类问题, 是鼓励不进行catch的, 可以在开发阶段尽早的暴露出来, 尽早的进行修复

RuntimeException的子类如下:

NullPropagation：空指针异常；
ClassCastException：类型强制转换异常
IllegalArgumentException：传递非法参数异常
IndexOutOfBoundsException：下标越界异常
NumberFormatException：数字格式异常

而对于其他的非RuntimeException而言, 是必须进行catch的, 因为这些错误代表着系统在操作中必定会产生的一些不合理的情况, 必须要catch掉提高代码的健壮性.

非RuntimeException的子类如下:

IOException: 读写错误

> go中的错误机制

在go中, 可以由函数返回error表示该函数异常, 也可以由函数调用panic表示该函数异常. 

类比java, 个人认为go中的error与java中的非RuntimeException类似, 即显式的要求在代码中对异常进行处理, go中的error返回值需要进行!=nil来比较并且进行处理, 而java则强制要求catch非运行时异常.

而go中的panic则与java中的RuntimeException类似, 造成这两者的都是一些代码逻辑上的漏洞, 可以进行catch也可以不进行catch, 没有强制性的要求

