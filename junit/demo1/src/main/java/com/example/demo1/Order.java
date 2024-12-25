package com.example.demo1;

/**
 * @author Tiger.Shen
 * @version 1.0
 * @date 2024/9/29
 * @description
 */
public class Order {

    private String fields1;

    public Order(String fields1, String fields2) {
        this.fields1 = fields1;
        this.fields2 = fields2;
    }

    public Order() {
    }

    public String getFields1() {
        return fields1;
    }

    public void setFields1(String fields1) {
        this.fields1 = fields1;
    }

    public String getFields2() {
        return fields2;
    }

    public void setFields2(String fields2) {
        this.fields2 = fields2;
    }

    private String fields2;

}
