package com.example.demo1._03_advanced;


import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import com.example.demo1._03_advanced._02_MockConstructor2.Grinder;
import com.example.demo1._03_advanced._02_MockConstructor2.WaterTank;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.MockedConstruction;
import org.mockito.Mockito;

import lombok.Getter;
import lombok.Setter;
import org.mockito.junit.jupiter.MockitoExtension;


/**
 * @author Tiger.Shen
 * @version 1.0
 * @date 2024/10/9
 * @description
 */
@ExtendWith(MockitoExtension.class)
public class _02_MockConstructor1 {


    public static class Fruit {

        public String getName() {
            return "Apple";
        }

        public String getColour() {
            return "Red";
        }
    }



    @Test
    public void test() {
        try (MockedConstruction<Fruit> mocked = Mockito.mockConstruction(Fruit.class)) {
            // 在这个范围内, Fruit的构造函数已经被mock了, 只要调用了Fruit的构造函数来创建对象,
            // 就会直接返回一个mock的Fruit对象, 而不会调用真实的构造函数

            Fruit fruit = new Fruit(); // 这会返回一个mock的Fruit对象

            // 可以对mock的Fruit对象进行一些操作
            Mockito.when(fruit.getName()).thenReturn("Banana");
            Mockito.when(fruit.getColour()).thenReturn("Yellow");

            // 验证mock的Fruit对象的方法是否被调用
            Mockito.verify(fruit).getName();
            Mockito.verify(fruit).getColour();

            // 可以使用mocked.constructed()来获取所有mock的Fruit对象
            List<Fruit> constructedFruits = mocked.constructed();
            assertThat(constructedFruits.size()).isEqualTo(1);
        }
    }
}
