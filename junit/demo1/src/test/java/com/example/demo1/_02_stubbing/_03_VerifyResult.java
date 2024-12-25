package com.example.demo1._02_stubbing;


import org.hamcrest.MatcherAssert;
import org.hamcrest.Matchers;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.internal.matchers.Or;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.stubbing.Answer;

import com.example.demo1.Order;
import com.example.demo1.OrderService;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.assertArg;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

/**
 * @author Tiger.Shen
 * @version 1.0
 * @date 2024/10/9
 * @description
 */
@ExtendWith(MockitoExtension.class)
public class _03_VerifyResult {

    @Mock
    OrderService orderService;

    @Test
    public void test() {
        // 定义行为
        Mockito.doReturn(new Order("1", "1")).when(orderService).getOrder("1");
        Mockito.doThrow(RuntimeException.class).when(orderService).getOrder("2");

        Order order = orderService.getOrder("1");

        // 使用junit断言
        Assertions.assertEquals("hello", order.getFields1());

        // 使用hamcrest断言
        MatcherAssert.assertThat(order.getFields1(), Matchers.equalTo("1"));

        // 断言抛出异常
        Assertions.assertThrows(RuntimeException.class, () -> {
            orderService.getOrder("2");
        });
    }

}
