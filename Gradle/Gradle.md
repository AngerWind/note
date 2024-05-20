## gradle安装

1. 下载gradle安装包并解压
2. 配置环境变量
   1. GRADLE_HOME为解压目录
   
   2. 配置GRADLE_USER_HOME, gradle会将下载到的jar放在这个目录下
   
      否则会下载到`C:\Users\用户名\.gradle\caches\modules-2\files-2.1`
   
   3. 配置M2_HOME为maven安装目录, 方便gradle查找本地maven仓库
3. 在命令行执行`gradle -v`

## Groovy安装

1. 下载groovy安装包

2. 配置环境变量

   1. GROOVY_HOME为解压目录

   2. 配置path环境变量为%GROOVY_HOME%/bin

3. 在命令行执行`groovy -v`

## gradle设置下载源

### 全局设置

gradle会在`构建的最开始按照顺序执行如下地方的的gradle脚本`, 所以可以在这些地方配置maven仓库

1. 在命令行指定文件,例如：gradle --init-script yourdir/init.gradle -q taskName。

   你可以多次输入此命令来指定多个init文件  

2. 把`init.gradle`文件放到 `GRADLE_USER_HOME/.gradle/` 目录下

3. 把`以.gradle结尾的文件`放到 `GRADLE_USER_HOME/.gradle/init.d/` 目录下

4. 把以`.gradle结尾的文件`放到 `GRADLE_HOME/init.d/` 目录下  

如果同一目录下有多个gradle文件, 那么会按照a-z的顺序执行

所以我们可以在这些目录下创建一个init.gradle文件, 内容如下

~~~groovy
allprojects {
    // 项目所需要的jar包, 会从这些仓库中查找
    // 查找是按照顺序来执行的, 所以mavenLocal需要配置在最上面
    // 如果这些都没有找到机会报错
    repositories {
        // 指定使用maven本地仓库
        // 先查找USER_HOME/.m2/settings.xml文件来确定本地maven库
        // 否则找 M2_HOME/conf/settings.xml文件来确定, 一般我们习惯配MAVEN_HOME, 所以需要另外配置一个M2_HOME
        // 最后使用 USER_HOME/.m2/repository来作为maven本地库
        mavenLocal()
        // 如果在maven本地库中找不到的jar包, 会通过远程库来下载
        // jar包会下载在GRADLE_USER_HOME\caches\modules-2\files-2.1\下
        maven { 
            name "Alibaba";
            url   "https://maven.aliyun.com/repository/public" 
        }
		// 指定maven中央仓库
        mavenCentral()
} 
    // 主要用来设置build时所需要使用的插件的仓库
    buildscript {
        repositories {
            maven { 
                name "Alibaba";
                url 'https://maven.aliyun.com/repository/public' 
            }
            maven { 
                name "Bstek";
                url 'https://nexus.bsdn.org/content/groups/public/' 
            }
            maven { 
                name "M2";
                url 'https://plugins.gradle.org/m2/' 
            }
        }
    }
}
~~~

### 项目单独设置

在项目的`build.gradle`中配置

~~~groovy
repositories {
    // 先查找USER_HOME/.m2/settings.xml文件来确定本地maven库
    // 否则找 M2_HOME/conf/settings.xml文件来确定, 一般我们习惯配MAVEN_HOME, 所以需要另外配置一个M2_HOME
    // 最后使用 USER_HOME/.m2/repository来作为maven本地库
    mavenLocal()
    // 如果在maven本地库中找不到的jar包, 会通过远程库来下载
    // jar包会下载在GRADLE_USER_HOME\caches\modules-2\files-2.1\下
    maven {
        url('https://maven.aliyun.com/repository/public')
    }
    // 直接使用maven中央仓库
    mavenCentral()
}
~~~



## Gradle Wrapper

**鉴于Gradle每个版本变动比较大, 推荐使用这种方式, 而不是直接使用本地的gradle**



在创建的gradle项目目录下, 有一个`gradle`文件夹和`gradlew.bat`和`gradlew`

<img src="img/gradle/image-20240124175501396.png" alt="image-20240124175501396" style="zoom:25%;" />

gradlew其实就是gradle wrapper, 他是对gradle的一层包装, 用于解决实际开发中可能遇到不同的项目需要的不同版本的gradle的问题

你可以像使用gradle命令一样去使用gradlew文件

当我们调用gradlew文件的时候, 他会读取`gradle/wrapper/gradle.properties`文件中设置的属性, 然后使用`gradle/wrapper/gradle-wrapper.jar`指定的地方调用对应版本的gradle来执行命令



**gradle-wrapper.properties**

`gradle/wrapper/gradle-wrapper.properties`的内容如下:

~~~properties
# 下载的gradle压缩包解压后的存储的主目录, 指定为GRADLE_USER_HOME环境变量
# 如果没有配置环境变量, 那么默认在当前用户家目录的.gradle文件夹下
distributionBase=GRADLE_USER_HOME
# 解压后的gradle压缩包的路径, 相对于distributionBase
distributionPath=wrapper/dists
# gradle压缩包的下载地址
distributionUrl=https\://services.gradle.org/distributions/gradle-5.2.1-bin.zip
# 同distributionBase, 只不过是存放zip压缩包的
zipStoreBase=GRADLE_USER_HOME
# 同distributionPath, 只不过是存放zip压缩包的
zipStorePath=wrapper/dists
~~~

上面我们通过`distributionUrl`指定了使用gradle的版本为`5.2.1`, 并且下载的gradle包只含有bin文件

通过`distributionBase`和`distributionPath`指定了gradle安装包解压后的目录在`GRADLE_USER_HOME/wrapper/dists/`下面



**GradleWrapper的执行流程**

1. 当我们第一次执行` ./gradlew build` 命令的时候，gradlew 会读取 gradle-wrapper.properties 文件的配置信息
2. 准确的将指定版本的 gradle 下载并解压到指定的位置(GRADLE_USER_HOME目录下的wrapper/dists目录中)
3. 并构建本地缓存(GRADLE_USER_HOME目录下的caches目录中),下载再使用相同版本的gradle就不用下载了
4. 之后执行的 ./gradlew 所有命令都是使用指定的 gradle 版本。



**修改GradleWrapper使用的Gradle版本**

1. 可以直接在`gradle-wrapper.properties`中直接修改`distributionUrl`的连接, 这样在build的时候gradlew会自动下载并使用该版本

2. 通过如下命令, 会自动修改`gradle-wrapper.properties`中的`distributionUrl`属性

   ~~~shell
   gradle wrapper --gradle-version 5.2.1
   ~~~



**关联Gradle源码**

在上面的`gradle-wrapper.properties`中, 我们使用`distributionUrl=https\://services.gradle.org/distributions/gradle-5.2.1-bin.zip`来指定gradle的版本和下载链接, 但是该链接下载后只有可执行文件, 并没有gradle源码

我们有两种方式来关联源码:

1. 将bin改为all, 如下, 这样下载的gradle就有源码了

   ~~~properties
   distributionUrl=https\://services.gradle.org/distributions/gradle-5.2.1-all.zip
   ~~~

2. 通过如下命令, 使用该命令后会自动修改`gradle-wrapper.properties`中的`distributionUrl`属性, 将bin修改为all

   ~~~shell
   gradle wrapper --gradle-version 5.2.1 --distribution-type all
   ~~~



## Gradle.properties文件的作用

在创建gradle项目的时候, 默认在项目根目录下是没有这个文件的, 但是我们可以手动创建, 我们可以在该文件中对gradle本身进行一些配置, 常见配置项如下:

~~~properties
# 传递给gradle使用的jvm的参数
org.gradle.jvmargs=-Xmx1536M
# 是否启用缓存, 默认false, 设置为true会重用上次build的task output
org.gradle.caching=true
# 是否并行构建, 默认为false, 设置为true会使用org.gradle.workers.max个worker来构建项目
org.gradle.parallel=true
# gradle中worker的数量, 默认为cpu核数
org.gradle.workers.max=100
~~~

其他参数查看https://docs.gradle.org/current/userguide/build_environment.html#sec:gradle_configuration_properties



## 使用IDEA创建普通Gradle项目及目录介绍

<img src="img/gradle/image-20240123180343655.png" alt="image-20240123180343655" style="zoom: 33%;" />

<img src="img/gradle/image-20240123180406749.png" alt="image-20240123180406749" style="zoom:33%;" />

gradle的目录结构和maven的并没有什么不同, 只是有`settings.gradle`和`build.gradle`

1. settings.gradle

   - 一个大项目只有一个, 下面的子项目没有settings.gradle文件了

   - 可以在该文件中定义gav和子项目
   - 子项目必须在该文件中显示指定, 否则不会作为子项目

2. build.gradle

   - 每个项目有一个build.gradle文件, 包括子项目
   - 可以在该文件中定义一系列的task, 来指示如何构建当前的项目



## 使用IDEA创建web的Gradle项目

1. 创建项目

   <img src="img/gradle/image-20240123181402594.png" alt="image-20240123181402594" style="zoom: 25%;" />

2. 查看生成的目录

   <img src="img/gradle/image-20240123182505737.png" alt="image-20240123182505737" style="zoom: 50%;" />

3. 在`build.gradle`文件中添加war插件

   <img src="img/gradle/image-20240123182438733.png" alt="image-20240123182438733" style="zoom: 25%;" />

4. 自己创建`webapp/WEB-INF`目录, 并在其下创建`web.xml`文件

   <img src="img/gradle/image-20240123182909434.png" alt="image-20240123182909434" style="zoom:33%;" />

   ~~~xml
   <web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee" 
   		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
   		xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
   		http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd" id="WebApp_ID" version="4.0">
   
   </web-app>
   ~~~

5. 在build.gradle中添加依赖

   ~~~groovy
   dependencies {
       compileOnly 'javax.servlet:servlet-api:2.5'
   }
   ~~~

6. 创建Servlet

   ~~~java
   public class HelloServlet extends HttpServlet {
       protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
   
           request.setCharacterEncoding("utf-8");
           String msg = request.getParameter("msg");
           System.out.println("获取参数方式1："+msg);
           msg = URLDecoder.decode(request.getParameter("msg"),"utf-8");
           System.out.println("解码之后:"+msg);
           //        jsp页面虽然设置了utf-8编码，但传输的过程中使用的编码是：ISO-8859-1
           String msg2 = new String(request.getParameter("msg").getBytes("ISO-8859-1"),"utf-8");
           System.out.println("获取参数方式2："+msg2);
           //        获取参数方式2：chinese中文字符串乱码测试
   
           response.setCharacterEncoding("utf-8");
   
           response.setContentType("text/html");
           response.setCharacterEncoding("utf-8");
           response.getWriter().println("<h2 style=\"color:orange\">请求成功，显示参数："+msg2+"</h2>");
       }
   
       protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
           doPost(request,response);
       }
   }
   ~~~

7. 添加Servlet映射

   ~~~xml
       <servlet>
           <servlet-name>helloServlet</servlet-name>
           <servlet-class>com.tiger.servlet.HelloServlet</servlet-class>
       </servlet>
       <servlet-mapping>
           <servlet-name>helloServlet</servlet-name>
           <url-pattern>/h</url-pattern>
       </servlet-mapping>
   ~~~

8. 使用tomcat部署

<img src="img/gradle/image-20240123213059523.png" alt="image-20240123213059523" style="zoom: 25%;" />

<img src="img/gradle/image-20240123213145869.png" alt="image-20240123213145869" style="zoom:25%;" />

![image-20240123213157814](img/gradle/image-20240123213157814.png)



## Gradle中的测试

gradle执行JUnit和TestNG测试, 在执行`gradle test`的时候, gradle会自动执行所有测试类中添加了@Test注解的方法, 并在`build/reports/tests`目录下生成测试报告

**Junit 使用**
Gradle 对于 Junit4.x 支持

~~~groovy
dependencies {
    testImplementation group: 'junit' ,name: 'junit', version: '4.12'
} 
test {
    useJUnit()
}
~~~

Gradle 对于 Junit5.x 版本支持

~~~groovy
dependencies {
    testImplementation 'org.junit.jupiter:junit-jupiter-api:5.8.1'
    testRuntimeOnly 'org.junit.jupiter:junit-jupiter-engine:5.8.1'
} 
test {
    useJUnitPlatform()
}
~~~

包含和排除特定测试

~~~groovy
test {
    enabled true // 指定是否开启测试
    useJUnit() // 指定使用junit4测试
    include 'com/**' // 指定只执行特定包下的测试类
    exclude 'com/abc/**' // 指定不执行特定包下的测试类
}
~~~

  



## Gradle中的依赖

### maven中的scope

|          | compile | test | runtime | 例子        | 依赖传递                              |
| :------: | :-----: | :--: | :-----: | ----------- | ------------------------------------- |
| compile  |    √    |  √   |    √    | spring-core | 是                                    |
| provided |    √    |  √   |         | servlet-api | 否                                    |
|  system  |    √    |  √   |         |             | 是(必须通过systemPath显示指定jar路径) |
|   test   |         |  √   |         | junit       | 否                                    |
| runtime  |         |  √   |    √    | JDBC驱动    | 是                                    |

### Gradle中的scope

![image-20240315171554593](img/gradle/image-20240315171554593.png)



### api和implement的区别

![image-20240315171752178](img/gradle/image-20240315171752178.png)

总结就是

1. a implementation b, 和a api b, b在编译, 运行时都有效

2. 不同的点在于, 当a被c引用时

   a implementation b这种方式不会把b暴露给c, 所以c不能使用b

   a api b这种方式会把c暴露给c, 所以c可以直接使用b
   
   

## Gradle 打包发布

~~~gradle
plugins {
	// 如果发布war包， 需要war插件
	// java-library支持带源码、 文档发布
	id 'java-library' 
	// 添加发布插件
	id 'maven-publish' 
}

// 在打包的时候, 如果要把源码和javadoc打包进去, 需要引入java-library
javadoc.options.encoding("UTF-8")
java {
    withJavadocJar()
    withSourcesJar()
}
publishing {
    // 发布的仓库，有多个可选择
    // 不需要指定本地的maven仓库, gradle会找到${M2_HOME}下的settings.xml文件中指定的仓库位置
    repositories {

        maven {
            name = "localRepo"
            // 发布到当前项目根目录下的/build/repo/文件夹下
            url = layout.buildDirectory.dir("repo")
        }
        // 发布到网络上
        maven {
            name = "nexus"
            // 用户口令
            credentials {
                username 'your-username'
                password 'your-password'
            }

            // release仓库地址
            def releasesRepoUrl = "https://www.your-domain.com/repository/maven-releases/"
            // snapshots仓库地址
            def snapshotsRepoUrl = "https://www.your-domain.com/repository/maven-snapshots/"
            // 根据版本信息动态判断发布到snapshots还是release仓库
            url = version.endsWith('SNAPSHOT') ? snapshotsRepoUrl : releasesRepoUrl
            // 禁用使用非安全协议通信(比如http)
            allowInsecureProtocol false
        }
    }
    publications {    // 配置发布的产出包，一个项目也有可能有多个产出，但大部分时候只有一个

        // 指定一个产出包, myJar为名字
        myJar(MavenPublication) {
            // 指定gav
            groupId = "com.example"
            artifactId = "projectc"
            version = "1.0-SNAPSHOT"

            // 指定为jar包
            // 如果发布为war包, 那么需要引入war插件, 然后使用 from components.web
            from components.java

            // 给pom文件添加内容
            pom {
                licenses {
                    license {
                        name = 'The Apache License, Version 2.0'
                        url = 'http://www.apache.org/licenses/LICENSE-2.0.txt'
                    }
                }
                developers {
                    developer {
                        id = 'hengyumo'
                        name = 'hengyumo'
                        email = 'le@hengyumo.cn'
                    }
                }
            }
            
            // 修改pom文件中的配置
            pom.withXml {
                asNode()
                        .dependencies
                        .dependency
                        .findAll { dependency ->
                            (dependency.groupId.text() == 'com.example' &&
                             dependency.artifactId.text() == 'projectc' &&
                             dependency.scope.text() == 'runtime' )

                        }
                        .each { dependency ->
                            // 设置scope范围为compile
                            // *表示对scope数组下的所有节点进行操作
                            dependency.scope*.value = "compile"
                        }
            }
        }
    }
}
~~~

在配置了上面的配置之后, 在idea的task中, 会出现如下一个`publishing`组

![image-20240320224824407](img/gradle/image-20240320224824407.png)

里面的任务可以分为三类:

1. publish:  发布所有发布包到所有参考???? 可能吧, 不确定
2. generateMetadataFileForXXXXPublication:   为XXXX发布包生成metadata文件
3. generatePomFileForXXXX:   为XXXX发布包生成pom.xml, 生成的pom文件的位置在`build/publications/<publicationName>/pom-default.xml`
4. publishXXXXPublicationToBBBBB:  发布XXXX发布包到BBBBB仓库
5. publicXXXXPublicationToMavenLocal: 发布XXXX发布包到本地仓库
6. publishAllPublicationsToBBBBB:  发布所有的发布包到BBBBB仓库
7. publishToMavenLocal: 发布所有发布包到BBBBB仓库



需要注意的是, 在生成pom.xml文件中, **所有`test`类型的依赖都不会包含在pom.xml文件中, 并且所有其他范围的依赖都是`runtime`类型的, 而不是`compile`类型的**, 这就会导致我们在使用该依赖包的时候, 非常容易报`ClassNotFound`的异常, 这个时候我们就需要使用上面的`pom.withXml()`方法来修改我们的scope



## Groovy和Java混合编译

1. 创建一个java项目

   ![image-20240325190331112](img/gradle/image-20240325190331112.png)

2. 创建完成之后, 这个项目就是可以正常编译java的,  之后我们就需要添加对`Groovy` 的支持了

3. 在`build.gradle`文件中添加插件, 这样gradle就支持编译groovy了

   ~~~gradle
   plugins {
   	id "groovy"
   }
   ~~~

4. 添加groovy sdk,  用于编译groovy, 他可以是本机上的groovy, 也可以直接以maven依赖包的形式添加进来

   ~~~gradle
   dependencies {
   	// 用以编译groovy, 使用maven依赖包
       implementation 'org.codehaus.groovy:groovy-all:3.0.11'
       
       // 导入本机上的groovy sdk来编译groovy
       // 假如groovy_home为E:/groovy-3.0.9, 那么可以使用如下形式
       implementation fileTree('E:/groovy-3.0.9/lib') {
           include '*.jar'
           include '*/*.jar'
       }
   }
   ~~~

5. 在项目中创建存放`groovy`的文件夹

   <img src="img/gradle/image-20240325191535071.png" alt="image-20240325191535071" style="zoom:33%;" />