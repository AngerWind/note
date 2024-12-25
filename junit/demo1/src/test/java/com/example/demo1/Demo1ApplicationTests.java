package com.example.demo1;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.verify;

@SpringBootTest
class Demo1ApplicationTests {

    @MockBean
    private OrderDao orderDao;

    @Autowired
    private OrderService orderService;

    @Test
    void contextLoads() {
        doReturn(true).when(orderDao).createOrder(any());

        Order order = new Order();
        order.setFields1("1");
        order.setFields2("2");

        Boolean result = orderService.createOrder(order);
        assert result;

        // verify(orderDao).createOrder(ArgumentCaptor.captor())
    }

}
