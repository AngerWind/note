package org.example;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.maven.artifact.factory.ArtifactFactory;
import org.apache.maven.execution.MavenSession;
import org.apache.maven.plugin.*;
import org.apache.maven.plugin.descriptor.PluginDescriptor;
import org.apache.maven.plugins.annotations.*;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.project.MavenProject;
import org.apache.maven.repository.RepositorySystem;
import org.apache.maven.repository.legacy.metadata.ArtifactMetadataSource;
import org.apache.maven.settings.Settings;
import org.codehaus.plexus.component.annotations.Component;

import java.io.File;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.Properties;

@Mojo(name = "time", // 指定这个mojo对应的goal的名字, 然后就可以通过plugin-prefix:name 来调用这个mojo
        defaultPhase = LifecyclePhase.PACKAGE, // 默认绑定到的phase
        /*
         * 是否要直接调用, 还是通过声明周期来调用
         * 注意, 如果你声明为了true, 那么defaultPhase就会失效, 这个goal不会默认绑定到生命周期上, 你必须手动绑定到goal上
        */
        requiresDirectInvocation = false,
        /*
         *  在执行这个 Mojo 之前，是否需要解析依赖（包括下载 .jar、确定依赖的完整性等）。
         *  如果你的插件需要访问编译后的 .class 文件、依赖 jar 包、或者依赖树结构，就必须设置这个属性。
         *  否则 Maven 默认不会浪费时间做依赖解析，加快执行速度。
         *    - NONE: maven跳过依赖解析, 适合简单输出信息, 本地文件操作, 不用管依赖的任务
         *    - COMPILE: maven在执行插件之前, 会解析pom, 下载compile scope的依赖, 构建`Project.getArtifacts`, 你可以让mojo访问这些依赖
         *               适合需要处理 .class 文件、或分析编译结果的任务
         *    - RUNTIME: 解析runtime范围的依赖
         *    - COMPILE_AND_RUNTIME: 解析 compile 和 runtime 范围的依赖
         *    - TEST: 解析compile, runtime, test范围的依赖	单元测试相关插件，比如 surefire 插件
         *    - RUNTIME_PLUS_SYSTEM: 解析 runtime和system 范围的依赖（极少用）
         */
        requiresDependencyResolution = ResolutionScope.COMPILE_PLUS_RUNTIME,
        /*
         * 和上面类似, 但是requiresDependencyResolution会收集依赖的gav, 下载jar包, 解决版本冲突
         * requiresDependencyCollection只会收集依赖的gav, 不会下载jar包, 比如你可以通过这个范围来
         */
        requiresDependencyCollection = ResolutionScope.COMPILE_PLUS_RUNTIME,
        /*
         * 实例化策略, 如果一个goal绑定到了多个phase上面, 应该怎么实例化
         *   - PER_LOOKUP: 每个phase都创建一个mojo
         *   - SINGLETON: 同一个生命周期的所有phase共享一个mojo实例
         *   - KEEP_ALIVE: 即使生命周期结束也不销毁, 缓存住, 下次需要的时候复用 (很少使用)
         *   - POOLABLE: 可以被池化, maven提前创建一批对象, 放到一个池子里面, 之后进行复用,
         *               mojo要实现Poolable接口, 告诉maven如何reset mojo的状态(很少使用)
        */
        instantiationStrategy = InstantiationStrategy.PER_LOOKUP,
        requiresProject = true, // 是否要求在一个项目中执行, 如果为 false，可以在无 pom.xml 的目录执行
        /*
         * 当你通过mvn your-plugin:your-goal来执行插件的时候
         *    - 如果为true, 那么maven只在项目的最顶层调用一次插件, 主要用于收集子模块的信息, 生成统一的报告, 跨多模块的大操作
         *    - 如果为false, maven会对每个模块都调用一次插件
        */
        aggregator = true,
        requiresOnline = false, // 执行时 必须有网络连接，否则 Maven 报错, 用于需要访问远程服务器或仓库的插件
        /*
         * 当插件被使用的时候, maven会把<configuration> ... </configuration> 中的内容解析为对象, 然后注入到mojo的 @Parameter字段中
         * configurator指定了将xml转换为对象的配置器, 默认使用的是BasicComponentConfigurator
         * 如果你要自定义配置器, 你可以实现CustomComponentConfigurator
        */
        configurator = "", // 指定 自定义的配置器类。空字符串表示用默认配置器. 例如复杂的 injection、嵌套 XML 结构时需要自定义
        threadSafe = true) // 声明插件是线程安全的 , 如果写 false，并行构建时会被强制串行执行

// 定义在执行这个goal之前, 需要执行clean生命周期的post-clean phase,  和time这个goal
@Execute(phase = LifecyclePhase.POST_CLEAN, goal = "time", lifecycle = "clean")
public class TimerPlugin extends AbstractMojo {

    /*
     * !!!!!!!千万不要设置name属性为除了字段名以外的其他值, 机制很复杂, 很容易报错, 不要动这个属性就好
     * <p>
     * 默认情况下, 你可以在configuration中通过字段名来设置这个值
     * 如果设置alias, 就可以在configuration中通过 alias 或者 字段名 来设置这个值
     * 如果设置property, 就可以在命令行中通过-Dproperty=value来设置这个值, 或者在pom.xml中通过<properties>中设置这个值
     */
    @Parameter(// name = "current",
            alias = "time1.current",
            property = "time2.current",
            defaultValue = "2022-01-01", // 默认值
            required = false,
            readonly = true) // 这个属性是否是只读的, 如果是, 那么你在修改currentTime的引用的时候, 会发出!警告!
    private String currentTime;

    /*
     * 这里的 args 里面的标签名可以任意
     * <configuration>
     *     <args>
     *         <arg>...</arg>
     *         <arg>...</arg>
     *     </args>
     * </configuration>
     */
    @Parameter(required = false)
    private List<String> args;

    /*
     * 这里的args里面的标签名可以任意
     * <configuration>
     *     <mymap>
     *         <key1>...</key1>
     *         <key2>...</key2>
     *     </mymap>
     * </configuration>
     */
    @Parameter(required = false)
    private Map<String, String> mymap;

    /*
     * <configuration>
     * <myProperties>
     *   <property>
     *     <name>propertyName1</name>
     *     <value>propertyValue1</value>
     *   <property>
     *   <property>
     *     <name>propertyName2</name>
     *     <value>propertyValue2</value>
     *   <property>
     * </myProperties>
     * </configuration>
     */
    @Parameter
    private Properties myProperties;

    /**
     * <configuration>
     * <student>
     *   <age>18</age>
     *   <name>张三</name>
     * </student>
     * </configuration>
     */
    @Parameter
    private Student student;


    // 代表当前的构建会话，它包含了构建的上下文和执行阶段。
    // 你可以通过 MavenSession 获取当前项目、构建过程中执行的插件等信息。
    @Parameter(defaultValue = "${session}", readonly = true)
    private MavenSession session;

    // 代表当前的 Maven 项目。它包含项目的所有信息，如依赖、插件、构建配置等。
    @Parameter(defaultValue = "${project}", readonly = true)
    private MavenProject project;

    // 用于处理Maven仓库相关的操作
    @Parameter(defaultValue = "${repositorySystem}", readonly = true)
    private RepositorySystem repositorySystem;

    // 用于处理Maven artifact 相关的操作
    @Parameter(defaultValue = "${artifactFactory}", readonly = true)
    private ArtifactFactory artifactFactory;

    // 用于获取artifact的元数据。
    @Parameter(defaultValue = "${artifactMetadataSource}", readonly = true)
    private ArtifactMetadataSource artifactMetadataSource;

    @Parameter(defaultValue = "${mojoExecution}", readonly = true)
    private MojoExecution mojoExecution;

    @Parameter(defaultValue = "${plugin}", readonly = true) // Maven 3 only
    private PluginDescriptor pluginDescriptor;

    @Parameter(defaultValue = "${pluginManager}", readonly = true)
    private PluginManager pluginManager;

    @Parameter(defaultValue = "${settings}", readonly = true)
    private Settings settings;


    // ========================当前项目构建时的各种路径==================================
    @Parameter(defaultValue = "${project.basedir}", readonly = true)
    private File basedir; // 项目的根目录
    @Parameter(defaultValue = "${project.build.directory}", readonly = true)
    private File target; // target目录
    @Parameter(defaultValue = "${project.build.outputDirectory}", readonly = true)
    private File outputDirectory; // target/classes目录
    @Parameter(defaultValue = "${project.build.testOutputDirectory}", readonly = true)
    private File testOutputDirectory; // target/test-classes目录
    @Parameter(defaultValue = "${project.build.sourceDirectory}", readonly = true)
    private File sourceDirectory; // src/main/java目录
    @Parameter(defaultValue = "${project.build.testSourceDirectory}", readonly = true)
    private File testSourceDirectory; // src/test/java目录
    @Parameter(defaultValue = "${project.build.resources}", readonly = true)
    private List<File> resources; // src/main/resources目录
    @Parameter(defaultValue = "${project.build.testResources}", readonly = true)
    private List<File> testResources; // src/test/resources目录
    @Parameter(defaultValue = "${project.build.directory}\\${project.artifactId}-${project.version}.jar")
    private File jar; // 打包后的jar文件的目录

    // ================================当前项目的gav=================================
    @Parameter(defaultValue = "${project.groupId}", readonly = true)
    private String groupId;
    @Parameter(defaultValue = "${project.artifactId}", readonly = true)
    private String artifactId;
    @Parameter(defaultValue = "${project.version}", readonly = true)
    private String version;


    public void execute() throws MojoExecutionException, MojoFailureException {
        getLog().info("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        getLog().info("timer plugin is running, current time is " + currentTime);
        args.forEach(getLog()::info);

        // 输出当前编译后class存放的路径
        getLog().info("-----------------------------------------------------------");
        getLog().info("outputDirectory = " + outputDirectory.getAbsolutePath());
        getLog().info("target = " + target.getAbsolutePath());
        getLog().info("basedir = " + basedir.getAbsolutePath());
        getLog().info("-----------------------------------------------------------");

        // 通过 MavenSession 获取当前构建的所有项目
        for (MavenProject mavenProject : session.getProjects()) {
            getLog().info("Project: " + mavenProject.getArtifactId() + " (" + mavenProject.getVersion() + ")");
        }
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class Student {
        private String name;
        private int age;
    }


}