package com.example.demo1._03_advanced;


import com.example.demo1.OrderDao;
import org.assertj.core.api.AbstractBigDecimalAssert;
import org.hamcrest.MatcherAssert;
import org.hamcrest.Matchers;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;

import com.example.demo1.Order;
import com.example.demo1.OrderService;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;


/**
 * @author Tiger.Shen
 * @version 1.0
 * @date 2024/10/9
 * @description
 */
@ExtendWith(MockitoExtension.class)
public class _01_MockStaticMethod {

    public static class StaticUtils {

        private StaticUtils() {}

        public static List<Integer> range(int start, int end) {
            return IntStream.range(start, end)
                    .boxed()
                    .collect(Collectors.toList());
        }

        public static String name() {
            return "Baeldung";
        }
    }

    @Test
    public void givenStaticMethodWithNoArgs_whenMocked_thenReturnsMockSuccessfully() {
        assertThat(StaticUtils.name()).isEqualTo("Baeldung");

        // utilities是threadlocal的, 并且必须在测试方法结尾被关闭
        // 之后在try-catch中, 静态方法才是被代理的
        // 在try-catch之外, 静态方法是正常调用的
        try (MockedStatic<StaticUtils> utilities = Mockito.mockStatic(StaticUtils.class)) {
            // 指定调用name的时候, 返回Eugen
            utilities.when(StaticUtils::name).thenReturn("Eugen");
            // 校验
            assertThat(StaticUtils.name()).isEqualTo("Eugen");
        }

        assertThat(StaticUtils.name()).isEqualTo("Baeldung");

    }

    /**
     * mock 有参数的静态方法
     */
    @Test
    void givenStaticMethodWithArgs_whenMocked_thenReturnsMockSuccessfully() {
        assertThat(StaticUtils.range(2, 6)).containsExactly(2, 3, 4, 5);

        // 只有在try-catch内, mock才是有效的
        try (MockedStatic<StaticUtils> utilities = Mockito.mockStatic(StaticUtils.class)) {
            // 使用lambda来定义, 当调用range(2, 6)时, 返回[10, 11, 12]
            utilities.when(() -> StaticUtils.range(2, 6))
                    .thenReturn(Arrays.asList(10, 11, 12));

            // 实际调用并验证
            assertThat(StaticUtils.range(2, 6)).containsExactly(10, 11, 12);
        }

        assertThat(StaticUtils.range(2, 6)).containsExactly(2, 3, 4, 5);
    }
}
