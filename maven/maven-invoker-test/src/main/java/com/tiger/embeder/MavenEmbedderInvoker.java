package com.tiger.embeder;

import ch.qos.logback.core.joran.conditional.IfAction;
import org.apache.maven.cli.CliRequest;
import org.apache.maven.cli.MavenCli;
import org.apache.maven.shared.utils.logging.MessageUtils;
import org.codehaus.plexus.classworlds.ClassWorld;

import java.io.File;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.nio.file.FileSystems;
import java.util.List;

public class MavenEmbedderInvoker {

    public static final String FILE_SEPARATOR = FileSystems.getDefault().getSeparator();

    // todo 修改为真正的路径
    public static final String DEFAULT_SETTINGS_XML = "E:\\apache-maven\\settings\\settings _with_proxy.xml";

    public static void invokeMaven(String workingDirectory, String multiModuleProjectDirectory, String pomXml, List<MavenInvokerGoal<?>> goals) {
        invokeMaven(workingDirectory, multiModuleProjectDirectory, DEFAULT_SETTINGS_XML, pomXml, goals);
    }

    public static void invokeMaven(String workingDirectory, List<MavenInvokerGoal<?>> goals) {
        invokeMaven(
            workingDirectory,
            workingDirectory,
            DEFAULT_SETTINGS_XML,
            workingDirectory + FILE_SEPARATOR + "pom.xml",
            goals
        );
    }

    public static void invokeMaven(String workingDirectory, String multiModuleProjectDirectory, String settingsXml, String pomXml, List<MavenInvokerGoal<?>> goals) {

        if (pomXml == null || pomXml.isBlank()) {
            throw new RuntimeException("pom.xml is null or blank");
        }
        if (multiModuleProjectDirectory == null || multiModuleProjectDirectory.isBlank()) {
            throw new RuntimeException("multiModuleProjectDirectory is null or blank");
        }
        if (workingDirectory == null || workingDirectory.isBlank()) {
            throw new RuntimeException("workingDirectory is null or blank");
        }

        if (settingsXml == null || settingsXml.isBlank()) {
            settingsXml = DEFAULT_SETTINGS_XML;
        }
        List<String> args = new java.util.ArrayList<>(List.of(
            "-s", settingsXml, // 指定settings.xml
            "-f", pomXml, // 指定pom.xml
            "-B", // 批处理模式
            "-Dverbose=true" // 输出详细信息
        ));
        for (MavenInvokerGoal<?> goal : goals) {
            args.add(goal.getGoal());
            goal.runBefore();
        }

        MavenCli cli = new MavenCli();
        CliRequest cliRequest = createCliRequest(args.toArray(new String[0]), null);
        setCliRequestMultiModuleProjectDirectory(cliRequest, multiModuleProjectDirectory);
        setCliRequestWorkingDirectory(cliRequest, workingDirectory);

        MessageUtils.systemInstall();
        MessageUtils.registerShutdownHook();
        int result = cli.doMain(cliRequest);
        MessageUtils.systemUninstall();

        // must run even if maven execution failed
        for (MavenInvokerGoal<?> goal : goals) {
            goal.collectResult();
        }

        if (result != 0) {
            throw new RuntimeException("Maven execution failed with exit code: " + result);
        }
    }


    private static void setCliRequestWorkingDirectory(CliRequest cliRequest, String workingDirectory) {
        try {
            Field workingDirectoryField = cliRequest.getClass().getDeclaredField("workingDirectory");
            if (!workingDirectoryField.canAccess(cliRequest)) {
                workingDirectoryField.setAccessible(true);
                workingDirectoryField.set(cliRequest, new File(workingDirectory).getCanonicalFile().getAbsolutePath());
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to set workingDirectory", e);
        }
    }

    private static CliRequest createCliRequest(String[] args, ClassWorld classWorld) {
        try {
            Constructor<CliRequest> constructor = CliRequest.class.getDeclaredConstructor(
                String[].class,
                ClassWorld.class
            );
            if (!constructor.canAccess(null)) {
                constructor.setAccessible(true);
            }
            return constructor.newInstance(args, classWorld);
        } catch (Exception e) {
            throw new RuntimeException("Failed to create CliRequest", e);
        }
    }

    private static void setCliRequestMultiModuleProjectDirectory(CliRequest cliRequest, String multiModuleProjectDirectory) {
        try {
            Field multiModuleProjectDirectoryField = cliRequest.getClass().getDeclaredField(
                "multiModuleProjectDirectory");
            if (!multiModuleProjectDirectoryField.canAccess(cliRequest)) {
                multiModuleProjectDirectoryField.setAccessible(true);
                multiModuleProjectDirectoryField.set(
                    cliRequest,
                    new File(multiModuleProjectDirectory).getCanonicalFile()
                );
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to set multiModuleProjectDirectory", e);
        }
    }
}
