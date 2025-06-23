package com.tiger.embeder.dependency.tree;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.ArrayList;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class DependencyNode {

    private static final ObjectMapper objectMapper = new ObjectMapper();


    public ArtifactInfo artifact;
    public List<DependencyNode> children = new ArrayList<>();

    public DependencyNode(ArtifactInfo artifact) {
        this.artifact = artifact;
    }

    @Override
    public String toString() {
        return artifact.toString();
    }

    public String writeValueAsJsonString() {
        try {
            return objectMapper.writeValueAsString(this);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialize ArtifactInfo to JSON", e);
        }
    }

    public String writeValueAsMavenFormattedString() {
        return DependencyTreeParser.writeValueAsMavenFormattedString(this);
    }
}