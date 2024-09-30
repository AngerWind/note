package com.tiger.binary

import groovy.transform.ToString
import groovy.transform.TupleConstructor
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.provider.Property

@ToString
class Config {
    String firstName
    String lastName
    Address address
}

@ToString
@TupleConstructor
class Address {
    String city
    String street
}


class GroovyPluginWithConfig implements Plugin<Project> {

    @Override
    void apply(Project project) {
        // 创建一个配置对象
        def config = project.extensions.create("groovyPlugin", Config)
        // 设置配置项的默认值
        config.firstName = "zhang"
        config.lastName = 'san'
        config.address = ["hanzhou", "xixi"]

        project.tasks.register('groovy-task-with-config') {
            doLast {
                // 在task中使用配置对象
                println config
            }
        }
    }
}
