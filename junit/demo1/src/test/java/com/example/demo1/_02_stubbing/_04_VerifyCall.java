package com.example.demo1._02_stubbing;


import com.example.demo1.OrderDao;
import org.hamcrest.MatcherAssert;
import org.hamcrest.Matchers;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;

import com.example.demo1.Order;
import com.example.demo1.OrderService;

import java.util.List;

/**
 * @author Tiger.Shen
 * @version 1.0
 * @date 2024/10/9
 * @description
 */
@ExtendWith(MockitoExtension.class)
public class _04_VerifyCall {

    @InjectMocks
    OrderService orderService;

    @Mock
    OrderDao orderDao;

    @Test
    public void test() {

        // 定义行为
        Mockito.doReturn(new Order("1", "1")).when(orderDao).getOrder("1");
        Mockito.doThrow(RuntimeException.class).when(orderDao).getOrder("2");

        Order order = orderService.getOrder("1");

        Assertions.assertThrows(RuntimeException.class, () -> {
            orderService.getOrder("2");
        });


        /**
         * 直接指定方法的调用参数
         */
        // 验证orderDao.getOrder("2")是否被调用了一次
        Mockito.verify(orderDao, Mockito.times(1)).getOrder("2");
        // 验证orderDao.getOrder("1")是否被调用了一次
        Mockito.verify(orderDao, Mockito.times(1)).getOrder("1");


        /**
         * 还可以使用ArgumentMatchers来指定调用的参数
         */
        // 校验getOrder()至少被调用了2次, 并且参数为"1"或者"2"
        Mockito.verify(orderDao, Mockito.atLeast(2)).getOrder(AdditionalMatchers.or(ArgumentMatchers.eq("1"), ArgumentMatchers.eq("2")));
        // 校验getOrder()被至多调用了2次, 并且参数为任何字符串
        Mockito.verify(orderDao, Mockito.atMost(2)).getOrder(ArgumentMatchers.anyString());


        /**
         * 或者可以使用ArgumentCaptor来捕获参数, 然后对调用的参数进行校验
         */
        ArgumentCaptor<String> argumentCaptor = ArgumentCaptor.forClass(String.class);
        // 验证getOrder被调用了2次, 并将调用的参数保存到argumentCaptor中
        // 想要捕获多个参数, 需要创建多个ArgumentCaptor
        // 如果getOrder被调用了多次, 那么会将所有参数都保存到ArgumentCaptor
        Mockito.verify(orderDao, Mockito.times(2)).getOrder(argumentCaptor.capture());

        // 获取每次调用时的参数, 返回List, 然后获取第1, 2次调用时的参数, 进行校验
        Assertions.assertEquals("1", argumentCaptor.getAllValues().get(0));
        Assertions.assertEquals("2", argumentCaptor.getAllValues().get(1));

        // 获取最后一次的调用
        Assertions.assertEquals("2", argumentCaptor.getValue());
    }

}
