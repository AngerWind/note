package com.tiger.embeder.dependency.tree;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class ArtifactInfo {

    public String groupId;
    public String artifactId;
    public String type;
    public String version;
    public String scope;
    public boolean omitted;
    public String omittedReason;

    /**
     * @param artifactLine example1: org.springframework:spring-jcl:jar:6.2.6:compile
     *                     example2: (org.springframework:spring-core:jar:6.2.6:compile - omitted for duplicate)
     *                     example3: (com.fasterxml.jackson.core:jackson-annotations:jar:2.17.2:compile - omitted for conflict with 2.18.3)
     */
    public static ArtifactInfo parse(String artifactLine) {
        ArtifactInfo info = new ArtifactInfo();

        String line = artifactLine.trim();
        if (line.contains(" - omitted for")) {
            info.omitted = true;
            int idx = line.indexOf(" - ");
            // length-1 是为了去掉最后一个)括号
            info.omittedReason = line.substring(idx + 3, line.length() - 1);
            // 1是为了去掉第一个(括号
            line = line.substring(1, idx).trim();
        }

        String[] parts = line.split(":");
        if (parts.length >= 5) {
            info.groupId = parts[0];
            info.artifactId = parts[1];
            info.type = parts[2];
            info.version = parts[3];
            info.scope = parts[4];
        } else {
            info.artifactId = line; // fallback
        }

        return info;
    }

    @Override
    public String toString() {
        String base = String.format(
            "%s:%s:%s:%s:%s",
            groupId, artifactId, type, version, scope
        );
        return omitted ? base + " - " + omittedReason : base;
    }

    public String toMavenFormattedString() {
        String base = String.format(
            "%s:%s:%s:%s:%s",
            groupId, artifactId, type, version, scope
        );
        return omitted ? "(" + base + " - " + omittedReason + ")" : base;
    }

}