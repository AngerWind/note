package com.example.demo1._03_advanced;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.mockito.MockedConstruction;
import org.mockito.Mockito;

import lombok.Getter;
import lombok.Setter;
import org.powermock.api.mockito.PowerMockito;

/**
 * @author Tiger.Shen
 * @version 1.0
 * @date 2024/10/9
 * @description
 */
public class _03_MockPrivateMethod {

    public static class LuckyNumberGenerator {

        public int getLuckyNumber(String name) {
            saveIntoDatabase(name);
            if (name == null) {
                return getDefaultLuckyNumber();
            }
            return getComputedLuckyNumber(name.length());
        }

        private int getDefaultLuckyNumber() {
            return 0;
        }

        private int getComputedLuckyNumber(int length) {
            return 0;
        }

        private void saveIntoDatabase(String name) { }

    }


    /**
     * 这个代码跑不起来, 有可能powermock的版本有问题
     */
    @Test
    public void test() throws Exception {
        LuckyNumberGenerator luckyNumberGenerator = new LuckyNumberGenerator();
        LuckyNumberGenerator spy = PowerMockito.spy(luckyNumberGenerator);

        // 当调用saveIntoDatabase时, 不做任何操作
        PowerMockito.doNothing().when(spy, "saveIntoDatabase", Mockito.anyString());
        // 当调用getDefaultLuckyNumber时, 返回100
        PowerMockito.when(spy, "getDefaultLuckyNumber").thenReturn(100);
        // 当调用getComputedLuckyNumber时, 返回100
        PowerMockito.when(spy, "getComputedLuckyNumber", Mockito.anyInt()).thenReturn(100);

        // 调用真实的方法
        int luckyNumber = luckyNumberGenerator.getLuckyNumber("Tiger");

        // 校验
        Assertions.assertEquals(100, luckyNumber);
    }
}
