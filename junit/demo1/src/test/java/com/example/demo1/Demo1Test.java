package com.example.demo1;

import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.boot.test.context.SpringBootTest;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.boot.test.context.TestComponent;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author Tiger.Shen
 * @version 1.0
 * @date 2024/9/30
 * @description
 */

@ExtendWith(MockitoExtension.class)
public class Demo1Test {

    public static class MyDictionaryAndList {
        public Map<String, String> wordMap;
        public List<String> list;

        public MyDictionaryAndList() {
            wordMap = new HashMap<String, String>();
            list = new ArrayList<String>();
        }
        public void add(final String word, final String meaning) {
            System.out.println("add");
            wordMap.put(word, meaning);
        }
        public String getMeaning(final String word) {
            System.out.println("getMeaning");
            return wordMap.get(word);
        }

        public void addListElement(final String word) {
            System.out.println("addListElement");
            list.add(word);
        }

        public String getListElement(final int index) {
            System.out.println("getElement");
            return list.get(index);
        }
    }

    List<String> arrayList = new ArrayList<String>();

    @Mock
    Map<String, String> map;

    @Spy
    List<String> list = arrayList;

    @InjectMocks
    MyDictionaryAndList myDictionaryAndList;

    @Test
    public void test(){

        System.out.println(map == myDictionaryAndList.wordMap); // true
        System.out.println(list == myDictionaryAndList.list); // true

        System.out.println(list == arrayList); // false

        myDictionaryAndList.add("hello", "world");
        System.out.println(myDictionaryAndList.getMeaning("hello") == null); // true

        myDictionaryAndList.addListElement("hello");
        System.out.println(myDictionaryAndList.getListElement(0)); // hello


        System.out.println(list.add("hello"));
    }

    @Test
    public void test2() {
        ArrayList spied = Mockito.spy(ArrayList.class);

        spied.add("one");
        spied.add("two");
    }
}
