package com.example.demo1;

import org.springframework.stereotype.Component;

/**
 * @author Tiger.Shen
 * @version 1.0
 * @date 2024/9/29
 * @description
 */

@Component
public class OrderDao {

    public Boolean createOrder(Order order) {
        return true;
    }

    public void save(Order order) {
        return;
    }

    public Order getOrder(String orderId) {
        return new Order(orderId, "1");
    }
}
