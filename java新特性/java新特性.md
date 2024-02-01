# Java9新特性

## Module模块系统

https://juejin.cn/post/6847902216590721031



#### 模块系统的作用

一个模块就是一个 jar 文件，但相比于传统的 jar 文件，模块的根目录下多了一个 `module-info.class` 文件，也即 `module descriptor`。 `module descriptor` 包含以下信息：

- 模块名称
- 依赖哪些模块
- 导出模块内的哪些包（允许直接 `import` 使用）
- 开放模块内的哪些包（允许通过 Java 反射访问）
- 提供哪些服务
- 依赖哪些服务



#### 模块系统的好处

第一，原生的依赖管理。有了模块系统，Java 可以根据 `module descriptor` 计算出各个模块间的依赖关系，一旦发现循环依赖，启动就会终止。同时，**由于模块系统不允许不同模块导出相同的包（即 `split package`，分裂包）**，所以在查找包时，Java 可以精准的定位到一个模块，从而获得更好的性能。

第二，精简  JRE。引入模块系统之后，JDK 自身被划分为 94 个模块（参见*图-2*）。通过 Java 9 新增的 `jlink` 工具，开发者可以根据实际应用场景随意组合这些模块，去除不需要的模块，生成自定义 JRE，从而有效缩小 JRE 大小。得益于此，JRE 11 的大小仅为 JRE 8 的 53%，从 218.4 MB缩减为 116.3 MB，JRE 中广为诟病的巨型 jar 文件 `rt.jar` 也被移除。更小的 JRE 意味着更少的内存占用，这让 Java 对嵌入式应用开发变得更友好。

第三，更好的兼容性。自打 Java 出生以来，就只有 4 种包可见性，这让 Java 对面向对象的三大特征之一封装的支持大打折扣，类库维护者对此叫苦不迭，只能一遍又一遍的通过各种文档或者奇怪的命名来强调这些或者那些类仅供内部使用，擅自使用后果自负云云。Java 9 之后，利用 `module descriptor` 中的 `exports` 关键词，模块维护者就精准控制哪些类可以对外开放使用，哪些类只能内部使用，换句话说就是不再依赖文档，而是由编译器来保证。类可见性的细化，除了带来更好的兼容性，也带来了更好的安全性。



![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2020/7/4/1731a259b0319241~tplv-t2oaga2asx-jj-mark:3024:0:0:0:q75.awebp)

#### module.info.java

上面提到，模块的核心在于 `module descriptor`，对应根目录下的 `module-info.class` 文件，而这个 class 文件是由源代码根目录下的 `module-info.java` 编译生成。Java 为 `module-info.java` 设计了专用的语法，包含 `module`、 `requires`、`exports` 等多个关键词

语法解读：

- `[open] module <module>`: 声明一个模块，模块名称应全局唯一，不可重复。加上 `open` 关键词表示模块内的所有包都允许通过 Java 反射访问，模块声明体内不再允许使用 `opens` 语句。
- `requires [transitive] <module>`: 声明模块依赖，一次只能声明一个依赖，如果依赖多个模块，需要多次声明。加上 `transitive` 关键词表示传递依赖，比如模块 A 依赖模块 B，模块 B 传递依赖模块 C，那么模块 A 就会自动依赖模块 C，类似于 Maven。
- `exports <package> [to <module1>[, <module2>...]]`: 导出模块内的包（**允许直接 `import` 使用和反射调用**），一次导出一个包，如果需要导出多个包，需要多次声明。如果需要定向导出，可以使用 `to` 关键词，后面加上模块列表（逗号分隔）。
- `opens <package> [to <module>[, <module2>...]]`: 开放模块内的包（**只运行反射调用, 不允许import**），一次开放一个包，如果需要开放多个包，需要多次声明。如果需要定向开放，可以使用 `to` 关键词，后面加上模块列表（逗号分隔）。
- `provides <interface | abstract class> with <class1>[, <class2> ...]`: 声明模块提供的 Java SPI 服务，一次可以声明多个服务实现类（逗号分隔）。
- `uses <interface | abstract class>`: 声明模块依赖的 Java SPI 服务，加上之后模块内的代码就可以通过 `ServiceLoader.load(Class)` 一次性加载所声明的 SPI 服务的所有实现类。

#### -p -m参数

Java 9 引入了一系列新的参数用于编译和运行模块，其中最重要的两个参数是 `-p` 和 `-m`。`-p` 参数指定模块路径，多个模块之间用 ":"（Mac, Linux）或者 ";"（Windows）分隔，同时适用于 `javac` 命令和 `java` 命令，用法和Java 8 中的 `-cp` 非常类似。`-m` 参数指定待运行的模块主函数，输入格式为`模块名/主函数所在的类名`，仅适用于 `java` 命令。两个参数的基本用法如下：

- `javac -p <module_path> <source>`
- `java -p <module_path> -m <module>/<main_class>`



#### demo示例

https://github.com/emac/jmods-demo

在本地文件的`./img/jmods-demo`下面也有备份



#### 老版本的处理

看到这里，相信创建和运行一个新的模块应用对你而言已经不是问题了，可问题是老的 Java 8 应用怎么办？别着急，我们先来了解两个高级概念，未命名模块（unnamed module）和自动模块（automatic module）。



![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2020/7/4/1731a26376e5a54e~tplv-t2oaga2asx-jj-mark:3024:0:0:0:q75.awebp)



一个未经模块化改造的 jar 文件是转为未命名模块还是自动模块，取决于这个 jar 文件出现的路径

如果是类路径，那么就会转为未命名模块，如果是模块路径，那么就会转为自动模块。

注意，自动模块也属于命名模块的范畴，其名称是模块系统基于 jar 文件名自动推导得出的，比如 com.foo.bar-1.0.0.jar 文件推导得出的自动模块名是 com.foo.bar。上图列举了未命名模块和自动模块行为上的区别，除此之外，两者还有一个关键区别，**分裂包规则适用于自动模块，但对未命名模块无效，也即多个未命名模块可以导出同一个包，但自动模块不允许。**

未命名模块和自动模块存在的意义在于，无论传入的 jar 文件是否一个合法的模块（包含 `module descriptor`），Java 内部都可以统一的以模块的方式进行处理，这也是 Java 9 兼容老版本应用的架构原理。运行老版本应用时，所有 jar 文件都出现在类路径下，也就是转为未命名模块，对于未命名模块而言，默认导出所有包并且依赖所有模块，因此应用可以正常运行。进一步的解读可以参阅[官方白皮书](https://link.juejin.cn?target=http%3A%2F%2Fopenjdk.java.net%2Fprojects%2Fjigsaw%2Fspec%2Fsotms%2F)的相关章节。

基于未命名模块和自动模块，相应的就产生了两种老版本应用的迁移策略，或者说模块化策略。



#### 如何使用未导出类

在jdk8中, `sun.security.util.SecurityConstants`这个类我们是可以随便使用的, 因为这是一个public类

但是在jdk11中, 我们无法再使用这个类, 因为jdk的jdk.base这个module并没有export他, 所以我们无法使用他

如果我们非要使用这个类, 可以使用如下命令

`--add-exports=a/b=c`, 指定a模块中的b包对c模块export



如果我们的项目中没有module-info.java(还是jdk8的结构)

可以在jvm中添加`--add-exports=java.base/sun.security.util=ALL-UNNAMED`来使用这个类, 这告诉jvm, `java.base`这个模块中的`sun.security.util`包对所有的未命名模块(因为我们的项目没有module-info.java, 所以是未命名模块)export

如果我们的项目中已经有了module-info.java, 

那么在jvm启动参数中添加``--add-exports=java.base/sun.security.util=our_module_name`, 这告诉jvm, `java.base`这个模块中的`sun.security.util`包对我们的包export

<img src="img/java新特性/image-20231229162419158.png" alt="image-20231229162419158" style="zoom: 25%;" />

如果我们的项目是maven, 那么还必须添加如下maven才能正确打包

~~~xml
<plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
                <configuration>
                    <source>11</source>
                    <target>11</target>
                    <compilerArgs>
                        <!-- 如果有多个--add-exports, 那么可以添加多个arg标签 -->
                        <arg>--add-exports=java.base/sun.security.pkcs=ALL-UNNAMED</arg>
                    </compilerArgs>
                </configuration>
            </plugin>
~~~



同理的还有`--add-opens=a/b=c`, 指定a模块的b包对c模块open





#### 如何改造老项目

> Bottom-up 自底向上策略

第一种策略，叫做自底向上（bottom-up）策略，即根据 jar 包依赖关系（如果依赖关系比较复杂，可以使用 `jdeps` 工具进行分析），沿着依赖树自底向上对 jar 包进行模块化改造（在 jar 包的源代码根目录下添加合法的模块描述文件 `module-info.java`）。初始时，所有 jar 包都是非模块化的，全部置于类路径下（转为未命名模块），应用以传统方式启动。然后，开始自底向上对 jar 包进行模块化改造，改造完的 jar 包就移到模块路径下，这期间应用仍以传统方式启动。最后，等所有 jar 包都完成模块化改造，应用改为 `-m` 方式启动，这也标志着应用已经迁移为真正的 Java 9 应用。以上面的示例工程为例，



![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2020/7/4/1731a2659433abba~tplv-t2oaga2asx-jj-mark:3024:0:0:0:q75.awebp)



*图-8: Bottom-up模块化策略*

1. 假设初始时，所有 jar 包都是非模块化的，此时应用运行命令为：

```
java -cp mod1.jar:mod2a.jar:mod2b.jar:mod3.jar:mod4.jar mod1.EventCenter
```

1. 对 mod3 和 mod4 进行模块化改造。完成之后，此时 mod1, mod2a, mod2b 还是普通的 jar 文件，新的运行命令为：

```
java -cp mod1.jar:mod2a.jar:mod2b.jar -p mod3.jar:mod4.jar --add-modules mod3,mod4 mod1.EventCenter
```

对比上一步的命令，首先 mod3.jar 和 mod4.jar 从类路径移到了模块路径，这个很好理解，因为这两个 jar 包已经改造成了真正的模块。其次，多了一个额外的参数 `--add-modules mod3,mod4`，这是为什么呢？这就要谈到模块系统的模块发现机制了。

不管是编译时，还是运行时，模块系统首先都要确定一个或者多个根模块（root module），然后从这些根模块开始根据模块依赖关系在模块路径中循环找出所有可观察到的模块（observable module），这些可观察到的模块加上类路径下的 jar 文件最终构成了编译时环境和运行时环境。那么根模块是如何确定的呢？对于运行时而言，如果应用是通过 `-m` 方式启动的，那么根模块就是 `-m` 指定的主模块；如果应用是通过传统方式启动的，那么根模块就是所有的 `java.*` 模块即 JRE（参见*图-2*）。回到前面的例子，如果不加 `--add-modules` 参数，那么运行时环境中除了 JRE 就只有 mod1.jar、mod2a.jar、mod2b.jar，没有 mod3、mod4 模块，就会报 `java.lang.ClassNotFoundException` 异常。如你所想，`--add-modules` 参数的作用就是手动指定额外的根模块，这样应用就可以正常运行了。

1. 接着完成 mod2a、mod2b 的模块化改造，此时运行命令为：

```
java -cp mod1.jar -p mod2a.jar:mod2b.jar:mod3.jar:mod4.jar --add-modules mod2a,mod2b,mod4 mod1.EventCenter
```

由于 mod2a、mod2b 都依赖 mod3，所以 mod3 就不用加到 `--add-modules` 参数里了。

1. 最后完成 mod1 的模块化改造，最终运行命令就简化为：

```
java -p mod1.jar:mod2a.jar:mod2b.jar:mod3.jar:mod4.jar -m mod1/mod1.EventCenter
```

注意此时应用是以 `-m` 方式启动，并且指定了 mod1 为主模块（也是根模块），因此所有其他模块根据依赖关系都会被识别为可观察到的模块并加入到运行时环境，应用可以正常运行。

>  Top-down 自上而下策略

自底向上策略很容易理解，实施路径也很清晰，但它有一个隐含的假设，即所有 jar 包都是可以模块化的，那如果其中有 jar 包无法进行模块化改造（比如 jar 包是一个第三方类库），怎么办？别慌，我们再来看第二种策略，叫做自上而下（top-down）策略。

它的基本思路是，根据 jar 包依赖关系，从主应用开始，沿着依赖树自上而下分析各个 jar 包模块化改造的可能性，将 jar 包分为两类，一类是可以改造的，一类是无法改造的。对于第一类，我们仍然采用自底向上策略进行改造，直至主应用完成改造，对于第二类，需要从一开始就放入模块路径，即转为自动模块。这里就要谈一下自动模块设计的精妙之处，首先，自动模块会导出所有包，这样就保证第一类 jar 包可以照常访问自动模块，其次，自动模块依赖所有命名模块，并且允许访问所有未命名模块的类（这一点很重要，因为除自动模块之外，其它命名模块是不允许访问未命名模块的类），这样就保证自动模块自身可以照常访问其他类。等到主应用完成模块化改造，应用的启动方式就可以改为 `-m` 方式。

还是以示例工程为例，假设 mod4 是一个第三方 jar 包，无法进行模块化改造，那么最终改造完之后，虽然应用运行命令和之前一样还是`java -p mod1.jar:mod2a.jar:mod2b.jar:mod3.jar:mod4.jar -m mod1/mod1.EventCenter`，但其中只有 mod1、mod2a、mod2b、mod3 是真正的模块，mod4 未做任何改造，借由模块系统转为自动模块。



![img](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2020/7/4/1731a2683f4fe432~tplv-t2oaga2asx-jj-mark:3024:0:0:0:q75.awebp)



*图-9: Top-down模块化策略*

看上去很完美，不过等一下，如果有多个自动模块，并且它们之间存在分裂包呢？前面提到，自动模块和其它命名模块一样，需要遵循分裂包规则。对于这种情况，如果模块化改造势在必行，要么忍痛割爱精简依赖只保留其中的一个自动模块，要么自己动手丰衣足食 Hack 一个版本。当然，你也可以试试找到这些自动模块的维护者们，让他们 PK 一下决定谁才是这个分裂包的主人。