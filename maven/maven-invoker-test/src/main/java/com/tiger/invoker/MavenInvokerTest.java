package com.tiger.invoker;

import org.apache.maven.shared.invoker.*;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.io.File;
import java.util.List;
import java.util.Properties;

public class MavenInvokerTest {

    public static Invoker invoker;

    @BeforeAll
    public static void createInvoker() {
        invoker = new DefaultInvoker();
        // 如果不设置的话, 会自动使用 maven.home
        invoker.setMavenHome(new File("E:\\apache-maven\\apache-maven-3.8.5"));
    }


    // https://maven.apache.org/plugins/maven-dependency-plugin/
    public static void invokeMaven(List<String> goals, Properties properties) throws Exception {
        InvocationRequest request = new DefaultInvocationRequest();
        request.setPomFile(new File("C:\\Users\\Administrator\\Desktop\\maven-invoker-test\\simple-project\\pom.xml"));
        request.setGoals(goals);

        request.setGlobalSettingsFile(new File("E:\\apache-maven\\settings\\maven-test.xml"));
        // request.setShowVersion(true); // 是否打印使用的maven版本, maven home, java version, os name, os version

        if (properties != null) {
            request.setProperties(properties);
        }

        // request.setQuiet(true); // 不会输出任何的东西

        request.setOutputHandler(s -> System.out.println("Output " + s));
        request.setErrorHandler(s -> System.err.println("Error " + s));

        // 脚本交互模式
        request.setBatchMode(true);

        InvocationResult result = invoker.execute(request);
        if (result.getExitCode() != 0) {
            if (result.getExecutionException() != null) {
                result.getExecutionException().printStackTrace();
            }
        }
    }

    public static void invokeMaven(List<String> goals) throws Exception {
        invokeMaven(goals, null);
    }

    @Test
    public void testMavenInvoker2() throws Exception {
        List<String> goals = List.of("dependency:tree");
        Properties properties = new Properties();
        // 默认为false, 只会输出有效的maven依赖树, 如果产生了依赖冲突, 只会显示有效的, 而不会显示被omitted的依赖
        // 设置为true, 会输出所有的依赖, 包括被omitted的依赖
        properties.setProperty("verbose", "true");
        invokeMaven(goals, properties);
    }

    @Test
    public void collect() throws Exception {
        // 下载依赖的pom.xml, 并搜集依赖的信息, 但是不下载依赖的jar包
        List<String> goals = List.of("dependency:collect");  // 只会以list的方式展示所有的依赖
        invokeMaven(goals);
    }

    @Test
    public void buildClasspath() throws Exception {
        List<String> goals = List.of("dependency:build-classpath");
        invokeMaven(goals);
    }
}
