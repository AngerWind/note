package com.tiger.binary;


import org.gradle.api.Action;
import org.gradle.api.Plugin;
import org.gradle.api.Task;
import org.gradle.api.internal.project.ProjectInternal;

import java.util.List;

public class JavaPluginWithConfig implements Plugin<ProjectInternal> {

    public static class JavaPluginConfig {
        private String firstName;
        private String lastName;
    }


    @Override
    public void apply(ProjectInternal project) {

        JavaPluginConfig javaPluginConfig = project.getExtensions().create("javaPluginConfig", JavaPluginConfig.class);

        // 设置默认的配置
        javaPluginConfig.firstName = "zhang";
        javaPluginConfig.lastName = "san";

        project.getTasks().register("printJavaPluginConfig", new Action<Task>() {
            @Override
            public void execute(Task task) {
                // 在task中使用配置
                System.out.println(javaPluginConfig.firstName + "-" + javaPluginConfig.lastName);
            }
        });

    }
}
