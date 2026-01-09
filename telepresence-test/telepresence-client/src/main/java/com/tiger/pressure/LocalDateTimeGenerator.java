package com.tiger.pressure;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.concurrent.atomic.AtomicLong;

public final class LocalDateTimeGenerator {

    /**
     * 起始时间：2000-01-01 00:00:00 (UTC)
     */
    private static final LocalDateTime BASE_TIME =
            LocalDateTime.of(2000, 1, 1, 0, 0, 0);

    /**
     * 基准 epoch 秒
     */
    private static final long BASE_EPOCH_SECOND =
            BASE_TIME.toEpochSecond(ZoneOffset.UTC);

    /**
     * 原子秒计数器（从 0 开始，每次 +1 秒）
     */
    private static final AtomicLong SEQ = new AtomicLong(0);

    private LocalDateTimeGenerator() {
        // 工具类，禁止实例化
    }

    /**
     * 生成一个全局唯一、单调递增的 LocalDateTime
     * 每次调用，时间 +1 秒
     */
    public static LocalDateTime next() {
        long offsetSeconds = SEQ.getAndIncrement();
        return LocalDateTime.ofEpochSecond(
                BASE_EPOCH_SECOND + offsetSeconds,
                0,
                ZoneOffset.UTC
        );
    }
}