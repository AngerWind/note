## 插件知识



### 生命周期

在maven中定义了三套生命周期, 分别是default, clean, site

生命周期中每个执行的步骤被称为phase

![image-20250425172513729](img/maven/image-20250425172513729.png)

### phase

phase就是maven中每个生命周期中要执行的步骤, 比如上面的compile, process-resources等等



### goal和mojo

goal是由插件提供的一个个的任务, 每个插件包中可以包含多个goal

在插件中每个goal都有具体的实现类, 这个实现类被称为mojo, 比如`compiler:compile` 这个 goal 由 `CompilerMojo` 类实现。



我们可以通过如下代码在maven中添加插件

~~~xml
<build>
  <plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-compiler-plugin</artifactId>
      <version>3.8.1</version>
      <executions>
        <execution>
          <phase>compile</phase>
          <goals>
            <goal>compile</goal>
          </goals>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
~~~

当maven执行到phase compile的时候, 就会自动执行goal compile了, 然后找到这个goal对应的mojo, 执行其中的代码





#### goal的手动触发

goal在绑定到特定的phase的时候, 会被指定自动执行

同时我们也可以手动来触发某个goal的执行

~~~shell
# 格式为: mvn group:artifact:goal
# 比如
mvn kr.motd.maven:show-goal-bindings:show
~~~

上面的代码就触发了`compiler`插件的compile这个goal

> 需要注意的时候, <font color=red>**手动执行 goal 时 Maven 不会自动处理依赖的前置 phase**</font>
>
> 比如有些goal是有依赖任务的, 比如执行`test`这个goal之前必须先编译好class文件
>
> 如果你没有编译好class文件, 那么手动执行`test`这个goal的话, 会失败的



**在执行maven的时候, 你不必处于项目的根目录下, 项目内的任何路径都可以, 他会递归父目录来查找pom.xml, 直到根目录**



#### goal的默认绑定

如果我们导入了一个插件, 但是不绑定任何的goal, 是不是这个插件就没有作用了呢?

~~~xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-compiler-plugin</artifactId>
  <version>3.8.1</version>
</plugin>
~~~

其实不是的, 每个 Maven 插件在发布时，都会包含一个 `plugin.xml`（类似插件的元数据描述文件），**这个文件告诉 Maven：哪些 goal 默认绑定在哪些 phase 上**。

~~~xml
<mojos>
  <mojo>
    <goal>compile</goal>
    <phase>compile</phase>  <!-- 就是默认绑定 -->
    ...
  </mojo>
  <mojo>
    <goal>testCompile</goal>
    <phase>test-compile</phase>
    ...
  </mojo>
</mojos>
~~~

只要你执行了某个生命周期（比如 compile），Maven 就会自动找到那些默认绑定在这个 phase 的 goal 并执行它们。



你可以通过如下命令来查看一个插件的所有goal, 以及他们是否默认绑定到phase上面

~~~shell
mvn help:describe -Dplugin=groupId:artifactId:version -Dfull
~~~

> 而对于没有默认绑定到特定的phase上的goal, 那么他就不会被执行, 除非你手动执行他, 或者手动将他绑定到特定的goal上



你也可以通过这个插件来查看, phase上都绑定了哪些goal

~~~xml
<build>
  <plugins>
    <plugin>
      <groupId>kr.motd.maven</groupId>
      <artifactId>maven-show-goal-bindings</artifactId>
      <version>1.4</version>
      <executions>
        <execution>
          <goals>
            <goal>show</goal>
          </goals>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
~~~

执行：

```bash
mvn kr.motd.maven:show-goal-bindings:show
```





### 默认的插件

Maven 自己并不直接“干活”，它只是个调度者，真正干活的是各个插件里的 goal。

如果你的maven项目中一个插件也没有添加, 那么maven会自动的给你添加上几个插件

![image-20250425180617553](img/maven/image-20250425180617553.png)

这些插件中的goal会默认绑定到特定的phase上, 来保证最基本的功能





你可以通过如下代码来查看真正的pom文件

~~~shell
mvn help:effective-pom
~~~

这个命令会输出 **Maven 实际使用的 POM**，包括：

- 你自己声明的插件
- 父 POM 继承的插件
- 隐式引入的核心插件

下面是一个空的maven项目打印出来的

~~~xml
<project
    xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>org.example</groupId>
    <artifactId>untitled</artifactId>
    <version>1.0-SNAPSHOT</version>
    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
    <repositories>
        <repository>
            <snapshots>
                <enabled>false</enabled>
            </snapshots>
            <id>central</id>
            <name>Central Repository</name>
            <url>https://repo.maven.apache.org/maven2</url>
        </repository>
    </repositories>
    <pluginRepositories>
        <pluginRepository>
            <snapshots>
                <enabled>false</enabled>
            </snapshots>
            <id>central</id>
            <name>Central Repository</name>
            <url>https://repo.maven.apache.org/maven2</url>
        </pluginRepository>
    </pluginRepositories>
    <build>
        <sourceDirectory>C:\Users\Administrator\Desktop\untitled\src\main\java</sourceDirectory>
        <scriptSourceDirectory>C:\Users\Administrator\Desktop\untitled\src\main\scripts</scriptSourceDirectory>
        <testSourceDirectory>C:\Users\Administrator\Desktop\untitled\src\test\java</testSourceDirectory>
        <outputDirectory>C:\Users\Administrator\Desktop\untitled\target\classes</outputDirectory>
        <testOutputDirectory>C:\Users\Administrator\Desktop\untitled\target\test-classes</testOutputDirectory>
        <resources>
            <resource>
                <directory>C:\Users\Administrator\Desktop\untitled\src\main\resources</directory>
            </resource>
        </resources>
        <testResources>
            <testResource>
                <directory>C:\Users\Administrator\Desktop\untitled\src\test\resources</directory>
            </testResource>
        </testResources>
        <directory>C:\Users\Administrator\Desktop\untitled\target</directory>
        <finalName>untitled-1.0-SNAPSHOT</finalName>
        <pluginManagement>
            <plugins>
                <plugin>
                    <artifactId>maven-antrun-plugin</artifactId>
                    <version>3.1.0</version>
                </plugin>
                <plugin>
                    <artifactId>maven-assembly-plugin</artifactId>
                    <version>3.7.1</version>
                </plugin>
                <plugin>
                    <artifactId>maven-dependency-plugin</artifactId>
                    <version>3.7.0</version>
                </plugin>
                <plugin>
                    <artifactId>maven-release-plugin</artifactId>
                    <version>3.0.1</version>
                </plugin>
            </plugins>
        </pluginManagement>
        <plugins>
            <plugin>
                <artifactId>maven-clean-plugin</artifactId>
                <version>3.2.0</version>
                <executions>
                    <execution>
                        <id>default-clean</id>
                        <phase>clean</phase>
                        <goals>
                            <goal>clean</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <artifactId>maven-resources-plugin</artifactId>
                <version>3.3.1</version>
                <executions>
                    <execution>
                        <id>default-testResources</id>
                        <phase>process-test-resources</phase>
                        <goals>
                            <goal>testResources</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>default-resources</id>
                        <phase>process-resources</phase>
                        <goals>
                            <goal>resources</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <artifactId>maven-jar-plugin</artifactId>
                <version>3.4.1</version>
                <executions>
                    <execution>
                        <id>default-jar</id>
                        <phase>package</phase>
                        <goals>
                            <goal>jar</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.13.0</version>
                <executions>
                    <execution>
                        <id>default-compile</id>
                        <phase>compile</phase>
                        <goals>
                            <goal>compile</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>default-testCompile</id>
                        <phase>test-compile</phase>
                        <goals>
                            <goal>testCompile</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.2.5</version>
                <executions>
                    <execution>
                        <id>default-test</id>
                        <phase>test</phase>
                        <goals>
                            <goal>test</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <artifactId>maven-install-plugin</artifactId>
                <version>3.1.2</version>
                <executions>
                    <execution>
                        <id>default-install</id>
                        <phase>install</phase>
                        <goals>
                            <goal>install</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <artifactId>maven-deploy-plugin</artifactId>
                <version>3.1.2</version>
                <executions>
                    <execution>
                        <id>default-deploy</id>
                        <phase>deploy</phase>
                        <goals>
                            <goal>deploy</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <artifactId>maven-site-plugin</artifactId>
                <version>3.12.1</version>
                <executions>
                    <execution>
                        <id>default-site</id>
                        <phase>site</phase>
                        <goals>
                            <goal>site</goal>
                        </goals>
                        <configuration>
                            <outputDirectory>C:\Users\Administrator\Desktop\untitled\target\site</outputDirectory>
                            <reportPlugins>
                                <reportPlugin>
                                    <groupId>org.apache.maven.plugins</groupId>
                                    <artifactId>maven-project-info-reports-plugin</artifactId>
                                </reportPlugin>
                            </reportPlugins>
                        </configuration>
                    </execution>
                    <execution>
                        <id>default-deploy</id>
                        <phase>site-deploy</phase>
                        <goals>
                            <goal>deploy</goal>
                        </goals>
                        <configuration>
                            <outputDirectory>C:\Users\Administrator\Desktop\untitled\target\site</outputDirectory>
                            <reportPlugins>
                                <reportPlugin>
                                    <groupId>org.apache.maven.plugins</groupId>
                                    <artifactId>maven-project-info-reports-plugin</artifactId>
                                </reportPlugin>
                            </reportPlugins>
                        </configuration>
                    </execution>
                </executions>
                <configuration>
                    <outputDirectory>C:\Users\Administrator\Desktop\untitled\target\site</outputDirectory>
                    <reportPlugins>
                        <reportPlugin>
                            <groupId>org.apache.maven.plugins</groupId>
                            <artifactId>maven-project-info-reports-plugin</artifactId>
                        </reportPlugin>
                    </reportPlugins>
                </configuration>
            </plugin>
        </plugins>
    </build>
    <reporting>
        <outputDirectory>C:\Users\Administrator\Desktop\untitled\target\site</outputDirectory>
    </reporting>
</project>
~~~









### 查看哪些goal绑定到了phase

maven中并没有提供直接的命令来查看各个phase到底绑定了哪些goal, 但是我们可以通过`mvn.cmd help:effective-pom`这个命令来生成执行时的pom文件

通过解析这个文件, 可以获取哪些goal绑定了哪些phase

下面是Java代码的时候, 他在执行的时候, 会打印所有的phase上面绑定的goal, 同时你也可以使用`--phase xxx`来指定要打印的phase上面绑定的goal

~~~java
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import org.w3c.dom.*;
import java.io.*;
import java.util.*;

public class MavenGoalBindings {
    public static void main(String[] args) throws Exception {
        String phaseFilter = null;
        for (int i = 0; i < args.length - 1; i++) {
            if ("--phase".equals(args[i])) {
                phaseFilter = args[i + 1];
            }
        }

        File effectivePom = File.createTempFile("effective-pom", ".xml");
        generateEffectivePom(effectivePom);

        Map<String, List<String>> bindings = parseEffectivePom(effectivePom);
        effectivePom.delete();

        if (phaseFilter != null) {
            List<String> goals = bindings.get(phaseFilter);
            if (goals != null) {
                System.out.println("🔹 " + phaseFilter);
                goals.forEach(goal -> System.out.println("   ↪ " + goal));
            } else {
                System.out.println("⚠️ No goals bound to phase: " + phaseFilter);
            }
        } else {
            bindings.keySet().stream().sorted().forEach(phase -> {
                System.out.println("\n🔹 " + phase);
                bindings.get(phase).forEach(goal -> System.out.println("   ↪ " + goal));
            });
        }
    }

    private static void generateEffectivePom(File outputFile) throws IOException, InterruptedException {
        ProcessBuilder pb = new ProcessBuilder(
                "mvn.cmd", "help:effective-pom", "-Doutput=" + outputFile.getAbsolutePath()
        );
        Map<String, String> env = pb.environment();
        env.put("PATH", System.getenv("PATH"));

        pb.inheritIO();
        Process process = pb.start();
        int exitCode = process.waitFor();
        if (exitCode != 0) {
            throw new RuntimeException("❌ Failed to generate effective POM");
        }
    }

    private static Map<String, List<String>> parseEffectivePom(File pomFile) throws Exception {
        Map<String, List<String>> phaseMap = new HashMap<>();

        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        dbf.setNamespaceAware(true); // Handle Maven's XML namespace
        DocumentBuilder db = dbf.newDocumentBuilder();
        Document doc = db.parse(pomFile);
        doc.getDocumentElement().normalize();

        NodeList plugins = doc.getElementsByTagNameNS("*", "plugin");

        for (int i = 0; i < plugins.getLength(); i++) {
            Element plugin = (Element) plugins.item(i);
            String groupId = getText(plugin, "groupId", "org.apache.maven.plugins");
            String artifactId = getText(plugin, "artifactId", null);

            if (artifactId == null) continue;

            NodeList executions = plugin.getElementsByTagNameNS("*", "execution");
            for (int j = 0; j < executions.getLength(); j++) {
                Element execution = (Element) executions.item(j);
                String phase = getText(execution, "phase", null);
                if (phase == null) continue;

                NodeList goals = execution.getElementsByTagNameNS("*", "goal");
                for (int k = 0; k < goals.getLength(); k++) {
                    String goal = goals.item(k).getTextContent().trim();
                    String full = groupId + ":" + artifactId + ":" + goal;
                    phaseMap.computeIfAbsent(phase, x -> new ArrayList<>()).add(full);
                }
            }
        }

        return phaseMap;
    }

    private static String getText(Element parent, String tag, String defaultValue) {
        NodeList list = parent.getElementsByTagNameNS("*", tag);
        if (list.getLength() > 0) {
            return list.item(0).getTextContent().trim();
        }
        return defaultValue;
    }
}
~~~



## plugin标签

~~~xml
      <plugin>
        <groupId>com.groupId</groupId>
        <artifactId>com.artifactId</artifactId>
        <version>1.0-SNAPSHOT</version>
        <!-- 表示该插件是一个 Maven 核心机制的扩展插件，它不只是普通地执行某些 goals，还可能：
             - 扩展 Maven 的构建生命周期（如添加新的生命周期、phase）；
             - 修改 Maven 的解析逻辑、项目构建机制
             - 动态注入功能，比如仓库解析、打包行为等
             - 需要在 Maven 的类加载器中生效（这点很关键）。
            Maven 会在构建开始前加载它，让它“驻留”在构建过程的类加载环境中。
            除非你很明确自己在干嘛, 否则不要使用这个选项
        -->
        <extensions>false</extensions>

        <!-- 表示当前这个插件是否要继承到子pom中, 如果是的话, 那么子项目也会有这个插件和所有的configuration, executions等等 -->
        <inherited>true</inherited>

        <!-- combine.children控制当前插件发送到子pom中的时候,是采用
                - merge(相同的key合并)(默认)
                - append(直接将子节点追加,不做合并)

             combine.self控制当前当前configuration节点怎么样继承父pom中的configuration
                - override: 用当前节点的configuration覆盖父pom中的configuration
                - merge: 用当前节点的configuration合并父pom中的configuration
              -->
        <!-- 这里的这个configuration作用于整个插件, 在所有的goal上面都可以读取 -->
        <configuration combine.children="append" combine.self="override">

        </configuration>

        <executions>
          <!-- 一个execution是goal的集合, 每个execution都可以有不同的configuration -->
          <execution>
            <!-- 想通id的execution在继承的时候会合并 -->
            <id>haha</id>

            <!-- 如果省略, 那么goal会绑定到默认的phase -->
            <phase>package</phase>

            <!-- 控制当前这个execution是否要继承到子pom中, 优先于外层的inherited -->
            <inherited>true</inherited>

            <!-- 这里的configuration作用于特定的goal, 并且较外层的有更高的优先级 -->
            <configuration combine.self="override" combine.children="append">

            </configuration>
            <goals>
              <goal>a</goal>
              <goal>b</goal>
            </goals>
          </execution>

          <execution>
            <!-- 这里还可以有另外一个execution, 他们可以有不同的configuration -->
          </execution>
        </executions>
        
        <!-- 需要传递给插件的classloader的额外依赖 -->
        <dependencies>

        </dependencies>
      </plugin>
~~~



## Plexus Container

Plexus Container其实是maven内部的一个ioc容器框架, 因为maven的第一个版本是在2002年发布的, 那个时候虽然有了ioc的思想, 但是还没有出现Spring这个框架

所以在maven早期的时候, 就实现了以及的一套ioc框架, 就是Plexus Container

Plexus类似其他的IOC框架，如Spring，但它还额外提供了很多特性，如：组件生命周期管理、组件实例化策略、嵌套容器、组件配置、自动注入、组件依赖、各种依赖注入方式（如构造器注入、setter注入、字段注入）。

Plexus下面主要有如下几个模块:

- Plexus Classworlds，类加载器框架，Maven至今还在用，个人感觉也挺不错，推荐学习学习；

- Plexus Container，IOC容器，Maven 1.x/2.x在用，3.0版本后，Maven自身也没有再使用了

- Plexus Components: 

- Maven的工作就是和各种文件、目录打交道，这期间，会沉淀出来很多公用组件:

  - IO相关的，`Plexus IO Components`，它的maven坐标：

  ```xml
  <dependency>
      <groupId>org.codehaus.plexus</groupId>
      <artifactId>plexus-io</artifactId>
      <version>3.2.0</version>
  </dependency>
  ```

  - 归档相关的，Plexus Archiver Component，maven坐标：

  ```xml
  <dependency>
      <groupId>org.codehaus.plexus</groupId>
      <artifactId>plexus-archiver</artifactId>
      <version>4.2.5</version>
  </dependency>
  ```

  - cli相关，Plexus CLI

  - 编译相关，Plexus Compiler

  - Digest/Hashcode相关，Plexus Digest / Hashcode Components

  - 国际化相关，i18n

  还有些其他的，我懒得列举了，大家自己看吧，https://web.archive.org/web/20150225072024/http://plexus.codehaus.org/plexus-components/

- Plexus Maven Plugin: 用来支持Maven插件

- Plexus Utils: 工具类，至今仍在用

### 现状

在maven2.0中, 与plexus相关的jar包只有少数几个了, 而在maven3.0中, 更是没有了plexus的声影

原因在于在maven3的时候, Spring已经开始成为事实上的IOC容器标准，不过，虽然Spring在应用开发领域，所向披靡，但是在各种框架中，框架开发者们还是觉得Spring太重了，一下就要引入好几个jar包，实在是过于臃肿。

因此，google 在2007年的时候，就推出了一个轻量级的依赖注入框架，叫google guice。经过多年的迭代，在2010年前后，guice已经比较成熟了，在google内部也而得到了广泛应用，且依赖注入这个领域，也在持续不断地发展中，比如java官方定义了相关的标准api。

经过多年的迭代，在2010年前后，guice已经比较成熟了，在google内部也而得到了广泛应用，且依赖注入这个领域，也在持续不断地发展中，比如java官方定义了相关的标准api。



## maven官方插件

### maven-invoker-plugin

这个插件的主要作用是, 当前项目执行的时候, 能够自动的调用别的项目构建并验证别的项目的输出

使用场景

1. 比如我有一个项目a, b,c, 项目bc依赖项目a, 我希望a在构建的时候, 自动帮我构建项目bc, 并验证是否构建成功
2. 我有一个插件a, 同时有两个测试项目bc, 我想插件a在构建的时候, 自动构建bc, 看看插件有没有达到预期



maven-invoker-plugin一共提供了六个goal:

1. `invoker:help`

   执行他可以打印invoker插件的帮助文档,  有哪些goal, 他们的作用

   还可以通过`-Ddetail=true`来打印详细的文档, 包括每个goal可以配置的参数

   还可以通过`-Dgoal=<goal-name>`来打印指定goal的帮助文档

2. `invoker:install`

   在调用项目之前, 将**当前项目和他的父项目打包的jar包和他的需要的所有依赖**install到本地仓库, 这样如果调用的项目依赖了当前项目, 就可以直接**最新**的版本

   默认绑定到`pre-integration-test`phase

   参数有

   | 参数名                                                       | 说明                                                         | 备注                                                         |
   | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
   | **extraArtifacts**                                           | 指定**额外**需要安装到本地仓库的依赖。 格式是： `groupId:artifactId:version:type:classifier`  **例子**： `org.apache.maven.plugins:maven-clean-plugin:2.4:maven-plugin` `org.apache.maven.plugins:maven-clean-plugin:2.4:jar:javadoc`  如果 `type` 是 `maven-plugin`，那么插件会用**plugin 仓库**而不是普通 artifact 仓库来解析。 | **注意**： 这里的依赖会被当做运行时（runtime scope）处理，且**会自动拉上它们的传递依赖（transitive dependencies）**。 |
   | **localRepositoryPath**  (默认值：`${session.localRepository.basedir}`) | 指定要安装这些 artifacts 的本地仓库路径。 如果不设，默认就是 Maven 的本地仓库（通常是 `~/.m2/repository`）。  **推荐**设成一个独立路径，比如： `${project.build.directory}/it-repo` 避免污染你平常用的本地仓库。 | **必填**参数（Required: Yes） 也可以通过命令行属性传：`-Dinvoker.localRepositoryPath=xxx` |
   | **scope**  (默认值：`runtime`)                               | 解析项目 artifact 时使用的依赖范围（scope）。 默认是 `runtime`，即运行时需要的依赖。 | 可以用 `-Dinvoker.install.scope=compile` 这样覆盖。          |
   | **skipInstallation**  (默认值：`false`)                      | 是否跳过 install 过程。 比如，有时候你只是想临时调试，想跳过 install，节省时间。 | 可以用命令行设置： `-Dinvoker.skip=true`                     |

3. `invoker:integration-test`

   搜索需要执行的项目, 并执行他们, 然后收集执行日志

   默认绑定到的生命周期: `integration-test`

   参数有如下几个:

   ```xml
   <plugin>
       <!--
           你只需要将使用到了插件的项目, 放到src/it目录下(这个目录是默认的, 可以配置)
        -->
       <groupId>org.apache.maven.plugins</groupId>
       <artifactId>maven-invoker-plugin</artifactId>
       <version>3.9.0</version>
   
       <configuration>
   
           <!-- 项目被调用前, 将他clone到指定的目录, 在clone后的项目中调用项目
                如果不设置的话, 就在项目的原始根目录下执行
                (如果运行 invoker 插件的是一个 maven-plugin 类型的项目,
                那么无论有没有设置 clone 目录，IT 项目都会默认被克隆到并在 target/its/ 目录下执行)
   
                最好还是设置一下
            -->
           <cloneProjectsTo>${project.build.directory}/it</cloneProjectsTo>
           <!-- 要克隆的项目, 默认情况下是所有的项目, 但是你可以手动制定 -->
           <collectedProjects>
               <collectedProject>../use-plugin</collectedProject>
           </collectedProjects>
           <!-- 在执行项目的时候, 需要调用的goals, 默认是package -->
           <goals>
               <goal>clean</goal>
               <goal>test-compile</goal>
           </goals>
           <!-- 可以在文件中定义调用项目时, 使用到的一些配置
                 文件中的配置优先级比这里高 -->
           <invokerPropertiesFile>src/it/invoker.properties</invokerPropertiesFile>
   
           <!-- 要执行的测试, 逗号分割, 不执行测试使用! -->
           <invokerTest>SimpleTest,Comp*Test,!Compare*</invokerTest>
           <!-- 定义一个本地存储库, 默认情况下会使用maven仓库,强烈建议指定一个独立存储库（例如 ${project.build.directory}/it-repo ）的路径。
                否则，系统将使用您的普通本地存储库，这可能会导致损坏的工件污染该存储库。  -->
           <localRepositoryPath>${project.build.directory}/it-repo</localRepositoryPath>
   
           <!-- 默认情况下, 项目的测试日志会被保存在项目根目录的build.log中,
                可以通过这个参数来指定保存到其他位置 -->
           <!-- <logDirect></logDirect> -->
   
   
           <!-- 需要调用和排除的项目的pom文件, 默认是${projectsDirectory}/*/pom.xml -->
           <pomIncludes>
               <pomInclude>*/pom.xml</pomInclude>
           </pomIncludes>
           <pomExcludes>
               <pomExclude>*/pom.xml</pomExclude>
           </pomExcludes>
           <!-- 搜索要调用项目的目录, 默认值${basedir}/src/it/ -->
           <projectsDirectory>${basedir}/src/it/</projectsDirectory>
   
   
           <!-- 执行构建后要运行的清理/验证钩子脚本的相对路径, 可以指定.bash和.groovy文件
                如果省略文件后缀, 默认使用.bash和.groovy来匹配
                比如verify等效于verify.bash和verify.groovy -->
           <postBuildHookScript>verify</postBuildHookScript>
           <!-- 同上, 在项目构建前要执行的脚本 -->
           <preBuildHookScript>clean</preBuildHookScript>
           <!-- 在构建项目的时候, 要指定的profile-->
           <profiles>
               <profile>dev</profile>
               <profile>web</profile>
           </profiles>
           <!-- 在构建项目的时候, 要通过-D传递的参数 -->
           <properties>
               <key1>value1</key1>
               <key2>value2</key2>
           </properties>
           <!-- 所有构建报告写入的基目录。每次执行集成测试都会生成一个 XML 文件，其中包含该构建作业成功或失败的信息
                默认值是${project.build.directory}/invoker-reports
                使用默认值就好 -->
           <reportsDirectory>${project.build.directory}/invoker-reports</reportsDirectory>
           <!-- 调用项目时, 指定使用的settigns.xml文件
                (文件中的<localRepository>会被忽略, 参数 localRepositoryPath 指定的路径将占主导地位) -->
           <settingsFile>src/it/settings.xml</settingsFile>
       </configuration>
       <executions>
           <execution>
               <id>integration-test</id>
               <goals>
                   <goal>install</goal>
                   <goal>integration-test</goal>
                   <goal>verify</goal>
               </goals>
           </execution>
       </executions>
   </plugin>
   ```

4. `invoker:verify`

   检查项目构建是否成功, 测试是否执行成功, postBuildHookScript脚本是否执行成功

   默认绑定到`verify`phase上

   这个goal的参数没什么好说的, 都是一些没用的参数

5. `invoker:run`

   运行这个goal就等效于运行了integration-test和verify两个goal

   并且integration-test和verify的参数, 在这里都可以配置

6. `invoker:report`

   将构建结果发布到站点中, 不知道有什么用

具体的使用可以查看`maven-plugin-test`这个项目



### maven-assembly-plugin

这个插件主要是用来将我们的项目打包为发行版本的, 比如我们从flink, dinky, dolphinscheduler这些网站下载的安装包

这个插件有两个goal: `help`和`single`

- `assembly:help`

  主要的作用是输出帮助信息

- `assembly:single`

  打包发行版本

  这个goal没有默认绑定的phase, 所以你如果要绑定到生命周期上的时候要指定phase, 如果不指定的话, 那么只能直接调用了

  详细的使用你可以查看文档, 或者本地的`assembly-test`项目

  

### maven-jar-plugin

这个插件主要是用来打jar包的, 其中只有一个help和jar两个goal

`jar:jar`默认绑定到`package`phase上面

尽管他有一些可以自定义的参数, 但是都是无关紧要的, 直接使用默认值就可以了

尽管jar这个goal可以打包可执行文件, 但是他并不会将所有的依赖一起打包进去, 你如果像打包可执行依赖, 还是使用maven-shade-plugin这个插件比较好



### maven-shade-plugin

这个插件主要用来打可执行jar包的, 并且他可以包含所有/部分的依赖

它里面只有`help`和`shade`两个goal

其中shade默认绑定到`package` phase

这个插件的使用场景是:

1. 我想将所有依赖都打包进来, 打包成一个可执行jar包

   ~~~xml
   <build>
     <plugins>
       <plugin>
         <groupId>org.apache.maven.plugins</groupId>
         <artifactId>maven-shade-plugin</artifactId>
         <version>3.6.0</version>
         <executions>
           <execution>
             <phase>package</phase> 
             <goals>
               <goal>shade</goal>   
             </goals>
             <configuration>
               <!-- 指定程序入口（Main-Class） -->
               <transformers>
                 <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                   <mainClass>com.example.Main</mainClass> <!-- 这里改成你的启动类 -->
                 </transformer>
               </transformers>
             </configuration>
           </execution>
         </executions>
       </plugin>
     </plugins>
   </build>
   ~~~

2. 我想将当前项目的多个模块, 打包为一个uber包, 这样别人只需要引用这一个包, 就相当于使用了所有包



具体的参数可以查看本地的`shade-plugin-test`项目



## 自定义插件

查看本地项目的`maven-plugin-test`