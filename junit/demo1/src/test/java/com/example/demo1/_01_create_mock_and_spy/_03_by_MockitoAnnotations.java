package com.example.demo1._01_create_mock_and_spy;

import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;




public class _03_by_MockitoAnnotations {

    // 通过class来创建一个mock对象
    // 等效于List<?> mockList = Mockito.mock(List.class);
    @Mock
    List<?> mockList;

    // 通过class来创建一个spy对象
    // 等效于List<?> spyList = Mockito.spy(AbstractList.class);
    @Spy
    List<?> spyList;

    // 通过一个对象来创建一个spy对象
    // 等效于List<?> spied = Mockito.spy(new ArrayList<>());
    // !!!! 需要注意的是, 此时的spied不是刚刚new出来的, Mockito会对刚刚new出来的list进行代理, 所以spied是代理对象
    @Spy
    List<?> spied = new ArrayList<>();

    @BeforeEach
    public void init() {
        // 在junit5中启用mockito, 这样就可以使用各种注解了
        MockitoAnnotations.openMocks(this);
    }

    @Test
    public void test() {
        // ...
    }
}
