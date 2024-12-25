package com.example.demo1._03_advanced;

import com.example.demo1._03_advanced._02_MockConstructor1.Fruit;
import lombok.*;
import org.junit.jupiter.api.Test;
import org.mockito.*;

import java.util.List;
import org.junit.jupiter.api.*;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

/**
 * @author Tiger.Shen
 * @version 1.0
 * @date 2024/10/9
 * @description
 */
public class _02_MockConstructor2 {

    public static class CoffeeMachine {

        private Grinder grinder;
        private WaterTank tank;

        public CoffeeMachine() {
            this.grinder = new Grinder();
            this.tank = new WaterTank();
        }

        public String makeCoffee() {
            String type = this.tank.isEspresso() ? "Espresso" : "Americano";
            return String.format("Finished making a delicious %s made with %s beans", type, this.grinder.getBeans());
        }
    }

    public static class Grinder {

        private String beans;

        public Grinder() {
            this.beans = "Guatemalan";
        }

        public String getBeans() {
            return beans;
        }

        public void setBeans(String beans) {
            this.beans = beans;
        }
    }

    public static class WaterTank {

        private int mils;

        public WaterTank() {
            this.mils = 25;
        }

        public boolean isEspresso() {
            return getMils() < 50;
        }

        public int getMils() {
            return mils;
        }

        public void setMils(int mils) {
            this.mils = mils;
        }
    }

    @Test
    public void test() {
        try (MockedConstruction<Grinder> mockedGrinder = Mockito.mockConstruction(Grinder.class);
            MockedConstruction<WaterTank> mockedWaterTank = Mockito.mockConstruction(WaterTank.class)) {
            // 在这个范围内, Grinder和WaterTank的构造函数已经被mock了, 只要调用了Grinder和WaterTank的构造函数来创建对象,
            // 就会直接返回一个mock的Grinder和WaterTank对象, 而不会调用真实的构造函数

            // 创建一个CoffeeMachine, 内部会调用WaterTank和Grinder的构造函数, 所以会创建他们的mock对象
            CoffeeMachine machine = new CoffeeMachine();

            WaterTank tank = mockedWaterTank.constructed().get(0); // 获取mock创建的的WaterTank对象
            Grinder grinder = mockedGrinder.constructed().get(0); // 获取mock创建的Grinder对象

            when(tank.isEspresso()).thenReturn(false); // 定义mock的WaterTank的行为
            when(grinder.getBeans()).thenReturn("Peruvian"); // 定义mock的Grinder的行为

            // 验证CoffeeMachine的行为
            Assertions.assertEquals("Finished making a delicious Americano made with Peruvian beans",
                machine.makeCoffee());

            assertThatThrownBy(() -> {

            });

        }
    }
}
