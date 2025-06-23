package com.tiger.embeder;

import com.tiger.embeder.dependency.classpath.BuildClasspath;
import com.tiger.embeder.dependency.classpath.MavenBuildClasspathParser;
import com.tiger.embeder.dependency.classpath.MavenBuildClasspathTask;
import com.tiger.embeder.dependency.tree.DependencyNode;
import com.tiger.embeder.dependency.tree.DependencyTreeParser;
import com.tiger.embeder.dependency.tree.MavenDependencyTreeTask;
import org.junit.jupiter.api.Test;

import java.util.List;

public class MavenInvokerTest {
    public static final String MULTI_MODULE_PROJECT_DIRECTORY = "C:\\Users\\Administrator\\Desktop\\maven-invoker-test\\simple-project";
    public static final String WORKING_DIRECTORY = MULTI_MODULE_PROJECT_DIRECTORY;
    public static final String POM_XML = "C:\\Users\\Administrator\\Desktop\\maven-invoker-test\\simple-project\\pom.xml";

    @Test
    public void test() {

        MavenBuildClasspathTask mavenBuildClasspathTask = new MavenBuildClasspathTask();
        MavenDependencyTreeTask mavenDependencyTreeTask = new MavenDependencyTreeTask();
        MavenEmbedderInvoker.invokeMaven(
            WORKING_DIRECTORY,
            MULTI_MODULE_PROJECT_DIRECTORY,
            null,
            POM_XML,
            List.of(mavenBuildClasspathTask, mavenDependencyTreeTask )
        );

        String result = mavenBuildClasspathTask.getResult();
        BuildClasspath buildClasspath = MavenBuildClasspathParser.parseClasspath(result);
        List<String> classpath = buildClasspath.getClasspath();
        if (classpath != null) {
            classpath.forEach(System.out::println);
        }

        List<String> result1 = mavenDependencyTreeTask.getResult();
        DependencyNode parse = DependencyTreeParser.parse(result1);

    }
}
