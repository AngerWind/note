package org.tiger.calcite.example4flyway_jpa_demo.controller;


import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.tiger.calcite.example4flyway_jpa_demo.entity.Order;
import org.tiger.calcite.example4flyway_jpa_demo.repository.OrderRepository;

import java.util.List;

@RestController
@AllArgsConstructor
public class OrderController {

    private final OrderRepository orderRepository;

    @GetMapping("/orders/{userId}")
    public List<Order> orders(@PathVariable Long userId) {
        return orderRepository.findByUserId(userId);
    }
}
