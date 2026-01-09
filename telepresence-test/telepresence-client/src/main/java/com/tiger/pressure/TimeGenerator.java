package com.tiger.pressure;

import java.time.Instant;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.concurrent.atomic.AtomicLong;

public class TimeGenerator {

    private static final AtomicLong micros = new AtomicLong(0);
    private static final long START_EPOCH_MICROS; // 微秒起点

    static {
        // 起点时间，例如 2000-01-01T00:00:00
        ZonedDateTime start = ZonedDateTime.of(2026, 1, 8, 0, 0, 0, 0, ZoneOffset.systemDefault());
        START_EPOCH_MICROS = start.toInstant().toEpochMilli() * 1_000;
    }

    /**
     * 返回下一个时间的微秒
     * 每次增加1毫秒
     */
    public static long nextMicro() {
        // 增加 1 ms = 1000 μs
        return START_EPOCH_MICROS + micros.getAndAdd(1_000);
    }

    /**
     * 返回 RFC 3339 格式
     */
    public static String nextRFC3339() {
        long micro = nextMicro();
        long seconds = micro / 1_000_000;
        int nanos = (int) (micro % 1_000_000) * 1_000; // 微秒 -> 纳秒
        Instant instant = Instant.ofEpochSecond(seconds, nanos);
        return DateTimeFormatter.ISO_OFFSET_DATE_TIME
                .withZone(ZoneOffset.UTC)
                .format(instant);
    }

    public static void main(String[] args) {
        for (int i = 0; i < 5; i++) {
            System.out.println(nextMicro() + " -> " + nextRFC3339());
        }
    }
}