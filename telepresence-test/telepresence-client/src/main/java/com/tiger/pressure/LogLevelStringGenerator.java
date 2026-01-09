package com.tiger.pressure;

import java.util.NavigableMap;
import java.util.TreeMap;
import java.util.concurrent.ThreadLocalRandom;

public class LogLevelStringGenerator {

    /**
     * key   : 累计概率 (0 ~ 1)
     * value : log level 字符串
     */
    private static final NavigableMap<Double, String> LEVEL_PROBABILITY_MAP = new TreeMap<>();

    private static double cumulativeProbability = 0.0;

    static {
        // 概率总和必须为 1.0
        add(0.05, "trace");     // 5%
        add(0.15, "debug");     // 15%
        add(0.60, "info");      // 60%
        add(0.15, "warning");   // 15%
        add(0.05, "error");     // 5%
    }

    private static void add(double probability, String level) {
        cumulativeProbability += probability;
        LEVEL_PROBABILITY_MAP.put(cumulativeProbability, level);
    }

    /**
     * 生成一个符合概率分布的 log level（String）
     */
    public static String next() {
        double random = ThreadLocalRandom.current().nextDouble();
        return LEVEL_PROBABILITY_MAP.ceilingEntry(random).getValue();
    }
}
