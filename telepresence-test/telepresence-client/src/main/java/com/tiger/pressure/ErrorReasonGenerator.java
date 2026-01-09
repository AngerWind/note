package com.tiger.pressure;

import java.util.concurrent.ThreadLocalRandom;

public class ErrorReasonGenerator {

    // 基础动词
    private static final String[] ACTIONS = {
        "fail", "timeout", "reject", "drop", "abort",
        "reset", "deny", "block", "close"
    };

    // 资源 / 对象
    private static final String[] TARGETS = {
        "request", "connection", "task", "thread",
        "resource", "operation", "stream", "channel"
    };

    // 原因 / 状态
    private static final String[] REASONS = {
        "limit", "error", "busy", "overflow",
        "invalid", "unavailable", "corrupt"
    };

    // 参数 key
    private static final String[] PARAM_KEYS = {
        "id", "code", "cost", "size", "retry", "index"
    };

    /**
     * 生成 error_reason（无语义、符合生产概率）
     */
    public static String next() {
        ThreadLocalRandom r = ThreadLocalRandom.current();

        double p = r.nextDouble();

        // 70%：短错误（最常见）
        if (p < 0.70) {
            return action() + "_" + target();
        }

        // 25%：中等复杂度
        if (p < 0.95) {
            return action() + "_" + target()
                    + "_" + reason();
        }

        // 5%：复杂错误（带参数）
        return action() + "_" + target()
                + "_" + reason()
                + " " + randomParam();
    }

    private static String action() {
        return pick(ACTIONS);
    }

    private static String target() {
        return pick(TARGETS);
    }

    private static String reason() {
        return pick(REASONS);
    }

    private static String randomParam() {
        return pick(PARAM_KEYS) + "=" + randomValue();
    }

    private static String randomValue() {
        ThreadLocalRandom r = ThreadLocalRandom.current();

        // 参数值也做概率分布
        int type = r.nextInt(3);
        switch (type) {
            case 0:
                return String.valueOf(r.nextInt(1, 10000));   // 数字
            case 1:
                return String.format("%.2f", r.nextDouble(1, 500)); // cost
            default:
                return "0x" + Integer.toHexString(r.nextInt()); // hash
        }
    }

    private static String pick(String[] array) {
        return array[ThreadLocalRandom.current().nextInt(array.length)];
    }
}
