package com.example.graalvm.springboot.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@AotProxyHint
public class GraalvmSpringbootDemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(GraalvmSpringbootDemoApplication.class, args);
    }

}
