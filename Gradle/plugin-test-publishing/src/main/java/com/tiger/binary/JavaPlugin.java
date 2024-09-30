package com.tiger.binary;

import org.gradle.api.Action;
import org.gradle.api.Plugin;
import org.gradle.api.Task;
import org.gradle.api.internal.project.ProjectInternal;

public class JavaPlugin implements Plugin<ProjectInternal> {
    @Override
    public void apply(ProjectInternal target) {
        target.getTasks().register("java-binary", new Action<Task>() {
            @Override
            public void execute(Task task) {
                System.out.println("java-binary");
            }
        });

    }
}