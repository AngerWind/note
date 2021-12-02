#### Gradle中使用Groovy中的语法糖

> 属性调用

Groovy中的属性和方法没有访问修饰符的话， 默认为public。并且还会为public的属性自动生成getter/setter。对属性的调用将转为对getter/setter的调用

~~~groovy
// build.gradle

// Using a getter method
println project.buildDir
println getProject().getBuildDir()

// Using a setter method
project.buildDir = 'target'
getProject().setBuildDir('target')
~~~

> 括号省略

在不产生歧义的情况下， 方法调用可以省略括号

~~~groovy
test.systemProperty 'some.prop', 'value'
test.systemProperty('some.prop', 'value')
~~~

> map语法糖

~~~groovy
// 定义map，默认类型java.util.LinkedHashMap
def langs = ['C++':'Stroustrup', 'Java':'Gosling', 'Lisp':'McCarthy']

// 如果map中的key是普通字符串， 还可以省略引号
def langs = ['C++':'Stroustrup', Java:'Gosling', Lisp:'McCarthy']

// map作为参数可以省略方括号
apply([plugin: 'java'])
apply plugin:'java'
~~~

> 闭包作为方法的最后一个参数时，可以放在小括号后面

~~~groovy
tasks.register("a",{
    // do something
})

tasks.register('a') {
    // do something
}
~~~

> 闭包delegate对象

https://www.jianshu.com/p/ae10f75b37cf

https://blog.csdn.net/yeziwang9/article/details/83770703

为了明白**delegate**的概念，我们必须首先解释清楚在闭包中关键字**this**的意义。一个闭包通常定义了一下三个量：

- **this** 指的是离闭包定义最近的类的对象。如果实在内部类中定义的那就是内部类对象。

- **owner** 指的是闭包定义所在的外层包裹对象，这个对象可能是类也可能是另一个闭包。【这是因为闭包是可以嵌套定义的。】

- **delegate** 默认与owner相同， 当区别在于delegate是可以设置的。其意义在于当在闭包中调用的方法或变量在当前闭包中没有定义时，就会去委托对象上寻找。在gradle中，会将delegate对象设置为当前闭包要配置的对象。

  下面调用dependencies方法传入了一个闭包，但是在该闭包中没有testImplementation方法，所以会转而去delegate对象上寻找。而该delegate对象被配置为project.dependencies对象。

~~~groovy
dependencies {
    assert delegate == project.dependencies
    testImplementation('junit:junit:4.13')
    delegate.testImplementation('junit:junit:4.13')
}
~~~

> 默认导入

在build.gradle中默认导入了import org.gradle.*



#### 官方文档翻译 Working With Files



几乎每个Gradle build都与文件打交道， 所以Gradle附带一个全面的api，他主要有两部分

- 指定要处理的文件和目录
- 指定如何处理他们

第一部分在[在深度文件路径](https://docs.gradle.org/current/userguide/working_with_files.html#sec:locating_files)详细讲解，第二部分在[文件在深度复制](https://docs.gradle.org/current/userguide/working_with_files.html#sec:copying_files)讲解，现在先看常见的示例

> 复制单个文件

此示例将生成的报告复制到打包路径中

~~~groovy
tasks.register('copyReport', Copy) {
    from layout.buildDirectory.dir("reports/my-report.pdf")
    into layout.buildDirectory.dir("toArchive")
}
// 两者相同
tasks.register('copyReport2', Copy) {
    from "$buildDir/reports/my-report.pdf"
    into "$buildDir/toArchive"
}
~~~

> 复制多个文件

~~~groovy
tasks.register('copyReportsForArchiving', Copy) {
    from layout.buildDirectory.file("reports/my-report.pdf"), layout.projectDirectory.file("src/docs/manual.pdf")
    into layout.buildDirectory.dir("toArchive")
}
~~~

> 使用过滤器

~~~groovy
tasks.register('copyPdfReportsForArchiving', Copy) {
    from layout.buildDirectory.dir("reports")
    include "*.pdf" // 复制reports中的所有pdf文件到toArchive中，不包括子目录中的pdf
    // include "**/*.pdf" // 复制reports中的所有pdf文件到toArchive中，包括子目录的pdf,连带目录结构
    // fileTree(dir){include "**/*.pdf"} // 复制reports中的所有pdf文件到toArchive中，包括子目录的pdf,不带目录结构
    into layout.buildDirectory.dir("toArchive")
}
~~~

> 复制目录

```groovy
// 复制reports中所有文件包括子目录到toArchive, 不包括reports
tasks.register('copyReportsDirForArchiving', Copy) {
    from layout.buildDirectory.dir("reports")
    into layout.buildDirectory.dir("toArchive")
}
// 复制reports中所有文件包括子目录到toArchive, 包括reports,所以会在toArchive下生成一个reports文件夹
tasks.register('copyReportsDirForArchiving2', Copy) {
    from(layout.buildDirectory) {
        include "reports/**"
        // 需要注意的是这里的include只负责这一个from
        // 而上面的include是作用在整个任务上的
        // 意思上面的include是作用在所有from上面的？
    }
    into layout.buildDirectory.dir("toArchive")
}
```

> 创建tar，zip等

~~~~groovy
tasks.register('packageDistribution', Zip) {
    archiveFileName = "my-distribution.zip" // 指定压缩包名字
    destinationDirectory = layout.buildDirectory.dir('dist') // 指定压缩包保存的路径

    from layout.buildDirectory.dir("toArchive") // 指定打包路径
}
~~~~

每种类型的存档都有自己的任务类型，最常见的是[Zip](https://docs.gradle.org/current/dsl/org.gradle.api.tasks.bundling.Zip.html)、[Tar](https://docs.gradle.org/current/dsl/org.gradle.api.tasks.bundling.Tar.html)和[Jar](https://docs.gradle.org/current/dsl/org.gradle.api.tasks.bundling.Jar.html)

压缩包名字和压缩包路径都是必须的，但是通常不会显示设置，而是使用[Base Plugin](https://docs.gradle.org/current/userguide/base_plugin.html#base_plugin)。它为这些属性提供了一些常规值。下一个示例演示了这一点，您可以在[存档命名](https://docs.gradle.org/current/userguide/working_with_files.html#sec:archive_naming)部分中了解有关约定的更多信息。

假设要打包所有pdf到压缩包中的docs路径中， 但是打包路径中并没有docs路径， 所以必须在压缩包路径中创建docs路径，通过添加into()声明来做到这一点

~~~groovy
plugins {
    id 'base'
}

version = "1.0.0"

tasks.register('packageDistribution', Zip) {
    from(layout.buildDirectory.dir("toArchive")) {
        exclude "**/*.pdf"
    }

    from(layout.buildDirectory.dir("toArchive")) {
        include "**/*.pdf"
        into "docs"
    }
}
~~~

如你所见，可以声明多个from()，并且每一个都可以有单独的配置。有关此功能的更多信息，请参阅 [Using child copy specifications](https://docs.gradle.org/current/userguide/working_with_files.html#sub:using_child_copy_specifications)

todo 未翻译完全，后面估计就是一些解压，重命名，创建，删除文件之类的。



## 官方文档翻译-使用Gradle插件

Gradle 的核心是有意为的自动化提供很少的内容。所有有用的特性，比如编译 Java 代码的能力，都是由*插件*添加的。插件添加新任务（例如[JavaCompile](https://docs.gradle.org/current/dsl/org.gradle.api.tasks.compile.JavaCompile.html)）、domain objects（例如[SourceSet](https://docs.gradle.org/current/dsl/org.gradle.api.tasks.SourceSet.html)）、convention约定（例如 Java 源代码位于`src/main/java`），扩展核心对象和来自其他插件的对象。

使用插件可以做一下事情：

- Extend the Gradle model (e.g. add new DSL elements that can be configured)

  扩展 Gradle 模型（例如添加可配置的新 DSL 元素）

- Configure the project according to conventions (e.g. add new tasks or configure sensible defaults)

  根据约定配置项目（例如添加新任务或配置合理的默认值）

- Apply specific configuration (e.g. add organizational repositories or enforce standards)

  应用特定配置（例如添加组织存储库或执行标准）

使用插件而不是向项目build script中添加逻辑的好处：

- Promotes reuse and reduces the overhead of maintaining similar logic across multiple projects

  促进重用并减少在多个项目中维护相似逻辑的开销

- Allows a higher degree of modularization, enhancing comprehensibility and organization

  允许更高程度的模块化，增强可理解性和组织性

- Encapsulates imperative logic and allows build scripts to be as declarative as possible

  封装命令式逻辑并允许构建脚本尽可能具有声明性

> 使用插件

使用插件，Gradle需要两个步骤，解析插件和将插件应用到项目上。

**解析插件就是为指定的插件找到正确版本，并将其添加到build script的classpath中。**

应用插件意味着真正执行执行插件的[Plugin.apply(T)](https://docs.gradle.org/current/javadoc/org/gradle/api/Plugin.html#apply-T-) 



> 插件的分类



> Binary Plugin

可以通过Plugin的id来使用他们，id是全局唯一的。Gradle的核心插件可以使用简写例如`'java'` 表示 [JavaPlugin](https://docs.gradle.org/current/javadoc/org/gradle/api/plugins/JavaPlugin.html)。而其他二进制插件必须使用全限定名。（例如`com.github.foo.bar`）

插件可以是实现[Plugin](https://docs.gradle.org/current/javadoc/org/gradle/api/Plugin.html)接口的任何类。Gradle 提供的核心插件（例如`JavaPlugin`）会被自动解析（注：可以自动解析出合适的版本）。但是，非核心二进制插件需要先解析后才能使用（注：需要通过解析找到指定的版本）。有多种方式来引用插件

- Including the plugin from the plugin portal or a [custom repository](https://docs.gradle.org/current/userguide/plugins.html#sec:custom_plugin_repositories) using the plugins DSL (see [Applying plugins using the plugins DSL](https://docs.gradle.org/current/userguide/plugins.html#sec:plugins_block)).

  plugin DSL通过 [Gradle plugin portal](http://plugins.gradle.org/) 或者私有仓库来获取插件.

  ~~~groovy
  // 格式
  plugins {
      id «plugin id»  // plugin id是核心插件           
      id «plugin id» version «plugin version» [apply «false»]   
  }
  
  plugins {
      id 'java'
      id 'com.jfrog.bintray' version '1.8.5'
  }
  ~~~

  - plugins中不允许有其他语句

  - plugins{}不能嵌套在其他括号内，必须是顶级括号

  - id和version必须是静态字符串

  - 多次应用同一个插件是一样效果的

  - **核心插件或者在父项目中已经引入并定义了版本的插件，对当前项目可以不定义版本**  

  - apply false表示只引入该插件，但是不对当前项目应用                        

    如果您有一个[multi-project build](https://docs.gradle.org/current/userguide/multi_project_builds.html#multi_project_builds),您可能希望将插件应用于[multi-project build](https://docs.gradle.org/current/userguide/multi_project_builds.html#multi_project_builds)中的部分或全部子项目，而不是`root`项目。`plugins {}`块的默认行为是立即`resolve` *和* `apply`插件到当前项目。但是，您可以使用`apply false`语法告诉 Gradle 不要将插件应用到当前项目，然后在子项目的构建脚本中使用没有版本的`plugins {}`块。

    ~~~groovy
    // settings.gradle
    // include 表示这三个项目是当前项目的子项目
    include 'hello-a'
    include 'goodbye-c'
    
    // build.gradle
    plugins {
        id 'com.example.hello' version '1.0.0' apply false
        id 'com.example.goodbye' version '1.0.0' apply false
    }
    
    // hello-a/build.gradle
    plugins {
        id 'com.example.hello'
    }
    
    //goodbye-c/build.gradle
    plugins {
        id 'com.example.goodbye'
    }
    ~~~

    

- Applying plugins from the buildSrc directory

  buildSrc/build.gradle

  ```groovy
  // 定义插件
  
  // 引入定义插件所需要的的插件
  plugins {
      id 'java-gradle-plugin'
  }
  
  gradlePlugin {
      plugins {
          myPlugins {
              id = 'my-plugin' // 定义插件的id
              implementationClass = 'my.MyPlugin' // 定义插件的class
          }
      }
  }
  ```

  build.gradle

  ```groovy
  // 使用插件
  plugins {
      id 'my-plugin'
  }
  ```

- 插件的获取规则

  使用plugins DSL引入插件，只允许使用插件的id和version，所以gradle需要某种方法来获取插件所在依赖的groupid，artifactid和version。获取规则就是${plugin.id}:${plugin.id}.gradle.plugin:${plugin.version}

- 发布插件到私有仓库

  ~~~groovy
  plugins {
      id 'java-gradle-plugin' // 自定义插件所需要的的插件
      id 'maven-publish' // 发布到maven仓库所需要的的插件
      id 'ivy-publish' // 发布到ivy仓库所需要的的插件
  }
  
  group 'com.example'
  version '1.0.0'
  
  gradlePlugin {
      plugins {
          hello {
              id = 'com.example.hello'
              implementationClass = 'com.example.hello.HelloPlugin'
          }
          goodbye {
              id = 'com.example.goodbye'
              implementationClass = 'com.example.goodbye.GoodbyePlugin'
          }
      }
  }
  
  // 指定要发布的仓库
  publishing {
      repositories {
          maven {
              url '../../consuming/maven-repo'
          }
          ivy {
              url '../../consuming/ivy-repo'
          }
      }
  }
  ~~~

  使用gradle publish 将插件发布到仓库。

- 插件管理

  使用pluginManagement{}块对插件进行管理，该block块只能出现在settings.gradle文件中。

  - 定义插件仓库

    默认情况下，plugins DSL从公开的[Gradle Plugin Portal](https://plugins.gradle.org/)中获取并解析插件。

    ~~~groovy
    pluginManagement {
            repositories {
            mavenLocal()
            maven {
                url "https://maven.aliyun.com/repository/gradle-plugin"
            }
            mavenCentral()
            gradlePluginPortal()
            ivy {
                url './ivy-repo'
            }
        }
    }
    ~~~

    上面指定Gradle先从本地maven仓库获取插件，然后从阿里云插件仓库，maven中央仓库，gradle的公开仓库获取插件，最后从位于'./ivy-repo'的lvy仓库获取插件。如果不写gradlePluginPortal()就不会从gradle的公开仓库获取插件。

- Including the plugin from an external jar defined as a buildscript dependency (see [Applying plugins using the buildscript block](https://docs.gradle.org/current/userguide/plugins.html#sec:applying_plugins_buildscript)).

- Defining the plugin as a source file under the buildSrc directory in the project (see [Using buildSrc to extract functional logic](https://docs.gradle.org/current/userguide/organizing_gradle_projects.html#sec:build_sources)).

- Defining the plugin as an inline class declaration inside a build script.





