package com.tiger.embeder.dependency.classpath;

import lombok.Getter;

import java.util.ArrayList;
import java.util.List;

public class MavenBuildClasspathParser {

    /**
     * 解析字符串，将“Dependencies classpath:”后的内容以分号拆分，生成File列表
     */
    public static BuildClasspath parseClasspath(String input) {
        String prefix = "Dependencies classpath:";
        int startIndex = input.indexOf(prefix);
        if (startIndex == -1) {
            throw new IllegalArgumentException("输入字符串不包含 'Dependencies classpath:'");
        }
        String pathsStr = input.substring(startIndex + prefix.length()).trim();

        String[] paths = pathsStr.split(";");
        BuildClasspath mavenBuildClasspath = new BuildClasspath();
        mavenBuildClasspath.getClasspath().addAll(List.of(paths));
        return mavenBuildClasspath;
    }


}