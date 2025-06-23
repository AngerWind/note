package com.tiger.embeder.dependency.classpath;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.LoggerContext;
import com.tiger.embeder.MavenInvokerBaseGoal;
import com.tiger.embeder.ThreadBasedMemoryAppender;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.concurrent.locks.ReentrantLock;

public class MavenBuildClasspathTask extends MavenInvokerBaseGoal<String> {
    public static final ThreadBasedMemoryAppender BUILD_CLASSPATH_LOG_APPENDER = new ThreadBasedMemoryAppender();
    public static final String GOAL = "dependency:build-classpath";

    private static boolean init = false;
    private static ReentrantLock lock = new ReentrantLock();


    public MavenBuildClasspathTask() {
        super(GOAL);
    }

    @Override
    public void collectResult() {
        List<String> logs = BUILD_CLASSPATH_LOG_APPENDER.getAndClearLogsForThread(Thread.currentThread().getName());
        if (logs != null && !logs.isEmpty()) {
            // 日志只有一行
            this.result = logs.getFirst();
        }
    }

    @Override
    public void runBefore() {
        if (!init) {
            lock.lock();
            try {
                if (!init) {
                    LoggerContext context = (LoggerContext) LoggerFactory.getILoggerFactory();

                    ch.qos.logback.classic.Logger logger1 = (ch.qos.logback.classic.Logger)LoggerFactory.getLogger("org.apache.maven.plugins.dependency.fromDependencies.BuildClasspathMojo");
                    logger1.setLevel(Level.INFO); // 强制设置为info级别
                    BUILD_CLASSPATH_LOG_APPENDER.setContext(context);
                    BUILD_CLASSPATH_LOG_APPENDER.start();
                    logger1.addAppender(BUILD_CLASSPATH_LOG_APPENDER);
                }
            } finally {
                lock.unlock();
            }
        }
    }
}
