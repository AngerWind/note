package com.tiger.pressure;

import java.util.concurrent.ThreadLocalRandom;

public class ServiceNameGenerator {

    /**
     * 写死的 20 个 serviceName
     */
    private static final String[] SERVICES = {
        "user-service",
        "order-service",
        "payment-service",
        "inventory-service",
        "product-service",
        "search-service",
        "recommend-service",
        "auth-service",
        "gateway-service",
        "notification-service",
        "message-service",
        "billing-service",
        "shipping-service",
        "cart-service",
        "review-service",
        "coupon-service",
        "promotion-service",
        "analytics-service",
        "report-service",
        "admin-service"
    };

    /**
     * 随机返回一个 serviceName
     */
    public static String next() {
        int index = ThreadLocalRandom.current().nextInt(SERVICES.length);
        return SERVICES[index];
    }
}
