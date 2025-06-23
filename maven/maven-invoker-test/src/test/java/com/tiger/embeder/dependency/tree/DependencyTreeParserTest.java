package com.tiger.embeder.dependency.tree;

import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class DependencyTreeParserTest {

    @Test
    void parse() {
        List<String> lines = Arrays.asList(
            "+- com.fasterxml.jackson.core:jackson-databind:jar:2.17.2:compile",
            "|  +- (com.fasterxml.jackson.core:jackson-annotations:jar:2.17.2:compile - omitted for conflict with 2.18.3)",
            "|  \\- com.fasterxml.jackson.core:jackson-core:jar:2.17.2:compile",
            "+- com.fasterxml.jackson.core:jackson-annotations:jar:2.18.3:compile",
            "+- org.projectlombok:lombok:jar:1.18.38:compile",
            "+- org.springframework:spring-aop:jar:6.2.6:compile",
            "|  +- org.springframework:spring-beans:jar:6.2.6:compile",
            "|  |  \\- (org.springframework:spring-core:jar:6.2.6:compile - omitted for duplicate)",
            "|  \\- (org.springframework:spring-core:jar:6.2.6:compile - omitted for duplicate)",
            "\\- org.springframework:spring-core:jar:6.2.6:compile",
            "   \\- org.springframework:spring-jcl:jar:6.2.6:compile"
        );
        StringBuilder sb = new StringBuilder();
        for (String line : lines) {
            sb.append(line).append("\n");
        }

        DependencyNode root = DependencyTreeParser.parse(lines);

        System.out.println("----------------------------------------");
        String mavenFormattedString = root.writeValueAsMavenFormattedString();
        System.out.println(mavenFormattedString.contentEquals(sb));
        System.out.println(mavenFormattedString);
        System.out.println("----------------------------------------");


        System.out.println(root.writeValueAsJsonString());
    }
}