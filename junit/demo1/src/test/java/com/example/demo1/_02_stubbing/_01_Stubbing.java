package com.example.demo1._02_stubbing;

import com.example.demo1.Order;
import com.example.demo1.OrderService;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.junit.jupiter.api.*;
import org.mockito.Mockito;
import org.mockito.invocation.Invocation;
import org.mockito.invocation.InvocationOnMock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.stubbing.Answer;

/**
 * @author Tiger.Shen
 * @version 1.0
 * @date 2024/10/9
 * @description
 */
@ExtendWith(MockitoExtension.class)
public class _01_Stubbing {

    @Mock
    OrderService orderService;

    /**
     * 使用doXXX, 可以用来指定mock和spy对象的行为
     */
    @Test
    public void test() {
        // 当调用orderService的createOrder方法, 并且参数是new Order("hello", "world")的时候, 返回true
        Mockito.doReturn(true).when(orderService).createOrder(new Order("hello", "world"));

        // doNothing一般针对返回值为void的方法, 当调用orderService.save()并且参数是new Order()的时候, 不做任何事情
        Mockito.doNothing().when(orderService).save(new Order());

        // 当调用orderService.createOrder方法的时候, 并且参数是new Order()的时候, 抛出一个RuntimeException异常
        Mockito.doThrow(RuntimeException.class).when(orderService).createOrder(new Order());
        // 当调用orderService.createOrder()并且参数是new Order("1", "1")的时候, 抛出一个IllegalArgumentException("msg")异常
        Mockito.doThrow(new IllegalArgumentException("msg")).when(orderService).createOrder(new Order("1", "1"));

        // 当调用orderService.createOrder(), 并且参数是new Order("2", "2")时, 转而调用真实的方法
        Mockito.doCallRealMethod().when(orderService).createOrder(new Order("2", "2"));

        // 当调用orderService..createOrder(new Order("3", "3"))时, 通过Answer接口来动态的设置返回值
        Mockito.doAnswer(invocation -> {
            // 获取参数
            Order argument = invocation.getArgument(1, Order.class);
            if (argument.getFields1().equals("1")) {
                return false;
            }
            // 调用真实的方法
            return invocation.callRealMethod();
        }).when(orderService).createOrder(new Order("3", "3"));
    }


    /**
     * 使用when().then(), 只能指定mock对象的行为, spy对象使用这种方式有歧义
     */
    @Test
    public void test1() {
        Mockito.when(orderService.createOrder(new Order("hello", "world"))).thenReturn(true);
        Mockito.when(orderService.createOrder(new Order())).thenThrow(RuntimeException.class);
        Mockito.when(orderService.createOrder(new Order("1", "1"))).thenThrow(new IllegalArgumentException("msg"));
        Mockito.when(orderService.createOrder(new Order("2", "2"))).thenCallRealMethod();
        Answer<?> answer = (invocation) -> {
            // 获取参数
            Order argument = invocation.getArgument(1, Order.class);
            if (argument.getFields1().equals("1")) {
                return false;
            }
            // 调用真实的方法
            return invocation.callRealMethod();
        };
        Mockito.when(orderService.createOrder(new Order("2", "2"))).thenAnswer(answer); // thenAnswer和then是一样的
        Mockito.when(orderService.createOrder(new Order("3", "3"))).then(answer);

        // when().then()不能作用于void方法, 碰上void方法使用doXXX().when()吧
        // Mockito.when(orderService.save(new Order())).thenCallRealMethod();
    }


    /**
     * when().then()可以进行链式调用, 引来指定多次调用时的行为
     */
    @Test
    public void test2() {
        Mockito.when(orderService.createOrder(new Order("hello", "world")))
                .thenReturn(true) // 第一次调用时返回true
                .thenReturn(false) // 第二次调用时返回false
                .thenThrow(RuntimeException.class); // 第三次调用时抛出异常
    }

}
