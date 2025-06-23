package com.tiger.embeder.dependency.tree;

import java.util.*;

public class DependencyTreeParser {

    /**
     * @param lines
     * +- com.fasterxml.jackson.core:jackson-databind:jar:2.17.2:compile
     * |  +- (com.fasterxml.jackson.core:jackson-annotations:jar:2.17.2:compile - omitted for conflict with 2.18.3)
     * |  \- com.fasterxml.jackson.core:jackson-core:jar:2.17.2:compile
     * +- com.fasterxml.jackson.core:jackson-annotations:jar:2.18.3:compile
     * +- org.projectlombok:lombok:jar:1.18.38:compile
     * +- org.springframework:spring-aop:jar:6.2.6:compile
     * |  +- org.springframework:spring-beans:jar:6.2.6:compile
     * |  |  \- (org.springframework:spring-core:jar:6.2.6:compile - omitted for duplicate)
     * |  \- (org.springframework:spring-core:jar:6.2.6:compile - omitted for duplicate)
     * \- org.springframework:spring-core:jar:6.2.6:compile
     *    \- org.springframework:spring-jcl:jar:6.2.6:compile
     */
    public static DependencyNode parse(List<String> lines) {
        Stack<DependencyNode> stack = new Stack<>();
        Stack<Integer> indentStack = new Stack<>();
        DependencyNode root = new DependencyNode(new ArtifactInfo());

        stack.push(root);
        indentStack.push(-1);

        for (String line : lines) {
            int depth = getDepth(line);
            String artifactText = cleanArtifact(line);

            ArtifactInfo artifact = ArtifactInfo.parse(artifactText);
            DependencyNode node = new DependencyNode(artifact);

            // 上一个节点的深度比当前节点大, 说明上一个节点的所有子节点都已经处理完毕, 需要将上一个节点pop出来
            while (indentStack.peek() >= depth) {
                stack.pop();
                indentStack.pop();
            }

            // 当前节点是上一个节点的子节点, push到stack中, 用于处理当前节点的子节点
            stack.peek().children.add(node);
            stack.push(node);
            indentStack.push(depth);
        }

        return root;
    }

    private static int getDepth(String line) {
        int depth = 0;
        for (int i = 0; i < line.length(); i++) {
            // 如果字符串是 | 或者 空格, 说明他还是下一个层级的节点
            if (line.charAt(i) == '|' || line.charAt(i) == ' ') {
                depth++;
            } else if (line.startsWith("+-", i) || line.startsWith("\\-", i)) {
                // 如果字符串是 +- 或者 \-, 说明他是当前层级的节点
                break;
            }
        }
        return depth;
    }

    private static String cleanArtifact(String line) {
        // ^匹配字符串开头, \\\\表示正则中的\, +匹配加号, \\-是正则中的\-, 表示匹配-,  +表示重复一次或者多次, []表示或
        // 作用是移除line中开头的 | 或者 \ 或者 + 或者 - 或者 空格
        return line.replaceAll("^[|\\\\+\\- ]+", "").trim();
    }


    public static String writeValueAsMavenFormattedString(DependencyNode node) {
        StringBuilder sb = new StringBuilder();

        for (int i = 0; i < node.children.size(); i++) {
            boolean isLast = (i == node.children.size() - 1);
            writeValueAsMavenFormattedString(sb, node.children.get(i), "", isLast);
        }

        return sb.toString();
    }

    private static void writeValueAsMavenFormattedString(StringBuilder sb, DependencyNode node, String prefix, boolean isLast) {
        String connector = isLast ? "\\- " : "+- ";
        sb.append(prefix).append(connector).append(node.artifact.toMavenFormattedString()).append("\n");


        for (int i = 0; i < node.children.size(); i++) {
            boolean childIsLast = (i == node.children.size() - 1);
            String childPrefix = prefix + (isLast ? "   " : "|  ");
            writeValueAsMavenFormattedString(sb, node.children.get(i), childPrefix, childIsLast);
        }

    }
}
