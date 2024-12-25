package com.example.demo1._01_create_mock_and_spy;

import org.mockito.Mockito;

import java.util.AbstractList;
import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

/**
 * @author Tiger.Shen
 * @version 1.0
 * @date 2024/10/9
 * @description
 */
public class _01_by_static_method {


    @Test
    public void test() {
        List<?> mockList = Mockito.mock(List.class); // 通过class来创建一个mock对象
        assert Mockito.mockingDetails(mockList).isMock(); // 判断是否为mock对象

        List<?> spyList = Mockito.spy(AbstractList.class); // 通过class来创建一个spy对象
        assert Mockito.mockingDetails(spyList).isSpy(); // 判断是否为spy对象
        assert Mockito.mockingDetails(spyList).isMock(); // 判断是否为mock对象

        List<?> spied = Mockito.spy(new ArrayList<>()); // 通过一个对象来创建一个spy对象
        assert Mockito.mockingDetails(spyList).isSpy(); // 判断是否为spy对象
        assert Mockito.mockingDetails(spyList).isMock(); // 判断是否为mock对象
    }
}
