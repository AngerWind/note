package com.tiger.pressure;

import java.util.concurrent.ThreadLocalRandom;

public class SpendTimeGenerator {

    /**
     * 生成接口耗时（毫秒），符合生产概率分布
     *
     * 默认分布：
     * - 70% 短耗时 5~100ms
     * - 25% 中等耗时 100~500ms
     * - 5% 长耗时 500~2000ms
     */
    public static long next() {
        ThreadLocalRandom r = ThreadLocalRandom.current();
        double p = r.nextDouble();

        if (p < 0.70) {
            // 短耗时
            return 5 + r.nextLong(96); // 5~100ms
        } else if (p < 0.95) {
            // 中耗时
            return 100 + r.nextLong(400); // 100~500ms
        } else {
            // 长耗时
            return 500 + r.nextLong(1500); // 500~2000ms
        }
    }
}
