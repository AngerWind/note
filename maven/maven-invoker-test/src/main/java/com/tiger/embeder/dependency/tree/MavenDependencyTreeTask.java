package com.tiger.embeder.dependency.tree;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.LoggerContext;
import com.tiger.embeder.MavenInvokerBaseGoal;
import com.tiger.embeder.ThreadBasedMemoryAppender;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.concurrent.locks.ReentrantLock;

public class MavenDependencyTreeTask extends MavenInvokerBaseGoal<List<String>> {
    public static final ThreadBasedMemoryAppender DEPENDENCY_TREE_LOG_APPENDER = new ThreadBasedMemoryAppender();
    public static final String GOAL = "dependency:tree";

    private static boolean init = false;
    private static ReentrantLock lock = new ReentrantLock();

    public MavenDependencyTreeTask() {
        super(GOAL);
    }


    @Override
    public void collectResult() {
        List<String> treeLog = DEPENDENCY_TREE_LOG_APPENDER.getAndClearLogsForThread(Thread.currentThread().getName());
        if (treeLog != null && !treeLog.isEmpty()) {
            treeLog.removeFirst();
            this.result = treeLog;
        }
    }

    @Override
    public void runBefore() {
        if (!init) {
            lock.lock();
            try {
                if (!init) {
                    LoggerContext context = (LoggerContext) LoggerFactory.getILoggerFactory();
                    ch.qos.logback.classic.Logger logger =
                        (ch.qos.logback.classic.Logger)LoggerFactory.getLogger("org.apache.maven.plugins.dependency.tree.TreeMojo");
                    logger.setLevel(Level.INFO); // 强制设置为info级别
                    DEPENDENCY_TREE_LOG_APPENDER.setContext(context);
                    DEPENDENCY_TREE_LOG_APPENDER.start();
                    logger.addAppender(DEPENDENCY_TREE_LOG_APPENDER);
                }
            } finally {
                lock.unlock();
            }
        }
    }
}
