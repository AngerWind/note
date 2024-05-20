package com.tiger;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tiger.model.entity.Student;

/**
 * @author tiger.shen
 * @version v1.0
 * @Title MainApp
 * @date 2020/9/25 16:35
 * @description
 */
public class MainApp {

    public static void main(String[] args) {
        try {
            Student a = new Student(12, "zhangsna");
            ObjectMapper objectMapper = new ObjectMapper();
            String s = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(a);
            System.out.println(s);
        } catch (JsonProcessingException e){
            e.printStackTrace();
        }

    }
}
