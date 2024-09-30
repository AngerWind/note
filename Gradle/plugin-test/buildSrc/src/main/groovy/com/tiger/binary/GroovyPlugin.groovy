package com.tiger.binary

import org.gradle.api.Plugin
import org.gradle.api.Project

class GroovyPlugin implements Plugin<Project>{
    @Override
    void apply(Project target) {
        target.tasks.register('groovy-binary') {
            doLast {
                println "executing groovy binary plugin"
            }
        }
    }
}
