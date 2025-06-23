package com.tiger.embeder.dependency.classpath;

import lombok.Getter;

import java.util.ArrayList;
import java.util.List;

@Getter
public class BuildClasspath {
    private final List<String> classpath = new ArrayList<>();
}