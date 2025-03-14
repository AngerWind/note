package com.example.graalvm.springboot.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author Tiger.Shen
 * @version 1.0
 * @date 2024/12/10
 * @description
 */

@RestController
public class HelloController {

    @GetMapping("/hello")
    public String hello() {
        System.out.println("hello");
        return "Hello, World!";
    }
}
