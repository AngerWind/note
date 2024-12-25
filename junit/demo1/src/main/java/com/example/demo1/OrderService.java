package com.example.demo1;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * @author Tiger.Shen
 * @version 1.0
 * @date 2024/9/29
 * @description
 */

@Service
public class OrderService {

    @Autowired
    private OrderDao orderDao;

    public Boolean createOrder(Order order) {
        if (order == null) {
            return false;
        }
        return orderDao.createOrder(order);
    }

    public void save(Order order) {
        orderDao.save(order);
    }

    public Boolean deleteOrder(Order order, boolean force){
        return true;
    }

    public Order getOrder(String orderId){
        return orderDao.getOrder(orderId);
    }
}
