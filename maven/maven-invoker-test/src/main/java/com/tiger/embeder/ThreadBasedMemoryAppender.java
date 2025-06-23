package com.tiger.embeder;

import ch.qos.logback.core.AppenderBase;
import ch.qos.logback.classic.spi.ILoggingEvent;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

public class ThreadBasedMemoryAppender extends AppenderBase<ILoggingEvent> {

    // 每个线程的日志列表
    private final Map<String, List<String>> threadLogs = new ConcurrentHashMap<>();

    @Override
    protected void append(ILoggingEvent event) {
        String threadName = event.getThreadName();
        String message = event.getFormattedMessage();

        threadLogs
            .computeIfAbsent(threadName, k -> new CopyOnWriteArrayList<>())
            .add(message);
    }

    // ✅ 取出并清除指定线程的日志
    public List<String> getAndClearLogsForThread(String threadName) {
        return threadLogs.remove(threadName);
    }

    // 单独清除
    public void clearLogsForThread(String threadName) {
        threadLogs.remove(threadName);
    }

    // 清除全部
    public void clearAllLogs() {
        threadLogs.clear();
    }

    // （可选）查看当前所有日志（调试用）
    public Map<String, List<String>> getAllLogs() {
        return threadLogs;
    }
}
