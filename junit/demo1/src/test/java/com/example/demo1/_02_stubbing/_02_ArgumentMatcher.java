package com.example.demo1._02_stubbing;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.stubbing.Answer;

import com.example.demo1.Order;
import com.example.demo1.OrderService;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.assertArg;

/**
 * @author Tiger.Shen
 * @version 1.0
 * @date 2024/10/9
 * @description
 */
@ExtendWith(MockitoExtension.class)
public class _02_ArgumentMatcher {

    @Mock
    OrderService orderService;

    /**
     * 使用doXXX, 可以用来指定mock和spy对象的行为
     */
    @Test
    public void test() {
        // 直接指定参数
        Mockito.doReturn(true).when(orderService).deleteOrder(new Order("hello", "world"), true);

        // any用来匹配任何对象实例
        // anyString(), anyInt(), anyByte(), anyChar(), anyDouble(), anyFloat(), anyBoolean(), anyShort(), anyLong()
        // anyCollection(), anyIterable(), anyList(), anyMap(), anySet()
        // any(Order.class) 匹配任意Order类型的对象
        // any() 匹配任意值
        Mockito.doReturn(true).when(orderService).deleteOrder(ArgumentMatchers.any(Order.class), ArgumentMatchers.anyBoolean());

        // isA(): 匹配当前类及其子类
        // eq(): 匹配相等的值
        // same(): 匹配相同的地址
        // refEq(): 使用反射来比较所有的属性是否相同, 可以排除指定的属性
        Mockito.doReturn(true).when(orderService).deleteOrder(ArgumentMatchers.isA(Order.class), ArgumentMatchers.eq(false));

        // startsWith(String prefix), endsWith(String suffix), contains(String substring), matchers(String regex), matchers(Pattern pattern): 匹配特定的字符串


        // isNull和isNull(Class T), isNotNull()和isNotNull(Class T), notNull()和notNull(Class T): 匹配null和非null值, isNotNull和notNull两个意思一样, 带类型的主要用于防止方法重载
        // nullable(Class t): 用于匹配特定类型的值, 或者null


        // xxxThat(): 自定义是否匹配
        Mockito.doReturn(true).when(orderService).deleteOrder(ArgumentMatchers.argThat(new ArgumentMatcher<Order>() {
            @Override
            public boolean matches(Order argument) {
                return false;
            }
        }), ArgumentMatchers.booleanThat(new ArgumentMatcher<Boolean>() {
            @Override
            public boolean matches(Boolean argument) {
                return false;
            }
        }));


        // or(): 或
        // and(): 与
        // not(): 非
        // cmpEq(): 通过类型自身的compareTo方法来比较
        // geq: 大于等于
        // gt: 大于
        // leq: 小于等于
        // le小于
        // aryEq: 比较数值是否相等
        Mockito.doReturn(true).when(orderService).deleteOrder(AdditionalMatchers.or(new Order("1", "1"), new Order("2", "2")), ArgumentMatchers.eq(false));
        Mockito.doReturn(true).when(orderService).deleteOrder(AdditionalMatchers.not(new Order()), ArgumentMatchers.eq(false));
    }

}
