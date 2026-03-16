package org.tiger.calcite.example4flyway_jpa_demo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.tiger.calcite.example4flyway_jpa_demo.entity.Order;

import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Long> {

    List<Order> findByUserId(Long userId);

}