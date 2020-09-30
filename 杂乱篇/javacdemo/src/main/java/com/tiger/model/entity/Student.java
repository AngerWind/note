package com.tiger.model.entity;


/**
 * @author tiger.shen
 * @version v1.0
 * @Title Student
 * @date 2020/9/25 16:35
 * @description
 */
public class Student {

    private Integer age;
    private String name;

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Student(Integer age, String name) {
        this.age = age;
        this.name = name;
    }
}
